-- MathLab Database Seed Data
-- Initial data for lessons, problems, and achievements

-- ==================== LESSONS ====================
INSERT INTO lessons (id, title, description, category, difficulty, order_index, icon, xp_reward) VALUES
('lesson001', '기초 산술 연습', '덧셈, 뺄셈, 곱셈, 나눗셈의 기초를 배웁니다', '기초 산술', 1, 1, '🔢', 50),
('lesson002', '분수의 이해', '분수의 개념과 사칙연산을 학습합니다', '기초 산술', 2, 2, '🍰', 75),
('lesson003', '일차방정식', '일차방정식의 풀이법을 익힙니다', '대수', 3, 3, '📐', 100),
('lesson004', '도형과 넓이', '다양한 도형의 넓이를 구하는 방법을 배웁니다', '기하', 2, 4, '🔷', 75),
('lesson005', '평균과 확률', '통계의 기초인 평균과 확률을 학습합니다', '통계', 3, 5, '📊', 100);

-- ==================== PROBLEMS ====================
INSERT INTO problems (id, lesson_id, category, difficulty, question, type, options, correct_answer_index, correct_answer, explanation, hints, tags, xp_reward) VALUES
(
    'prob_001',
    'lesson001',
    '덧셈',
    1,
    '3 + 5 = ?',
    'multiple_choice',
    '["6", "7", "8", "9"]',
    2,
    '8',
    '3과 5를 더하면 8입니다.',
    '["손가락을 사용해서 세어보세요!"]',
    '["기초", "덧셈"]',
    5
),
(
    'prob_002',
    'lesson001',
    '뺄셈',
    1,
    '10 - 4 = ?',
    'multiple_choice',
    '["4", "5", "6", "7"]',
    2,
    '6',
    '10에서 4를 빼면 6입니다.',
    '["10개 중에서 4개를 빼면 몇 개가 남을까요?"]',
    '["기초", "뺄셈"]',
    5
),
(
    'prob_003',
    'lesson001',
    '곱셈',
    2,
    '7 × 3 = ?',
    'multiple_choice',
    '["18", "21", "24", "27"]',
    1,
    '21',
    '7을 3번 더하면 21입니다. (7 + 7 + 7 = 21)',
    '["7 + 7 + 7은 얼마일까요?"]',
    '["중급", "곱셈"]',
    10
),
(
    'prob_004',
    'lesson001',
    '나눗셈',
    2,
    '15 ÷ 3 = ?',
    'multiple_choice',
    '["3", "4", "5", "6"]',
    2,
    '5',
    '15를 3으로 나누면 5입니다.',
    '["15개를 3명이 나누어 가지면 한 명당 몇 개씩 가질까요?"]',
    '["중급", "나눗셈"]',
    10
),
(
    'prob_005',
    'lesson002',
    '분수',
    3,
    '1/2 + 1/4 = ?',
    'multiple_choice',
    '["1/6", "2/6", "3/4", "1/3"]',
    2,
    '3/4',
    '1/2는 2/4와 같으므로, 2/4 + 1/4 = 3/4입니다.',
    '["분모를 같게 만들어보세요!"]',
    '["고급", "분수"]',
    15
);

-- ==================== ACHIEVEMENTS ====================
INSERT INTO achievements (id, title, description, icon, category, requirement_type, requirement_value, xp_reward) VALUES
('ach_first_problem', '첫 걸음', '첫 번째 문제를 풀었습니다!', '🎯', 'problem_solving', 'problem_count', 1, 10),
('ach_10_problems', '열심히 공부', '10개의 문제를 풀었습니다', '📚', 'problem_solving', 'problem_count', 10, 50),
('ach_50_problems', '수학 마스터', '50개의 문제를 풀었습니다', '🏆', 'problem_solving', 'problem_count', 50, 200),
('ach_3_day_streak', '3일 연속 학습', '3일 연속으로 학습했습니다', '🔥', 'streak', 'streak_days', 3, 30),
('ach_7_day_streak', '일주일 연속', '7일 연속으로 학습했습니다', '⭐', 'streak', 'streak_days', 7, 100),
('ach_30_day_streak', '한 달 연속', '30일 연속으로 학습했습니다', '👑', 'streak', 'streak_days', 30, 500),
('ach_100_xp', 'XP 수집가', '100 XP를 획득했습니다', '💎', 'xp', 'total_xp', 100, 20),
('ach_500_xp', 'XP 마스터', '500 XP를 획득했습니다', '💰', 'xp', 'total_xp', 500, 100),
('ach_perfect_lesson', '완벽한 레슨', '레슨을 실수 없이 완료했습니다', '✨', 'perfect', 'perfect_lesson_count', 1, 50),
('ach_speed_demon', '스피드 마스터', '문제를 10초 이내에 풀었습니다', '⚡', 'speed', 'fast_solve_count', 1, 30),
('ach_lesson_complete', '레슨 완료', '첫 번째 레슨을 완료했습니다', '📖', 'lesson', 'lesson_count', 1, 50),
('ach_5_lessons', '열정적인 학습자', '5개의 레슨을 완료했습니다', '🎓', 'lesson', 'lesson_count', 5, 250),
('ach_all_correct_day', '완벽한 하루', '하루 동안 모든 문제를 맞췄습니다', '🌟', 'accuracy', 'perfect_day_count', 1, 100),
('ach_no_hints', '독학 마스터', '힌트 없이 10문제를 풀었습니다', '🧠', 'independent', 'no_hint_count', 10, 150),
('ach_comeback', '재도전 정신', '틀린 문제를 다시 풀어 맞췄습니다', '💪', 'retry', 'retry_success_count', 1, 20),
('ach_early_bird', '아침형 인간', '오전 6-9시에 학습했습니다', '🌅', 'timing', 'morning_study_count', 1, 25),
('ach_night_owl', '올빼미 학습자', '오후 9-12시에 학습했습니다', '🦉', 'timing', 'night_study_count', 1, 25),
('ach_weekend_warrior', '주말 학습자', '주말에 학습했습니다', '🏖️', 'timing', 'weekend_study_count', 1, 30),
('ach_daily_challenge', '챌린저', '일일 챌린지를 완료했습니다', '🎯', 'challenge', 'daily_challenge_count', 1, 40),
('ach_10_daily_challenges', '챌린지 마스터', '일일 챌린지를 10번 완료했습니다', '🏅', 'challenge', 'daily_challenge_count', 10, 200);

-- ==================== DEFAULT DAILY CHALLENGE (Today) ====================
INSERT INTO daily_challenges (challenge_date, problem_ids, xp_bonus) VALUES
(CURRENT_DATE, '["prob_001", "prob_002", "prob_003"]', 20);

-- Success message
SELECT 'Database seeded successfully!' AS message;
