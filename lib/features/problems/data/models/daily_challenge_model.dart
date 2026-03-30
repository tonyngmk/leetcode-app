import 'problem_model.dart';

class DailyChallenge {
  final String date;
  final String link;
  final Problem question;

  const DailyChallenge({
    required this.date,
    required this.link,
    required this.question,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    final data = json['activeDailyCodingChallengeQuestion'] as Map<String, dynamic>;
    return DailyChallenge(
      date: data['date'] as String,
      link: data['link'] as String,
      question: Problem.fromJson(data['question'] as Map<String, dynamic>),
    );
  }
}
