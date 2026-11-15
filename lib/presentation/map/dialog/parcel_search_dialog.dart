import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/input/parcel_info_text_field.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// Asks for a parcel by number: neighbourhood, block and parcel.
///
/// The neighbourhood is picked from [neighbourhoods] — those of the parcels
/// already stored, which is where a family's land usually is — or typed as
/// the registry's code for any other. [open] answers the three values, or
/// null when the member backs out; nothing is looked up here.
class ParcelSearchDialog extends StatefulWidget {
  const ParcelSearchDialog({super.key, required this.neighbourhoods});

  final List<({int id, String name})> neighbourhoods;

  static Future<({int neighborhoodId, String block, String parcel})?> open(
    BuildContext context, {
    required List<({int id, String name})> neighbourhoods,
  }) => showDialog<({int neighborhoodId, String block, String parcel})>(
    context: context,
    builder: (_) => ParcelSearchDialog(neighbourhoods: neighbourhoods),
  );

  @override
  State<ParcelSearchDialog> createState() => _ParcelSearchDialogState();
}

class _ParcelSearchDialogState extends State<ParcelSearchDialog> {
  final TextEditingController _code = TextEditingController();
  final TextEditingController _block = TextEditingController();
  final TextEditingController _parcel = TextEditingController();
  late int _neighbourhood = widget.neighbourhoods.isEmpty
      ? _other
      : widget.neighbourhoods.first.id;

  static const int _other = -1;

  @override
  void dispose() {
    _code.dispose();
    _block.dispose();
    _parcel.dispose();
    super.dispose();
  }

  int? get _neighbourhoodId => _neighbourhood == _other
      ? int.tryParse(_code.text.trim())
      : _neighbourhood;

  bool get _complete =>
      (_neighbourhoodId ?? CoreConstants.zero) > CoreConstants.zero &&
      _block.text.trim().isNotEmpty &&
      _parcel.text.trim().isNotEmpty;

  void _submit() {
    if (!_complete) return;
    Navigator.of(context).pop((
      neighborhoodId: _neighbourhoodId!,
      block: _block.text.trim(),
      parcel: _parcel.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    return AlertDialog(
      title: ParcelInfoText(l10n.searchTitle),
      content: SizedBox(
        width: ParcelInfoDimens.panelMaxWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DropdownButtonFormField<int>(
                initialValue: _neighbourhood,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.searchNeighbourhood,
                ),
                items: <DropdownMenuItem<int>>[
                  for (final ({int id, String name}) item
                      in widget.neighbourhoods)
                    DropdownMenuItem<int>(
                      value: item.id,
                      child: ParcelInfoText(item.name),
                    ),
                  DropdownMenuItem<int>(
                    value: _other,
                    child: ParcelInfoText(l10n.searchOther),
                  ),
                ],
                onChanged: (int? value) =>
                    setState(() => _neighbourhood = value ?? _other),
              ),
              if (_neighbourhood == _other) ...<Widget>[
                SizedBox(height: BaseDimens.height.xxSmall),
                ParcelInfoTextField(
                  controller: _code,
                  label: l10n.searchNeighbourhoodCode,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ],
              SizedBox(height: BaseDimens.height.xxSmall),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ParcelInfoTextField(
                      controller: _block,
                      label: l10n.blockLabel,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  SizedBox(width: BaseDimens.width.small),
                  Expanded(
                    child: ParcelInfoTextField(
                      controller: _parcel,
                      label: l10n.parcelNumberLabel,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.search,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: BaseDimens.height.xxSmall),
              ParcelInfoText(
                l10n.searchHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: ParcelInfoText(l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: _complete ? _submit : null,
          icon: const Icon(Icons.search),
          label: ParcelInfoText(l10n.searchButton),
        ),
      ],
    );
  }
}
