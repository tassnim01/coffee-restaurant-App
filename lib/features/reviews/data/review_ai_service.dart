import 'package:dio/dio.dart';

import '../models/product_review.dart';

class ReviewAiInsight {
  final String summary;
  final List<String> strengths;
  final List<String> issues;
  final List<String> recommendations;

  const ReviewAiInsight({
    required this.summary,
    required this.strengths,
    required this.issues,
    required this.recommendations,
  });

  factory ReviewAiInsight.fromMap(Map<String, dynamic> map) => ReviewAiInsight(
    summary: map['summary'] as String? ?? '',
    strengths: (map['strengths'] as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .toList(),
    issues: (map['issues'] as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .toList(),
    recommendations: (map['recommendations'] as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .toList(),
  );
}

class ReviewAiService {
  final Dio _dio;
  final String endpoint;

  ReviewAiService({Dio? dio})
    : _dio = dio ?? Dio(),
      endpoint = const String.fromEnvironment('AI_INSIGHTS_URL');

  Future<ReviewAiInsight> analyze(List<ProductReview> reviews) async {
    if (endpoint.isEmpty) {
      return _analyzeLocally(reviews);
    }

    final response = await _dio.post<Map<String, dynamic>>(
      endpoint,
      data: {
        'reviews': reviews
            .map(
              (review) => {
                'productId': review.productId,
                'rating': review.rating,
                'comment': review.comment,
              },
            )
            .toList(),
      },
    );
    if (response.data == null) {
      throw StateError('La réponse IA est vide.');
    }
    return ReviewAiInsight.fromMap(response.data!);
  }

  ReviewAiInsight _analyzeLocally(List<ProductReview> reviews) {
    final average =
        reviews.fold<int>(0, (sum, review) => sum + review.rating) /
        reviews.length;

    final text = reviews
        .map((review) => review.comment.toLowerCase())
        .where((comment) => comment.isNotEmpty)
        .join(' ');

    final strengths = <String>[];
    final issues = <String>[];
    final recommendations = <String>[];

    if (average >= 4.5) {
      strengths.add('Les clients donnent une excellente note générale.');
    } else if (average >= 4) {
      strengths.add('La satisfaction globale des clients est positive.');
    } else if (average < 3) {
      issues.add('La note moyenne est faible.');
    }

    final positiveWords = [
      'excellent',
      'délicieux',
      'bon',
      'bonne',
      'savoureux',
      'recommande',
      'rapide',
    ];
    final positiveMatches = positiveWords.where(text.contains).toList();
    if (positiveMatches.isNotEmpty) {
      strengths.add(
        'Les avis citent souvent des qualités positives '
        '(goût, qualité ou service).',
      );
    }

    final negativeWords = [
      'froid',
      'attente',
      'long',
      'cher',
      'dur',
      'déçu',
      'déception',
      'salé',
      'fade',
    ];
    final negativeMatches = negativeWords.where(text.contains).toList();
    if (negativeMatches.isNotEmpty) {
      issues.add(
        'Plusieurs avis signalent des problèmes récurrents '
        'à vérifier (température, attente, prix ou goût).',
      );
    }

    if (average < 4) {
      recommendations.add(
        'Relancer les clients ayant donné une note faible pour recueillir '
        'des informations précises.',
      );
      recommendations.add(
        'Préparer un plan d’amélioration pour les plats les moins bien notés.',
      );
    } else {
      recommendations.add(
        'Mettre en avant les plats les mieux notés dans les promotions.',
      );
    }

    if (negativeMatches.isNotEmpty) {
      recommendations.add(
        'Analyser les commentaires concernés et former l’équipe sur '
        'les points remontés.',
      );
    }

    return ReviewAiInsight(
      summary:
          '${reviews.length} avis analysés, avec une note moyenne de '
          '${average.toStringAsFixed(1)} sur 5.',
      strengths: strengths.isEmpty
          ? const [
              'Pas assez de commentaires positifs pour dégager une tendance.',
            ]
          : strengths,
      issues: issues.isEmpty
          ? const ['Aucun problème récurrent détecté dans les commentaires.']
          : issues,
      recommendations: recommendations,
    );
  }
}
