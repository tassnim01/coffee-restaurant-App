import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../reviews/data/review_ai_service.dart';
import '../../../reviews/providers/reviews_provider.dart';

class AiReviewInsightsCard extends StatefulWidget {
  const AiReviewInsightsCard({super.key});

  @override
  State<AiReviewInsightsCard> createState() => _AiReviewInsightsCardState();
}

class _AiReviewInsightsCardState extends State<AiReviewInsightsCard> {
  ReviewAiInsight? _insight;
  bool _isAnalyzing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewsProvider>().loadAllReviews();
    });
  }

  Future<void> _analyze() async {
    final reviewsProvider = context.read<ReviewsProvider>();
    if (reviewsProvider.allReviews.isEmpty) {
      setState(() => _error = 'Aucun avis disponible pour analyse.');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });
    try {
      final insight = await ReviewAiService().analyze(
        reviewsProvider.allReviews,
      );
      if (!mounted) return;
      setState(() {
        _insight = insight;
        _isAnalyzing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('StateError:', '').trim();
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviews = context.watch<ReviewsProvider>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.forestGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Analyse IA des avis',
                  style: AppTextStyles.productName,
                ),
              ),
              Text(
                '${reviews.allReviews.length} avis',
                style: AppTextStyles.chip.copyWith(color: AppColors.gray),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (reviews.isLoadingAll)
            const LinearProgressIndicator()
          else ...[
            if (_insight == null)
              Text(
                'Demandez à l’agent IA d’analyser les avis clients et '
                'de proposer des recommandations au responsable.',
                style: AppTextStyles.body.copyWith(color: AppColors.gray),
              ),
            if (_insight != null) _insightContent(_insight!),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: AppTextStyles.body.copyWith(color: AppColors.burgundy),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _isAnalyzing ? null : _analyze,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                ),
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(
                  _insight == null ? 'Analyser les avis' : 'Réanalyser',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _insightContent(ReviewAiInsight insight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (insight.summary.isNotEmpty) ...[
          Text('Synthèse', style: AppTextStyles.productName),
          const SizedBox(height: 4),
          Text(insight.summary, style: AppTextStyles.body),
          const SizedBox(height: 12),
        ],
        _bulletSection('Points forts', insight.strengths),
        _bulletSection('Points à améliorer', insight.issues),
        _bulletSection('Recommandations', insight.recommendations),
      ],
    );
  }

  Widget _bulletSection(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.productName),
          const SizedBox(height: 4),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(child: Text(item, style: AppTextStyles.body)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
