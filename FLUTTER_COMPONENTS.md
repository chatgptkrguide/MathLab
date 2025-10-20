# MathLab Flutter 컴포넌트 구현 가이드

실제 스크린샷 기반 Flutter 위젯 구현 예시

## 🏠 홈 화면 컴포넌트

### 1. 상단 헤더 위젯
```dart
class HomeHeaderWidget extends StatelessWidget {
  final String userName;
  final int streakDays;

  const HomeHeaderWidget({
    Key? key,
    required this.userName,
    required this.streakDays,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '안녕하세요, $userName!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202124),
                ),
              ),
              Text(
                '중1 수학을 학습하고 있어요',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Color(0xFF5F6368),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFFFF6B35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🔥', style: TextStyle(fontSize: 16)),
                SizedBox(width: 4),
                Text(
                  '${streakDays}일',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2. 통계 카드 그리드
```dart
class StatsGridWidget extends StatelessWidget {
  final int xp;
  final int level;
  final int streakDays;

  const StatsGridWidget({
    Key? key,
    required this.xp,
    required this.level,
    required this.streakDays,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('⚡', 'XP', xp.toString())),
          SizedBox(width: 8),
          Expanded(child: _buildStatCard('⭐', '레벨', level.toString())),
          SizedBox(width: 8),
          Expanded(child: _buildStatCard('🎯', '연속', '${streakDays}일')),
        ],
      ),
    );
  }

  Widget _buildStatCard(String icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: TextStyle(fontSize: 24)),
          SizedBox(height: 4),
          Text(label, style: TextStyle(
            fontSize: 12,
            color: Color(0xFF5F6368),
          )),
          Text(value, style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF202124),
          )),
        ],
      ),
    );
  }
}
```

### 3. 진행률 카드
```dart
class ProgressCardWidget extends StatelessWidget {
  final String title;
  final int currentXP;
  final int targetXP;

  const ProgressCardWidget({
    Key? key,
    required this.title,
    required this.currentXP,
    required this.targetXP,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = currentXP / targetXP;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF202124),
              )),
              Text('$currentXP/$targetXP XP', style: TextStyle(
                color: Color(0xFF4285F4),
                fontWeight: FontWeight.w500,
              )),
            ],
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Color(0xFFDADCE0),
            valueColor: AlwaysStoppedAnimation(Color(0xFF4285F4)),
            borderRadius: BorderRadius.circular(4),
            minHeight: 8,
          ),
          SizedBox(height: 8),
          Text(
            '목표까지 ${targetXP - currentXP} XP 남았습니다!',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF5F6368),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 4. 주요 액션 버튼
```dart
class PrimaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;

  const PrimaryActionButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4285F4),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          borderRadius: BorderRadius.circular(8),
          elevation: 2,
          disabledBackgroundColor: Color(0xFF9AA0A6),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
```

## 📚 학습 로드맵 컴포넌트

### 1. 탭 네비게이션
```dart
class GradeTabBar extends StatelessWidget {
  final List<String> grades;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const GradeTabBar({
    Key? key,
    required this.grades,
    required this.selectedIndex,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: grades.asMap().entries.map((entry) {
          int index = entry.key;
          String grade = entry.value;
          bool isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  grade,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Color(0xFF4285F4) : Color(0xFF5F6368),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

### 2. 레슨 카드
```dart
class LessonCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final double progress;
  final VoidCallback onTap;

  const LessonCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.progress,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF202124),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5F6368),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '진행률',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5F6368),
                            ),
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4285F4),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Color(0xFFDADCE0),
                        valueColor: AlwaysStoppedAnimation(Color(0xFF4285F4)),
                        borderRadius: BorderRadius.circular(2),
                        minHeight: 4,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Color(0xFF5F6368),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## 📝 오답 노트 컴포넌트

### 1. 통계 카드 그리드 (4열)
```dart
class ErrorStatsGrid extends StatelessWidget {
  final int totalErrors;
  final int unreviewed;
  final int reviewedOnce;
  final int reviewedTwice;

  const ErrorStatsGrid({
    Key? key,
    required this.totalErrors,
    required this.unreviewed,
    required this.reviewedOnce,
    required this.reviewedTwice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('총 오답', totalErrors)),
          SizedBox(width: 8),
          Expanded(child: _buildStatCard('미복습', unreviewed)),
          SizedBox(width: 8),
          Expanded(child: _buildStatCard('1회 복습', reviewedOnce)),
          SizedBox(width: 8),
          Expanded(child: _buildStatCard('2회 이상', reviewedTwice)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF202124),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF5F6368),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

### 2. 빈 상태 위젯
```dart
class EmptyStateWidget extends StatelessWidget {
  final String icon;
  final String title;
  final String message;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: 48),
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF202124),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF5F6368),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

## 👤 프로필 컴포넌트

### 1. 사용자 정보 카드
```dart
class UserProfileCard extends StatelessWidget {
  final String userName;
  final String joinDate;
  final int level;
  final int streakDays;
  final int xp;

  const UserProfileCard({
    Key? key,
    required this.userName,
    required this.joinDate,
    required this.level,
    required this.streakDays,
    required this.xp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF4285F4),
                    child: Text(
                      '학',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF202124),
                        ),
                      ),
                      Text(
                        '$joinDate부터 학습 중',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5F6368),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(
                Icons.settings,
                color: Color(0xFF5F6368),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildQuickStat('🏆', '레벨 $level'),
              SizedBox(width: 16),
              _buildQuickStat('🔥', '${streakDays}일 연속'),
              SizedBox(width: 16),
              _buildQuickStat('⭐', '$xp XP'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: TextStyle(fontSize: 16)),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF5F6368),
          ),
        ),
      ],
    );
  }
}
```

### 2. 업적 그리드
```dart
class AchievementGrid extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementGrid({
    Key? key,
    required this.achievements,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '업적',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF202124),
            ),
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return _buildAchievementCard(achievement);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? Color(0xFFE3F2FD)
            : Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: achievement.isUnlocked
              ? Color(0xFF4285F4)
              : Color(0xFFDADCE0),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            achievement.icon,
            style: TextStyle(
              fontSize: 24,
              color: achievement.isUnlocked
                  ? null
                  : Color(0xFF9AA0A6),
            ),
          ),
          SizedBox(height: 4),
          Text(
            achievement.title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: achievement.isUnlocked
                  ? Color(0xFF202124)
                  : Color(0xFF9AA0A6),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class Achievement {
  final String icon;
  final String title;
  final bool isUnlocked;

  Achievement({
    required this.icon,
    required this.title,
    required this.isUnlocked,
  });
}
```

## 🎯 공통 유틸리티

### 색상 상수
```dart
class AppColors {
  static const Color primaryBlue = Color(0xFF4285F4);
  static const Color secondaryBlue = Color(0xFFE3F2FD);
  static const Color successGreen = Color(0xFF34A853);
  static const Color warningOrange = Color(0xFFFF6B35);
  static const Color errorRed = Color(0xFFEA4335);
  static const Color purpleAccent = Color(0xFF9C27B0);

  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color borderLight = Color(0xFFDADCE0);
  static const Color disabled = Color(0xFF9AA0A6);
}
```

### 텍스트 스타일
```dart
class AppTextStyles {
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    color: AppColors.textSecondary,
  );
}
```

이 컴포넌트들을 조합해서 실제 스크린샷과 동일한 UI를 Flutter로 구현할 수 있습니다!