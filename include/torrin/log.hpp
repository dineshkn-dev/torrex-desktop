#pragma once

#include <chrono>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>

namespace torrin::log {

inline bool enabled()
{
    static const bool on = [] {
        const char* env = std::getenv("TORRIN_LOG");
        return env != nullptr && env[0] != '\0' && env[0] != '0';
    }();
    return on;
}

inline void write(const char* level, const char* component, const std::string& message)
{
    if (!enabled()) {
        return;
    }

    const auto now = std::chrono::system_clock::now();
    const auto ms =
        std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()) % 1000;

    std::time_t tt = std::chrono::system_clock::to_time_t(now);
    std::tm local_tm{};
#if defined(_WIN32)
    localtime_s(&local_tm, &tt);
#else
    localtime_r(&tt, &local_tm);
#endif

    std::cerr << std::put_time(&local_tm, "%H:%M:%S") << '.' << std::setw(3) << std::setfill('0')
              << ms.count() << " [" << level << "] torrin." << component << ": " << message
              << std::endl;
}

inline void info(const char* component, const std::string& message)
{
    write("INFO", component, message);
}

inline void warn(const char* component, const std::string& message)
{
    write("WARN", component, message);
}

inline void error(const char* component, const std::string& message)
{
    write("ERROR", component, message);
}

} // namespace torrin::log
