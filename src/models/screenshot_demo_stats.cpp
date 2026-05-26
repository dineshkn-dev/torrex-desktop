#include "screenshot_demo_stats.hpp"

#include <QProcessEnvironment>
#include <QString>

namespace torrin::models {

namespace {

bool screenshotMode()
{
    return qEnvironmentVariableIsSet("TORRIN_SCREENSHOT");
}

void setSingleFile(TorrentSnapshot& snap, int progress_percent)
{
    TorrentFileSnapshot file;
    file.index = 0;
    file.path = snap.name.empty() ? "download.iso" : snap.name;
    file.priority = 4;
    file.progress_percent = progress_percent;
    file.size_bytes = snap.total;
    snap.files = {file};
}

void applyUbuntuDemo(TorrentSnapshot& snap)
{
    constexpr std::int64_t kTotal = 5'990'000'000LL;
    constexpr int kProgress = 42;

    snap.state = TorrentState::Downloading;
    snap.has_metadata = true;
    snap.total = kTotal;
    snap.downloaded = (kTotal * kProgress) / 100;
    snap.progress_percent = kProgress;
    snap.download_rate = 3'400'000;
    snap.upload_rate = 98'000;
    snap.uploaded_total = 52'000'000;
    snap.num_peers = 16;
    snap.num_seeds = 12;
    snap.num_connections = 48;
    snap.eta_seconds = 16 * 60 + 20;
    snap.upload_stopped = false;
    snap.sequential_download = false;
    if (snap.save_path.empty()) {
        snap.save_path = "/Users/Shared/Torrin/Downloads";
    }
    setSingleFile(snap, kProgress);
}

void applyDebianDemo(TorrentSnapshot& snap)
{
    constexpr std::int64_t kTotal = 3'800'000'000LL;
    constexpr int kProgress = 76;

    snap.state = TorrentState::Downloading;
    snap.has_metadata = true;
    snap.total = kTotal;
    snap.downloaded = (kTotal * kProgress) / 100;
    snap.progress_percent = kProgress;
    snap.download_rate = 1'100'000;
    snap.upload_rate = 220'000;
    snap.uploaded_total = 410'000'000;
    snap.num_peers = 11;
    snap.num_seeds = 9;
    snap.num_connections = 31;
    snap.eta_seconds = 8 * 60 + 5;
    snap.upload_stopped = false;
    snap.sequential_download = true;
    if (snap.save_path.empty()) {
        snap.save_path = "/Users/Shared/Torrin/Downloads";
    }
    setSingleFile(snap, kProgress);
}

void applyGenericDemo(TorrentSnapshot& snap, int slot)
{
    constexpr std::int64_t kTotal = 2'400'000'000LL;
    const int progress = 20 + slot * 15;

    snap.state = TorrentState::Downloading;
    snap.has_metadata = true;
    snap.total = kTotal;
    snap.downloaded = (kTotal * progress) / 100;
    snap.progress_percent = progress;
    snap.download_rate = 850'000 + slot * 200'000;
    snap.upload_rate = 64'000;
    snap.uploaded_total = 12'000'000;
    snap.num_peers = 8 + slot;
    snap.num_seeds = 6;
    snap.num_connections = 22 + slot * 4;
    snap.eta_seconds = (30 - slot * 5) * 60;
    snap.upload_stopped = false;
    setSingleFile(snap, progress);
}

} // namespace

void applyScreenshotDemoStats(std::vector<TorrentSnapshot>& items)
{
    if (!screenshotMode() || items.empty()) {
        return;
    }

    int slot = 0;
    for (TorrentSnapshot& snap : items) {
        const QString name = QString::fromStdString(snap.name);
        if (name.contains(QStringLiteral("ubuntu"), Qt::CaseInsensitive)) {
            applyUbuntuDemo(snap);
        } else if (name.contains(QStringLiteral("debian"), Qt::CaseInsensitive)) {
            applyDebianDemo(snap);
        } else {
            applyGenericDemo(snap, slot++);
        }
    }
}

} // namespace torrin::models
