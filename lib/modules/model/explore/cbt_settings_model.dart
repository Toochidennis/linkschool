class CbtSettingsModel {
  final int challengeDurationLimit;
  final int maxExamsPerChallenge;
  final int minQuestionsPerExam;
  final int passingScorePercentage;
  final bool leaderboardEnabled;
  final bool notificationEmails;
  final int amount;
  final double discountRate;
  final int freeTrialDays;

  CbtSettingsModel({
    required this.challengeDurationLimit,
    required this.maxExamsPerChallenge,
    required this.minQuestionsPerExam,
    required this.passingScorePercentage,
    required this.leaderboardEnabled,
    required this.notificationEmails,
    required this.amount,
    required this.discountRate,
    required this.freeTrialDays,
  });

  factory CbtSettingsModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"] ?? {};

    return CbtSettingsModel(
      challengeDurationLimit: data["challenge_duration_limit"],
      maxExamsPerChallenge: data["max_exams_per_challenge"],
      minQuestionsPerExam: data["min_questions_per_exam"],
      passingScorePercentage: data["passing_score_percentage"],
      leaderboardEnabled: data["leaderboard_enabled"],
      notificationEmails: data["notification_emails"],
      amount: data["amount"],
      discountRate: (data["discount_rate"] as num).toDouble(),
      freeTrialDays: data["free_trial_days"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "challenge_duration_limit": challengeDurationLimit,
      "max_exams_per_challenge": maxExamsPerChallenge,
      "min_questions_per_exam": minQuestionsPerExam,
      "passing_score_percentage": passingScorePercentage,
      "leaderboard_enabled": leaderboardEnabled,
      "notification_emails": notificationEmails,
      "amount": amount,
      "discount_rate": discountRate,
      "free_trial_days": freeTrialDays,
    };
  }
}
