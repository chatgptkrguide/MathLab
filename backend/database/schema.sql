-- MathLab Database Schema
-- PostgreSQL 14+

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==================== USERS TABLE ====================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255),  -- NULL for social login

    -- Authentication
    auth_provider VARCHAR(50) NOT NULL DEFAULT 'email',  -- 'email', 'google', 'kakao', 'apple'
    auth_provider_id VARCHAR(255),  -- Social provider's user ID

    -- Game Data
    level INTEGER DEFAULT 1 CHECK (level >= 1),
    xp INTEGER DEFAULT 0 CHECK (xp >= 0),
    streak_days INTEGER DEFAULT 0 CHECK (streak_days >= 0),
    hearts INTEGER DEFAULT 5 CHECK (hearts >= 0 AND hearts <= 5),
    current_grade VARCHAR(20) DEFAULT '중1',  -- '중1', '중2', '중3', '고1', '고2', '고3'

    -- Profile
    avatar_url TEXT,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    last_streak_date DATE,  -- For streak tracking
    is_active BOOLEAN DEFAULT TRUE,

    -- Constraints
    CONSTRAINT valid_auth_provider CHECK (auth_provider IN ('email', 'google', 'kakao', 'apple')),
    CONSTRAINT valid_grade CHECK (current_grade IN ('중1', '중2', '중3', '고1', '고2', '고3'))
);

-- Indexes for users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_auth ON users(auth_provider, auth_provider_id);
CREATE INDEX idx_users_created ON users(created_at DESC);

-- ==================== LESSONS TABLE ====================
CREATE TABLE lessons (
    id VARCHAR(50) PRIMARY KEY,  -- 'lesson001', 'lesson002'
    title VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,  -- '기초 산술', '대수', '기하', '통계'
    difficulty INTEGER DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 5),
    order_index INTEGER NOT NULL UNIQUE,
    icon TEXT,  -- Emoji or icon URL
    xp_reward INTEGER DEFAULT 50 CHECK (xp_reward >= 0),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_lessons_category ON lessons(category);
CREATE INDEX idx_lessons_order ON lessons(order_index);

-- ==================== USER LESSON PROGRESS TABLE ====================
CREATE TABLE user_lesson_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id VARCHAR(50) NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,

    is_unlocked BOOLEAN DEFAULT FALSE,
    is_completed BOOLEAN DEFAULT FALSE,
    progress_percent INTEGER DEFAULT 0 CHECK (progress_percent BETWEEN 0 AND 100),
    problems_completed INTEGER DEFAULT 0,
    problems_total INTEGER DEFAULT 0,

    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(user_id, lesson_id)
);

CREATE INDEX idx_user_lesson_progress_user ON user_lesson_progress(user_id);
CREATE INDEX idx_user_lesson_progress_status ON user_lesson_progress(user_id, is_completed);

-- ==================== PROBLEMS TABLE ====================
CREATE TABLE problems (
    id VARCHAR(50) PRIMARY KEY,  -- 'prob_001'
    lesson_id VARCHAR(50) REFERENCES lessons(id) ON DELETE CASCADE,

    category VARCHAR(100) NOT NULL,
    difficulty INTEGER DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 5),
    question TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,  -- 'multiple_choice', 'drag_drop', 'text_input'
    options JSONB,  -- Array of options for multiple choice
    correct_answer_index INTEGER,
    correct_answer TEXT NOT NULL,
    explanation TEXT,
    hints JSONB,  -- Array of hints
    tags JSONB,  -- Array of tags
    xp_reward INTEGER DEFAULT 5 CHECK (xp_reward >= 0),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT valid_problem_type CHECK (type IN ('multiple_choice', 'drag_drop', 'text_input'))
);

CREATE INDEX idx_problems_lesson ON problems(lesson_id);
CREATE INDEX idx_problems_category ON problems(category);
CREATE INDEX idx_problems_difficulty ON problems(difficulty);

-- ==================== USER PROBLEM RESULTS TABLE ====================
CREATE TABLE user_problem_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    problem_id VARCHAR(50) NOT NULL REFERENCES problems(id) ON DELETE CASCADE,

    is_correct BOOLEAN NOT NULL,
    user_answer TEXT,
    time_spent_seconds INTEGER CHECK (time_spent_seconds >= 0),
    hints_used INTEGER DEFAULT 0 CHECK (hints_used >= 0),
    xp_earned INTEGER DEFAULT 0,

    solved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_problem_results_user ON user_problem_results(user_id);
CREATE INDEX idx_user_problem_results_problem ON user_problem_results(problem_id);
CREATE INDEX idx_user_problem_results_solved ON user_problem_results(solved_at DESC);
CREATE INDEX idx_user_problem_results_correct ON user_problem_results(user_id, is_correct);

-- ==================== ACHIEVEMENTS TABLE ====================
CREATE TABLE achievements (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    icon TEXT,
    category VARCHAR(100),  -- 'problem_solving', 'streak', 'xp', 'speed'
    requirement_type VARCHAR(50) NOT NULL,  -- 'problem_count', 'streak_days', 'total_xp'
    requirement_value INTEGER NOT NULL,
    xp_reward INTEGER DEFAULT 0 CHECK (xp_reward >= 0),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_achievements_category ON achievements(category);

-- ==================== USER ACHIEVEMENTS TABLE ====================
CREATE TABLE user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id VARCHAR(50) NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,

    unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(user_id, achievement_id)
);

CREATE INDEX idx_user_achievements_user ON user_achievements(user_id);
CREATE INDEX idx_user_achievements_unlocked ON user_achievements(unlocked_at DESC);

-- ==================== LEADERBOARD TABLE ====================
CREATE TABLE leaderboard (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    league VARCHAR(50) DEFAULT 'bronze',  -- 'bronze', 'silver', 'gold', 'diamond'
    weekly_xp INTEGER DEFAULT 0 CHECK (weekly_xp >= 0),
    rank_position INTEGER,

    week_start DATE NOT NULL,  -- Monday of the week
    week_end DATE NOT NULL,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(user_id, week_start),
    CONSTRAINT valid_league CHECK (league IN ('bronze', 'silver', 'gold', 'diamond'))
);

CREATE INDEX idx_leaderboard_league_rank ON leaderboard(league, rank_position);
CREATE INDEX idx_leaderboard_week ON leaderboard(week_start);
CREATE INDEX idx_leaderboard_user_week ON leaderboard(user_id, week_start);

-- ==================== SESSIONS TABLE ====================
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,  -- Hashed refresh token
    device_info JSONB,  -- {device_type, os, app_version}

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    last_used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_sessions_user ON sessions(user_id);
CREATE INDEX idx_sessions_token ON sessions(token_hash);
CREATE INDEX idx_sessions_expires ON sessions(expires_at);

-- ==================== DAILY CHALLENGES TABLE ====================
CREATE TABLE daily_challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenge_date DATE NOT NULL UNIQUE,

    problem_ids JSONB NOT NULL,  -- Array of problem IDs
    xp_bonus INTEGER DEFAULT 20,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_daily_challenges_date ON daily_challenges(challenge_date DESC);

-- ==================== USER DAILY CHALLENGE RESULTS TABLE ====================
CREATE TABLE user_daily_challenge_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    challenge_id UUID NOT NULL REFERENCES daily_challenges(id) ON DELETE CASCADE,

    is_completed BOOLEAN DEFAULT FALSE,
    problems_solved INTEGER DEFAULT 0,
    xp_earned INTEGER DEFAULT 0,

    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,

    UNIQUE(user_id, challenge_id)
);

CREATE INDEX idx_user_daily_challenges_user ON user_daily_challenge_results(user_id);
CREATE INDEX idx_user_daily_challenges_completed ON user_daily_challenge_results(completed_at DESC);

-- ==================== TRIGGERS ====================

-- Trigger to update updated_at on users table
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_lesson_progress_updated_at BEFORE UPDATE ON user_lesson_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_leaderboard_updated_at BEFORE UPDATE ON leaderboard
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==================== VIEWS ====================

-- View for user stats summary
CREATE VIEW user_stats AS
SELECT
    u.id AS user_id,
    u.display_name,
    u.level,
    u.xp,
    u.streak_days,
    u.hearts,
    COUNT(DISTINCT ulp.lesson_id) FILTER (WHERE ulp.is_completed = TRUE) AS lessons_completed,
    COUNT(DISTINCT upr.problem_id) AS problems_attempted,
    COUNT(DISTINCT upr.problem_id) FILTER (WHERE upr.is_correct = TRUE) AS problems_correct,
    COUNT(DISTINCT ua.achievement_id) AS achievements_unlocked,
    ROUND(
        COUNT(DISTINCT upr.problem_id) FILTER (WHERE upr.is_correct = TRUE)::numeric /
        NULLIF(COUNT(DISTINCT upr.problem_id), 0) * 100,
        2
    ) AS accuracy_percent
FROM users u
LEFT JOIN user_lesson_progress ulp ON u.id = ulp.user_id
LEFT JOIN user_problem_results upr ON u.id = upr.user_id
LEFT JOIN user_achievements ua ON u.id = ua.user_id
GROUP BY u.id, u.display_name, u.level, u.xp, u.streak_days, u.hearts;

-- View for weekly leaderboard
CREATE VIEW weekly_leaderboard AS
SELECT
    l.id,
    l.user_id,
    u.display_name,
    u.avatar_url,
    l.league,
    l.weekly_xp,
    l.rank_position,
    l.week_start,
    l.week_end
FROM leaderboard l
JOIN users u ON l.user_id = u.id
WHERE l.week_start = DATE_TRUNC('week', CURRENT_DATE)::DATE
ORDER BY l.league, l.rank_position;

-- ==================== COMMENTS ====================

COMMENT ON TABLE users IS '사용자 기본 정보 및 게임 데이터';
COMMENT ON TABLE lessons IS '레슨 마스터 데이터';
COMMENT ON TABLE user_lesson_progress IS '사용자별 레슨 진행도';
COMMENT ON TABLE problems IS '문제 마스터 데이터';
COMMENT ON TABLE user_problem_results IS '사용자 문제 풀이 기록';
COMMENT ON TABLE achievements IS '업적 마스터 데이터';
COMMENT ON TABLE user_achievements IS '사용자 업적 달성 기록';
COMMENT ON TABLE leaderboard IS '주간 리더보드';
COMMENT ON TABLE sessions IS 'JWT 세션 관리';
COMMENT ON TABLE daily_challenges IS '일일 챌린지';
COMMENT ON TABLE user_daily_challenge_results IS '사용자 일일 챌린지 결과';
