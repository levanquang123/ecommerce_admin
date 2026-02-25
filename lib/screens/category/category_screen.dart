import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../utility/constants.dart';
import 'components/add_category_form.dart';
import 'components/category_header.dart';
import 'components/category_list_section.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CategoryHeader(),
            const SizedBox(height: defaultPadding),

            /// Title + Action buttons
            Row(
              children: [
                Expanded(
                  child: Text(
                    "My Categories",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),

                /// Add button
                ElevatedButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding * 1.5,
                      vertical: defaultPadding,
                    ),
                  ),
                  onPressed: () {
                    showAddCategoryForm(context, null);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add New"),
                ),

                const Gap(20),

                /// Refresh button
                IconButton(
                  onPressed: () {
                    // TODO: implement getAllCategory
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),

            const Gap(defaultPadding),

            /// Category list
            const CategoryListSection(),
          ],
        ),
      ),
    );
  }
}
