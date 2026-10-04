import 'package:flutter/material.dart';

import '../domain/storage_template.dart';
import 'layout_localization.dart';

/// Storage place templates as radio buttons; used when adding a storage place
/// and during onboarding.
class StorageTemplateChoiceList extends StatelessWidget {
  const StorageTemplateChoiceList({
    required this.templates,
    required this.selectedTemplate,
    required this.onTemplateSelected,
    super.key,
  });

  /// Usually the templates of one domain, from `storageTemplatesOfDomainProvider`.
  final List<StorageTemplate> templates;
  final StorageTemplate? selectedTemplate;
  final ValueChanged<StorageTemplate> onTemplateSelected;

  @override
  Widget build(BuildContext context) => RadioGroup<StorageTemplate>(
    groupValue: selectedTemplate,
    onChanged: (template) {
      if (template != null) onTemplateSelected(template);
    },
    child: Column(
      children: [
        for (final template in templates)
          RadioListTile<StorageTemplate>(
            value: template,
            title: Text(context.storageTemplateLabelOf(template)),
          ),
      ],
    ),
  );
}
