#!/usr/bin/env swift
import Cocoa
import Foundation

guard CommandLine.arguments.count >= 3 else {
  fputs("Usage: capture-window.swift <process-name> <output.png>\n", stderr)
  exit(2)
}

let processName = CommandLine.arguments[1].lowercased()
let outPath = CommandLine.arguments[2]

guard let screen = NSScreen.main else {
  fputs("error: no main screen\n", stderr)
  exit(1)
}

let visible = screen.visibleFrame
let menuTop = Int(screen.frame.height - visible.origin.y - visible.height)

// Resize target app window to fill visible frame (top-left coords for System Events).
let ax = Int(visible.origin.x)
let ay = menuTop
let aw = Int(visible.width)
let ah = Int(visible.height)

let resizeScript = """
tell application "\(processName)" to activate
delay 0.5
tell application "System Events"
  tell process "\(processName)"
    set frontmost to true
    if (count of windows) is 0 then error "no window"
    tell window 1
      set position to {\(ax), \(ay)}
      set size to {\(aw), \(ah)}
    end tell
  end tell
end tell
"""

var err: NSDictionary?
if let script = NSAppleScript(source: resizeScript) {
  script.executeAndReturnError(&err)
}
if let err {
  fputs("AppleScript: \(err)\n", stderr)
  exit(1)
}

Thread.sleep(forTimeInterval: 0.8)

let opts: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
guard let infoList = CGWindowListCopyWindowInfo(opts, kCGNullWindowID) as? [[String: Any]] else {
  fputs("error: window list\n", stderr)
  exit(1)
}

var windowId: CGWindowID?
for info in infoList {
  guard let owner = info[kCGWindowOwnerName as String] as? String,
        owner.lowercased() == processName,
        let layer = info[kCGWindowLayer as String] as? Int, layer == 0,
        let wid = info[kCGWindowNumber as String] as? CGWindowID,
        let bounds = info[kCGWindowBounds as String] as? [String: CGFloat],
        let w = bounds["Width"], let h = bounds["Height"], w > 400, h > 300
  else { continue }
  windowId = wid
  break
}

guard let wid = windowId else {
  fputs("error: window not found for \(processName)\n", stderr)
  exit(1)
}

let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
task.arguments = ["-x", "-l\(wid)", outPath]
try task.run()
task.waitUntilExit()

if task.terminationStatus != 0 {
  fputs("error: screencapture exit \(task.terminationStatus)\n", stderr)
  exit(1)
}

print(outPath)
