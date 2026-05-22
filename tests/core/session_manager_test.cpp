#include <torrex/session_manager.hpp>

#include <gtest/gtest.h>

TEST(SessionManager, StartShutdown) {
    torrex::SessionManager session;
    EXPECT_FALSE(session.is_running());
    session.start();
    EXPECT_TRUE(session.is_running());
    session.shutdown();
    EXPECT_FALSE(session.is_running());
}

TEST(SessionManager, DoubleStartIsIdempotent) {
    torrex::SessionManager session;
    session.start();
    session.start();
    EXPECT_TRUE(session.is_running());
    session.shutdown();
}
