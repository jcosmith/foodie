import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
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

/// Adds a storage place to one domain from one of its templates, then opens
/// its editor.
class StorageTemplatePickerScreen extends ConsumerStatefulWidget {
  const StorageTemplatePickerScreen({required this.domainIdentifier, super.key});

  final StorageDomainIdentifier domainIdentifier;

  @override
  ConsumerState<StorageTemplatePickerScreen> createState() => _StorageTemplatePickerScreenState();
}

class _StorageTemplatePickerScreenState extends ConsumerState<StorageTemplatePickerScreen> {
  final TextEditingController _nameController = TextEditingController();
  StorageTemplate? _chosenTemplate;
  String? _nameError;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createStoragePlace(StorageTemplate template) async {
    setState(() => _isSaving = true);
    final localizations = StorageLayoutLocalizations.of(context);
    final result = await ref
        .read(createStoragePlaceFromTemplateUseCaseProvider)
        .execute(
          template: template,
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
    final templates = ref.watch(storageTemplatesOfDomainProvider(widget.domainIdentifier));
    final selectedTemplate = _chosenTemplate ?? templates.firstOrNull;
    final defaultName = selectedTemplate == null
        ? localizations.defaultStoragePlaceName
        : context.layoutDefaultNames.storagePlaceName(selectedTemplate.storageKind);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.newStoragePlaceTitle)),
      body: ListView(
        padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
        children: [
          Text(localizations.templatePrompt, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: FoodieSpacing.small),
          StorageTemplateChoiceList(
            templates: templates,
            selectedTemplate: selectedTemplate,
            onTemplateSelected: (template) => setState(() => _chosenTemplate = template),
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
            onPressed: _isSaving || selectedTemplate == null
                ? null
                : () => _createStoragePlace(selectedTemplate),
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
