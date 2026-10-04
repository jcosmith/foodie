import 'package:flutter/material.dart';

import '../domain/storage_template.dart';
import '../l10n/generated/storage_layout_localizations.dart';
import 'layout_localization.dart';

/// The storage place templates as radio buttons; used when adding a storage place and
/// during onboarding.
class StorageTemplateChoiceList extends StatelessWidget {
  const StorageTemplateChoiceList({
    required this.selectedTemplate,
    required this.onTemplateSelected,
    super.key,
  });

  final StorageTemplate selectedTemplate;
  final ValueChanged<StorageTemplate> onTemplateSelected;

  @override
  Widget build(BuildContext context) {
    final localizations = StorageLayoutLocalizations.of(context);
    return RadioGroup<StorageTemplate>(
      groupValue: selectedTemplate,
      onChanged: (template) {
        if (template != null) onTemplateSelected(template);
      },
      child: Column(
        children: [
          for (final template in StorageTemplate.values)
            RadioListTile<StorageTemplate>(
              value: template,
              title: Text(localizations.templateName(template)),
            ),
        ],
      ),
    );
  }
}
