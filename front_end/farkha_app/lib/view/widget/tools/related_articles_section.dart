import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/colors.dart';

class RelatedArticlesSection extends StatelessWidget {
  final List<int>? relatedArticleIds;

  const RelatedArticlesSection({
    super.key,
    this.relatedArticleIds,
  });

  // Map يربط ID المقال بعنوانه
  static const Map<int, String> articleTitles = {
    1: 'اعراض الامراض',
    2: 'اخطاء في التربية',
    3: 'علاج الامراض',
    4: 'الارضية',
    5: 'الرطوبة',
    6: 'الصيف',
    7: 'الشتاء',
    8: 'تجانس الاوزان',
    9: 'الاظلام',
    10: 'الامراض',
    11: 'استقبال الكتاكيت',
    12: 'استهلاك العلف',
    13: 'اوزان',
    14: 'درجات الحرارة',
    15: 'نصائح في التربية',
    16: 'سلالات الفراخ البيضاء',
    17: 'التحصينات',
    18: 'تطهير العنبر',
    19: 'معدل التحويل الغذائي',
    20: 'الكفاءة الانتاجية',
  };

  @override
  Widget build(BuildContext context) {
    // إذا لم يتم تمرير مقالات أو القائمة فارغة، لا نعرض شيء
    if (relatedArticleIds == null || relatedArticleIds!.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            'مقالات ذات صلة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...relatedArticleIds!.map((articleId) {
          final title = articleTitles[articleId];
          if (title == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              color:
                  isDark
                      ? AppColors.darkSurfaceElevatedColor
                      : AppColors.lightSurfaceColor,
              elevation: isDark ? 0 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color:
                      isDark
                          ? AppColors.darkOutlineColor.withValues(alpha: 0.5)
                          : AppColors.lightOutlineColor.withValues(alpha: 0.3),
                ),
              ),
              child: InkWell(
                onTap: () {
                  Get.toNamed<void>(
                    AppRoute.articleDetail,
                    arguments: {
                      'id': articleId.toString(),
                      'title': title,
                    },
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 24,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
