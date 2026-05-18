import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sika_customer/l10n/app_localizations.dart';
import '../../../../core/constants/app_pallete.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value.trim();
    });
  }

  List<Map<String, Object>> _faqSections(AppLocalizations l10n) {
    return [
      {
        'title': l10n.faqPoliciesTitle,
        'questions': [
          l10n.faqCancellationRefundPolicy,
          l10n.faqBecomeShopper,
          l10n.faqJoinPartnerStore,
          l10n.faqDataUsage,
          l10n.faqTermsConditions,
        ],
      },
      {
        'title': l10n.faqGeneralTitle,
        'questions': [
          l10n.faqWhenAvailable,
          l10n.faqWhatIsSika,
          l10n.faqProductsDeliver,
          l10n.faqWhereAvailable,
        ],
      },
      {
        'title': l10n.faqOrdersTitle,
        'questions': [
          l10n.faqDeliveryTime,
          l10n.faqEditCancelOrder,
          l10n.faqPaymentMethods,
          l10n.faqTrackDriver,
        ],
      },
    ];
  }

  List<Map<String, Object>> _filteredSections(AppLocalizations l10n) {
    final baseSections = _faqSections(l10n);
    if (_query.isEmpty) return baseSections;

    final lowerQuery = _query.toLowerCase();
    final filtered = <Map<String, Object>>[];

    for (final section in baseSections) {
      final questions = (section['questions'] as List<String>)
          .where((question) => question.toLowerCase().contains(lowerQuery))
          .toList();
      if (questions.isNotEmpty) {
        filtered
            .add({'title': section['title'] as String, 'questions': questions});
      }
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sections = _filteredSections(l10n);

    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, l10n),
            _buildSearchField(l10n),
            Expanded(
              child: sections.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.faqNoResults,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(top: 24),
                      itemCount: sections.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 32),
                      itemBuilder: (context, sectionIndex) {
                        final section = sections[sectionIndex];
                        final questions = section['questions'] as List<String>;
                        return _FaqSection(
                          title: section['title'] as String,
                          items: questions,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.faqTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: l10n.faqSearchHint,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _FaqSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((question) => _buildQuestionTile(question)).toList(),
        ],
      ),
    );
  }

  Widget _buildQuestionTile(String question) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            // TODO: wire navigation to answer screen when available.
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: Colors.grey[300]),
      ],
    );
  }
}
