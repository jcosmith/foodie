import 'package:core_design_system/core_design_system.dart';
import 'package:core_localization/core_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/storage_layout_providers.dart';
import '../domain/freezer_template.dart';
import '../domain/layout_name_policy.dart';
import '../l10n/generated/storage_layout_localizations.dart';
import 'freezer_template_choice_list.dart';
import 'layout_localization.dart';
import 'storage_layout_routes.dart';

/// Adds a freezer from a template, then opens its editor.
class FreezerTemplatePickerScreen extends ConsumerStatefulWidget {
  const FreezerTemplatePickerScreen({super.key});

  @override
  ConsumerState<FreezerTemplatePickerScreen> createState() => _FreezerTemplatePickerScreenState();
}

class _FreezerTemplatePickerScreenState extends ConsumerState<FreezerTemplatePickerScreen> {
  final TextEditingController _nameController = TextEditingController();
  FreezerTemplate _selectedTemplate = FreezerTemplate.uprightWithThreeDrawers;
  String? _nameError;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createFreezer() async {
    setState(() => _isSaving = true);
    final localizations = StorageLayoutLocalizations.of(context);
    final result = await ref
        .read(createFreezerFromTemplateUseCaseProvider)
        .execute(
          template: _selectedTemplate,
          enteredName: _nameController.text,
          defaultNames: context.layoutDefaultNames,
        );
    if (!mounted) return;
    result.fold(
      onSuccess: (freezerIdentifier) =>
          context.pushReplacement(StorageLayoutRoutes.freezerEditor(freezerIdentifier)),
      onFailure: (failure) => setState(() {
        _isSaving = false;
        _nameError = localizations.describeFailure(failure, isAboutFreezer: true);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = StorageLayoutLocalizations.of(context);
    final defaultName = context.layoutDefaultNames.freezerName(_selectedTemplate.storageKind);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.newFreezerTitle)),
      body: ListView(
        padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
        children: [
          Text(localizations.templatePrompt, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: FoodieSpacing.small),
          FreezerTemplateChoiceList(
            selectedTemplate: _selectedTemplate,
            onTemplateSelected: (template) => setState(() => _selectedTemplate = template),
          ),
          const SizedBox(height: FoodieSpacing.large),
          TextField(
            controller: _nameController,
            maxLength: LayoutNamePolicy.maximumNameLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: localizations.freezerNameLabel,
              hintText: defaultName,
              helperText: localizations.freezerNameHelper(defaultName),
              helperMaxLines: 2,
              errorText: _nameError,
            ),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: FoodieSpacing.large),
          FilledButton(
            onPressed: _isSaving ? null : _createFreezer,
            child: Text(localizations.addFreezerButton),
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
