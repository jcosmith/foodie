import 'package:core_design_system/core_design_system.dart';
import 'package:core_localization/core_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/storage_layout_providers.dart';
import '../domain/layout_name_policy.dart';
import '../domain/storage_template.dart';
import '../l10n/generated/storage_layout_localizations.dart';
import 'layout_localization.dart';
import 'storage_layout_routes.dart';
import 'storage_template_choice_list.dart';

/// Adds a storage place from a template, then opens its editor.
class StorageTemplatePickerScreen extends ConsumerStatefulWidget {
  const StorageTemplatePickerScreen({super.key});

  @override
  ConsumerState<StorageTemplatePickerScreen> createState() => _StorageTemplatePickerScreenState();
}

class _StorageTemplatePickerScreenState extends ConsumerState<StorageTemplatePickerScreen> {
  final TextEditingController _nameController = TextEditingController();
  StorageTemplate _selectedTemplate = StorageTemplate.uprightWithThreeDrawers;
  String? _nameError;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createStoragePlace() async {
    setState(() => _isSaving = true);
    final localizations = StorageLayoutLocalizations.of(context);
    final result = await ref
        .read(createStoragePlaceFromTemplateUseCaseProvider)
        .execute(
          template: _selectedTemplate,
          enteredName: _nameController.text,
          defaultNames: context.layoutDefaultNames,
        );
    if (!mounted) return;
    result.fold(
      onSuccess: (storagePlaceIdentifier) =>
          context.pushReplacement(StorageLayoutRoutes.storagePlaceEditor(storagePlaceIdentifier)),
      onFailure: (failure) => setState(() {
        _isSaving = false;
        _nameError = localizations.describeFailure(failure, isAboutStoragePlace: true);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = StorageLayoutLocalizations.of(context);
    final defaultName = context.layoutDefaultNames.storagePlaceName(_selectedTemplate.storageKind);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.newStoragePlaceTitle)),
      body: ListView(
        padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
        children: [
          Text(localizations.templatePrompt, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: FoodieSpacing.small),
          StorageTemplateChoiceList(
            selectedTemplate: _selectedTemplate,
            onTemplateSelected: (template) => setState(() => _selectedTemplate = template),
          ),
          const SizedBox(height: FoodieSpacing.large),
          TextField(
            controller: _nameController,
            maxLength: LayoutNamePolicy.maximumNameLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: localizations.storagePlaceNameLabel,
              hintText: defaultName,
              helperText: localizations.storagePlaceNameHelper(defaultName),
              helperMaxLines: 2,
              errorText: _nameError,
            ),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: FoodieSpacing.large),
          FilledButton(
            onPressed: _isSaving ? null : _createStoragePlace,
            child: Text(localizations.addStoragePlaceButton),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.commonLocalizations.actionCancel),
          ),
        ],
      ),
    );
  }
}
