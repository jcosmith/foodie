import 'package:flutter/material.dart';

import '../domain/freezer_template.dart';
import '../l10n/generated/storage_layout_localizations.dart';
import 'layout_localization.dart';

/// The freezer templates as radio buttons; used when adding a freezer and
/// during onboarding.
class FreezerTemplateChoiceList extends StatelessWidget {
  const FreezerTemplateChoiceList({
    required this.selectedTemplate,
    required this.onTemplateSelected,
    super.key,
  });

  final FreezerTemplate selectedTemplate;
  final ValueChanged<FreezerTemplate> onTemplateSelected;

  @override
  Widget build(BuildContext context) {
    final localizations = StorageLayoutLocalizations.of(context);
    return RadioGroup<FreezerTemplate>(
      groupValue: selectedTemplate,
      onChanged: (template) {
        if (template != null) onTemplateSelected(template);
      },
      child: Column(
        children: [
          for (final template in FreezerTemplate.values)
            RadioListTile<FreezerTemplate>(
              value: template,
              title: Text(localizations.templateName(template)),
            ),
        ],
      ),
    );
  }
}
