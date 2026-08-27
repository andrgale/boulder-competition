import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

import 'package:boulder_competition/features/email/data/email_template_asset_service.dart';
import 'package:boulder_competition/features/email/data/email_template_repository.dart';

import '../models/email_template_model.dart';
import '../models/email_template_variable_model.dart';

import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:boulder_competition/l10n/app_localizations.dart';
class EmailTemplateEditorPage extends StatefulWidget {
  const EmailTemplateEditorPage({
    super.key,
    required this.template,
  });

  final EmailTemplateModel template;

  @override
  State<EmailTemplateEditorPage> createState() =>
      _EmailTemplateEditorPageState();
}

class _EmailTemplateEditorPageState extends State<EmailTemplateEditorPage> {
  final _repository = EmailTemplateRepository();
  final _assetService = EmailTemplateAssetService();
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _subject;
  late final TextEditingController _description;

  late EmailTemplateModel _template;

  late QuillController _editor;

  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  List<EmailTemplateVariableModel> _variables = [];

  bool _loading = true;
  bool _saving = false;
  bool _publishing = false;

  @override
  void initState() {
    super.initState();

    _template = widget.template;

    _subject = TextEditingController(text: _template.subject);
    _description = TextEditingController(text: _template.description ?? '');
    _editor = _createEditorFromHtml(_template.htmlBody);

    _loadVariables();
  }

  QuillController _createEditorFromHtml(String html) {
    try {
      final sourceHtml = html.trim().isEmpty ? '<p><br></p>' : _normalizeHtmlForQuill(html);

      final delta = HtmlToDelta().convert(sourceHtml, transformTableAsEmbed: false);
      final document = Document.fromDelta(delta);

      final selectionOffset = document.length > 0 ? document.length - 1 : 0;

      return QuillController(
        document: document,
        selection: TextSelection.collapsed(offset: selectionOffset),
      );
    } catch (error, stackTrace) {
      debugPrint('ERRORE HTML → DELTA → QUILL: $error');
      debugPrintStack(stackTrace: stackTrace);

      final document = Document();

      return QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();

    _editor.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();

    super.dispose();
  }

  Future<void> _loadVariables() async {
    try {
      _variables = await _repository.variablesFor(_template.id);
    } catch (error) {
      if (mounted) {
        _showError(error);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _normalizeHtmlForQuill(String html) {
    final document = html_parser.parseFragment(html);

    void processElement(dom.Element element) {
      final style = element.attributes['style'];

      if (style != null && style.trim().isNotEmpty) {
        final tag = element.localName?.toLowerCase();

        const inlineFormattingTags = {'strong', 'b', 'em', 'i', 'u', 's', 'del'};

        if (tag != null && inlineFormattingTags.contains(tag)) {
          final span = dom.Element.tag('span');
          span.attributes['style'] = style;
          span.nodes.addAll(List<dom.Node>.from(element.nodes));
          element.nodes.clear();
          element.append(span);
          element.attributes.remove('style');
        }
      }

      for (final child in List<dom.Element>.from(element.children)) {
        processElement(child);
      }
    }

    for (final element in document.children) {
      processElement(element);
    }

    return document.outerHtml;
  }

  String _editorToHtml() {
    final delta = _editor.document.toDelta();

    final normalizedDelta = delta.toJson().map((operation) {
      final result = Map<String, dynamic>.from(operation);
      final attributes = result['attributes'];

      if (attributes is Map) {
        final normalizedAttributes = Map<String, dynamic>.from(attributes);
        final color = normalizedAttributes['color'];
        if (color is String) {
          normalizedAttributes['color'] = _quillColorToCss(color);
        }
        final background = normalizedAttributes['background'];
        if (background is String) {
          normalizedAttributes['background'] = _quillColorToCss(background);
        }
        result['attributes'] = normalizedAttributes;
      }

      return result;
    }).toList();

    final options = ConverterOptions.forEmail();
    options.converterOptions.inlineStylesFlag = true;
    options.sanitizerOptions = OpAttributeSanitizerOptions(allow8DigitHexColors: true);

    final converter = QuillDeltaToHtmlConverter(normalizedDelta, options);

    final html = converter.convert();
    return html;
  }

  String _quillColorToCss(String color) {
    final value = color.trim();
    if (RegExp(r'^#[0-9a-fA-F]{8}$').hasMatch(value)) {
      return '#${value.substring(3)}';
    }
    return value;
  }

  Future<bool> _save() async {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    setState(() {
      _saving = true;
    });

    try {
      final html = _editorToHtml();

      _validateTokens(_subject.text, html);

      if (_template.status == 'active') {
        _template = await _repository.createDraft(
          templateCode: _template.templateCode,
          language: _template.language,
          subject: _subject.text.trim(),
          htmlBody: html,
          description: _emptyToNull(_description.text),
        );
      } else {
        _template = await _repository.updateDraft(
          id: _template.id,
          subject: _subject.text.trim(),
          htmlBody: html,
          description: _emptyToNull(_description.text),
        );
      }

      await _repository.replaceVariables(_template.id, _variables);

      if (!mounted) {
        return true;
      }

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.emailMessageCustom36(_template.version.toString()), // 'Bozza v{version} salvata.'
          ),
        ),
      );

      return true;
    } catch (error, stackTrace) {
      debugPrint('Errore salvataggio template: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        _showError(error);
      }

      return false;
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _publish() async {
    final saved = await _save();

    if (!saved || !mounted || _template.status != 'draft') {
      return;
    }

    final defaultLanguage = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.emailMessageCustom37), // 'Pubblica versione'
        content: Text(l10n.emailMessageCustom38), // dialog content
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(l10n.emailMessageCustom39), // 'No'
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text(l10n.emailMessageCustom40), // 'Sì, pubblica'
          ),
        ],
      ),
    );

    if (defaultLanguage == null) {
      return;
    }

    setState(() {
      _publishing = true;
    });

    try {
      await _repository.publish(_template.id, isDefault: defaultLanguage);

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        _showError(error);
      }
    } finally {
      if (mounted) {
        setState(() {
          _publishing = false;
        });
      }
    }
  }

  Future<void> _insertImage() async {
    if (_template.status == 'active') {
      _showMessage(l10n.emailMessageCustom41); // 'Salva prima: ...'
      return;
    }

    try {
      final image = await _assetService.pickUploadAndGetPublicUrl(_template.id);
      if (image == null) return;

      final url = image.publicUrl;
      final selection = _editor.selection;
      var index = selection.baseOffset;
      if (index < 0) index = 0;
      final maxIndex = _editor.document.length > 0 ? _editor.document.length - 1 : 0;
      if (index > maxIndex) index = maxIndex;

      _editor.document.insert(index, BlockEmbed.image(url));
      _editor.updateSelection(TextSelection.collapsed(offset: index + 1), ChangeSource.local);
      _editorFocusNode.requestFocus();

      _showMessage(l10n.emailMessageCustom42); // 'Immagine caricata e inserita nell’editor.'
    } catch (error, stackTrace) {
      debugPrint('Errore inserimento immagine: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) _showError(error);
    }
  }

  void _insertVariable(String code) {
    final value = '{{$code}}';
    final selection = _editor.selection;
    final start = selection.start;
    final length = selection.end - selection.start;

    _editor.replaceText(
      start,
      length,
      value,
      TextSelection.collapsed(offset: start + value.length),
    );

    _editorFocusNode.requestFocus();
  }

  Future<void> _editVariable([EmailTemplateVariableModel? current]) async {
    final variable = await showDialog<EmailTemplateVariableModel>(
      context: context,
      builder: (_) => _VariableDialog(variable: current),
    );

    if (variable == null) return;

    final duplicate = _variables.any((item) => item.variableCode == variable.variableCode && item.id != variable.id);

    if (duplicate) {
      _showMessage(l10n.emailMessageCustom45); // 'Questa variabile è già presente.'
      return;
    }

    setState(() {
      final index = _variables.indexWhere((item) => item.id == variable.id);
      if (index == -1) {
        _variables = [..._variables, variable];
      } else {
        _variables = [..._variables]..[index] = variable;
      }
    });
  }

  void _validateTokens(String subject, String html) {
    final supported = _variables.map((item) => item.variableCode).toSet();
    final pattern = RegExp(r'\{\{([A-Z][A-Z0-9_]*)\}\}');
    final found = pattern.allMatches('$subject\n$html').map((match) => match.group(1)!).toSet();
    final unknown = found.difference(supported);

    if (unknown.isNotEmpty) {
      throw StateError(AppLocalizations.of(context)!.emailMessageCustom44(unknown.join(', '))); // 'Variabili non dichiarate: {list}'
    }
  }

  String? _emptyToNull(String value) {
    return value.trim().isEmpty ? null : value.trim();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(Object error) {
    _showMessage(l10n.emailMessageCustom43(error.toString())); // 'Operazione non riuscita: {error}'
  }

  @override
  Widget build(BuildContext context) {
    final readOnlyVersion = _template.status == 'active';
    final sampleToken = Localizations.localeOf(context).languageCode.startsWith('it') ? '{{CODICE}}' : '{{CODE}}';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.emailMessageCustom21(_template.templateCode, _template.language, _template.version.toString())), // '{code} · {language} · v{version}'
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(l10n.emailMessageCustom22), // 'Salva bozza'
          ),
          if (_template.status == 'draft')
            FilledButton.icon(
              onPressed: _saving || _publishing ? null : _publish,
              icon: const Icon(Icons.publish_outlined),
              label: Text(l10n.emailMessageCustom23), // 'Pubblica'
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (readOnlyVersion)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(l10n.emailMessageCustom24), // 'Versione pubblicata'
                        subtitle: Text(l10n.emailMessageCustom25), // 'Il salvataggio creerà automaticamente...'
                      ),
                    ),

                  TextFormField(
                    controller: _subject,
                    decoration: InputDecoration(labelText: l10n.emailMessageCustom26), // 'Oggetto email'
                    maxLength: 200,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.emailMessageCustom27; // 'L’oggetto è obbligatorio.'
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _description,
                    decoration: InputDecoration(labelText: l10n.emailMessageCustom28), // 'Descrizione interna'
                    maxLines: 2,
                  ),

                  const SizedBox(height: 24),

                  _VariablesPanel(
                    variables: _variables,
                    onAdd: () => _editVariable(),
                    onEdit: _editVariable,
                    onDelete: (variable) {
                      setState(() {
                        _variables.remove(variable);
                      });
                    },
                    onInsert: _insertVariable,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Text(l10n.emailMessageCustom32, style: Theme.of(context).textTheme.titleLarge), // 'Corpo email'
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: _insertImage,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: Text(l10n.emailMessageCustom33), // 'Carica immagine'
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  _buildRichTextEditor(l10n),

                  const SizedBox(height: 24),

                  Text(l10n.emailMessageCustom35(sampleToken), // paragraph about variables
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRichTextEditor(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: QuillSimpleToolbar(
              controller: _editor,
              config: QuillSimpleToolbarConfig(
                multiRowsDisplay: true,
                showDividers: true,
                showFontFamily: true,
                showFontSize: true,
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showStrikeThrough: true,
                showColorButton: true,
                showBackgroundColorButton: true,
                showClearFormat: true,
                showAlignmentButtons: true,
                showHeaderStyle: true,
                showListNumbers: true,
                showListBullets: true,
                showIndent: true,
                showLink: true,
                showUndo: true,
                showRedo: true,
                showInlineCode: false,
                showCodeBlock: false,
                showQuote: false,
                showDirection: false,
                showSubscript: false,
                showSuperscript: false,
                showSearchButton: false,
                axis: Axis.horizontal,
                buttonOptions: const QuillSimpleToolbarButtonOptions(
                  fontFamily: QuillToolbarFontFamilyButtonOptions(
                    items: {
                      'sans-serif': 'Sans Serif',
                      'serif': 'Serif',
                      'monospace': 'Monospace',
                      'Arial': 'Arial',
                      'Helvetica': 'Helvetica',
                      'Verdana': 'Verdana',
                      'Tahoma': 'Tahoma',
                      'Trebuchet MS': 'Trebuchet MS',
                      'Georgia': 'Georgia',
                      'Times New Roman': 'Times New Roman',
                      'Courier New': 'Courier New',
                    },
                  ),
                ),
              ),
            ),
          ),

          const Divider(height: 1),

          SizedBox(
            height: 460,
            child: QuillEditor(
              controller: _editor,
              focusNode: _editorFocusNode,
              scrollController: _editorScrollController,
              config: QuillEditorConfig(
                placeholder: l10n.emailMessageCustom34, // 'Scrivi il contenuto della mail…'
                padding: const EdgeInsets.all(16),
                expands: false,
                scrollable: true,
                enableInteractiveSelection: true,
                enableSelectionToolbar: true,
                autoFocus: false,
                embedBuilders: FlutterQuillEmbeds.editorBuilders(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VariablesPanel extends StatelessWidget {
  const _VariablesPanel({
    required this.variables,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onInsert,
  });

  final List<EmailTemplateVariableModel> variables;
  final VoidCallback onAdd;
  final ValueChanged<EmailTemplateVariableModel> onEdit;
  final ValueChanged<EmailTemplateVariableModel> onDelete;
  final ValueChanged<String> onInsert;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(l10n.emailMessageCustom29, style: Theme.of(context).textTheme.titleLarge), // 'Variabili dinamiche'
                const Spacer(),
                OutlinedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: Text(l10n.emailMessageCustom30)), // 'Aggiungi'
              ],
            ),

            if (variables.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l10n.emailMessageCustom31), // 'Nessuna variabile...'
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: variables
                    .map(
                      (variable) => InputChip(
                        label: Text('{{${variable.variableCode}}} · ${variable.dataType}'),
                        tooltip: variable.description ?? variable.label,
                        onPressed: () => onInsert(variable.variableCode),
                        onDeleted: () => onDelete(variable),
                        avatar: IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () => onEdit(variable),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _VariableDialog extends StatefulWidget {
  const _VariableDialog({this.variable});
  final EmailTemplateVariableModel? variable;

  @override
  State<_VariableDialog> createState() => _VariableDialogState();
}

class _VariableDialogState extends State<_VariableDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _code;
  late final TextEditingController _label;
  late final TextEditingController _description;
  late final TextEditingController _defaultValue;
  late final TextEditingController _exampleValue;

  late String _type;
  late bool _required;

  @override
  void initState() {
    super.initState();

    final value = widget.variable;

    _code = TextEditingController(text: value?.variableCode ?? '');
    _label = TextEditingController(text: value?.label ?? '');
    _description = TextEditingController(text: value?.description ?? '');
    _defaultValue = TextEditingController(text: value?.defaultValue ?? '');
    _exampleValue = TextEditingController(text: value?.exampleValue ?? '');
    _type = value?.dataType ?? 'text';
    _required = value?.required ?? false;
  }

  @override
  void dispose() {
    _code.dispose();
    _label.dispose();
    _description.dispose();
    _defaultValue.dispose();
    _exampleValue.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.variable == null ? l10n.emailMessageCustom46 : l10n.emailMessageCustom47), // 'Nuova variabile' / 'Modifica variabile'
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _code,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(labelText: l10n.emailMessageCustom11), // reuse 'Codice, es. WELCOME'
                  validator: (value) => RegExp(r'^[A-Z][A-Z0-9_]*$').hasMatch(value ?? '')
                      ? null
                      : l10n.emailMessageCustom12, // 'Usa maiuscole, numeri e _.'
                ),

                TextFormField(
                  controller: _label,
                  decoration: InputDecoration(labelText: l10n.emailMessageCustom50), // 'Etichetta'
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.emailMessageCustom51; // 'L’etichetta è obbligatoria.'
                    }
                    return null;
                  },
                ),

                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: InputDecoration(labelText: l10n.emailMessageCustom52), // 'Tipo'
                  items: const ['text', 'number', 'date', 'datetime', 'url', 'email']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _type = value;
                    });
                  },
                ),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.emailMessageCustom59), // 'Obbligatoria'
                  value: _required,
                  onChanged: (value) {
                    setState(() {
                      _required = value;
                    });
                  },
                ),

                TextFormField(controller: _defaultValue, decoration: InputDecoration(labelText: l10n.emailMessageCustom60)), // 'Valore predefinito'

                TextFormField(controller: _exampleValue, decoration: InputDecoration(labelText: l10n.emailMessageCustom61)), // 'Valore per anteprima'

                TextFormField(controller: _description, decoration: InputDecoration(labelText: l10n.emailMessageCustom62), maxLines: 2), // 'Descrizione'
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.emailMessageCustom8)), // 'Annulla'
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            Navigator.pop(
              context,
              EmailTemplateVariableModel(
                id: widget.variable?.id ?? '',
                templateId: widget.variable?.templateId ?? '',
                variableCode: _code.text.trim().toUpperCase(),
                label: _label.text.trim(),
                description: _emptyToNull(_description.text),
                dataType: _type,
                required: _required,
                defaultValue: _emptyToNull(_defaultValue.text),
                validation: widget.variable?.validation ?? const {},
                exampleValue: _emptyToNull(_exampleValue.text),
                createdAt: widget.variable?.createdAt ?? DateTime.now(),
              ),
            );
          },
          child: Text(l10n.emailMessageCustom63), // 'Conferma'
        ),
      ],
    );
  }
}

String? _emptyToNull(String value) {
  return value.trim().isEmpty ? null : value.trim();
}