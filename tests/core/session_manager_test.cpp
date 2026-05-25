#include <torrin/session_manager.hpp>

#include <gtest/gtest.h>

TEST(SessionManager, StartShutdown) {
    torrin::SessionManager session;
    EXPECT_FALSE(session.is_running());
    session.start();
    EXPECT_TRUE(session.is_running());
    session.shutdown();
    EXPECT_FALSE(session.is_running());
}

TEST(SessionManager, DoubleStartIsIdempotent) {
    torrin::SessionManager session;
    session.start();
    session.start();
    EXPECT_TRUE(session.is_running());
    session.shutdown();
}
