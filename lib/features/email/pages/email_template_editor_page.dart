import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

import 'package:boulder_competition/features/email/data/email_template_asset_service.dart';
import 'package:boulder_competition/features/email/data/email_template_repository.dart';

import '../models/email_template_model.dart';
import '../models/email_template_variable_model.dart';

/// Editor dei template email.
///
/// Il database continua a utilizzare HTML.
///
/// Flusso:
///
///   HTML database
///       ↓
///   HtmlToDelta
///       ↓
///   QuillController
///       ↓
///   Flutter Quill
///       ↓
///   Delta
///       ↓
///   QuillDeltaToHtmlConverter
///       ↓
///   HTML database
///
/// Non utilizza WebView.
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

class _EmailTemplateEditorPageState
    extends State<EmailTemplateEditorPage> {
  final _repository = EmailTemplateRepository();
  final _assetService = EmailTemplateAssetService();

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _subject;
  late final TextEditingController _description;

  late EmailTemplateModel _template;

  late QuillController _editor;

  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController =
      ScrollController();

  List<EmailTemplateVariableModel> _variables = [];

  bool _loading = true;
  bool _saving = false;
  bool _publishing = false;

@override
void initState() {
  super.initState();

  _template = widget.template;

  // debugPrint('======================================');
  // debugPrint('EDITOR APERTO');
  // debugPrint('ID: ${_template.id}');
  // debugPrint('VERSION: ${_template.version}');
  // debugPrint('STATUS: ${_template.status}');
  // debugPrint('HTML BODY DA DB:');
  // debugPrint(_template.htmlBody);
  // debugPrint('======================================');

  _subject = TextEditingController(
    text: _template.subject,
  );

  _description = TextEditingController(
    text: _template.description ?? '',
  );

  _editor = _createEditorFromHtml(
    _template.htmlBody,
  );

  _loadVariables();
}
  /// Converte l'HTML presente nel database in un documento
  /// Quill modificabile.
  // QuillController _createEditorFromHtml(String html) {
  //   try {
  //     final sourceHtml = html.trim().isEmpty
  //         ? '<p><br></p>'
  //         : html;

  //     final delta = HtmlToDelta().convert(
  //       sourceHtml,
  //       transformTableAsEmbed: false,
  //     );

  //     final document = Document.fromDelta(delta);

  //     final selectionOffset =
  //         document.length > 0 ? document.length - 1 : 0;

  //     return QuillController(
  //       document: document,
  //       selection: TextSelection.collapsed(
  //         offset: selectionOffset,
  //       ),
  //     );
  //   } catch (error, stackTrace) {
  //     debugPrint(
  //       'Errore conversione HTML → Quill: $error',
  //     );
  //     debugPrintStack(stackTrace: stackTrace);

  //     return QuillController.basic();
  //   }
  // }

  QuillController _createEditorFromHtml(String html) {
  // debugPrint('════════════════════════════════════════');
  // debugPrint('QUILL LOAD');
  // debugPrint('HTML RICEVUTO DAL MODELLO:');
  // debugPrint(html);
  // debugPrint('════════════════════════════════════════');

  try {
    final sourceHtml = html.trim();

    if (sourceHtml.isEmpty) {
      final document = Document();

      return QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    final delta = HtmlToDelta().convert(
      sourceHtml,
      transformTableAsEmbed: false,
    );

    // debugPrint('DELTA GENERATO DA HTML:');
    // debugPrint(delta.toJson().toString());

    final document = Document.fromDelta(delta);

    // debugPrint('TESTO PLAIN GENERATO DA DELTA:');
    // debugPrint(document.toPlainText());

    final selectionOffset =
        document.length > 0 ? document.length - 1 : 0;

    return QuillController(
      document: document,
      selection: TextSelection.collapsed(
        offset: selectionOffset,
      ),
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
      _variables = await _repository.variablesFor(
        _template.id,
      );
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

  /// Converte il documento Quill nell'HTML da salvare nel DB.
  ///
  /// inlineStylesFlag è importante per le email: gli stili vengono
  /// prodotti direttamente nell'HTML invece di dipendere da CSS
  /// esterni.
  String _editorToHtml() {
    final delta = _editor.document.toDelta();

    final options = ConverterOptions.forEmail();

    options.converterOptions.inlineStylesFlag = true;

    final converter = QuillDeltaToHtmlConverter(
      delta.toJson()
          .map(
            (operation) =>
                Map<String, dynamic>.from(operation),
          )
          .toList(),
      options,
    );

    return converter.convert();
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

      // debugPrint(
      //   '>>> HTML GENERATO DAL NUOVO EDITOR:\n$html',
      // );

      _validateTokens(
        _subject.text,
        html,
      );

      if (_template.status == 'active') {
        _template = await _repository.createDraft(
          templateCode: _template.templateCode,
          language: _template.language,
          subject: _subject.text.trim(),
          htmlBody: html,
          description: _emptyToNull(
            _description.text,
          ),
        );
      } else {
        _template = await _repository.updateDraft(
          id: _template.id,
          subject: _subject.text.trim(),
          htmlBody: html,
          description: _emptyToNull(
            _description.text,
          ),
        );
      }

      await _repository.replaceVariables(
        _template.id,
        _variables,
      );

      if (!mounted) {
        return true;
      }

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bozza v${_template.version} salvata.',
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

    if (!saved ||
        !mounted ||
        _template.status != 'draft') {
      return;
    }

    final defaultLanguage = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pubblica versione'),
        content: const Text(
          'La versione attiva precedente per questa lingua '
          'verrà archiviata. Vuoi impostare questa lingua '
          'anche come predefinita?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Sì, pubblica'),
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
      await _repository.publish(
        _template.id,
        isDefault: defaultLanguage,
      );

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

  /// Carica l'immagine tramite il tuo servizio esistente e inserisce
  /// l'URL pubblico come image embed Quill.
  Future<void> _insertImage() async {
    if (_template.status == 'active') {
      _showMessage(
        'Salva prima: verrà creata una nuova bozza '
        'a cui associare l’immagine.',
      );
      return;
    }

    try {
      final image =
          await _assetService.pickUploadAndGetPublicUrl(
        _template.id,
      );

      if (image == null) {
        return;
      }

      final url = image.publicUrl;

      final selection = _editor.selection;

      var index = selection.baseOffset;

      if (index < 0) {
        index = 0;
      }

      final maxIndex =
          _editor.document.length > 0
              ? _editor.document.length - 1
              : 0;

      if (index > maxIndex) {
        index = maxIndex;
      }

      _editor.document.insert(
        index,
        BlockEmbed.image(url),
      );

      _editor.updateSelection(
        TextSelection.collapsed(
          offset: index + 1,
        ),
        ChangeSource.local,
      );

      _editorFocusNode.requestFocus();

      _showMessage(
        'Immagine caricata e inserita nell’editor.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Errore inserimento immagine: $error',
      );
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        _showError(error);
      }
    }
  }

  /// Inserisce {{CODICE}} nella posizione corrente del cursore.
  void _insertVariable(String code) {
    final value = '{{$code}}';

    final selection = _editor.selection;

    final start = selection.start;
    final length = selection.end - selection.start;

    _editor.replaceText(
      start,
      length,
      value,
      TextSelection.collapsed(
        offset: start + value.length,
      ),
    );

    _editorFocusNode.requestFocus();
  }

  Future<void> _editVariable([
    EmailTemplateVariableModel? current,
  ]) async {
    final variable =
        await showDialog<EmailTemplateVariableModel>(
      context: context,
      builder: (_) => _VariableDialog(
        variable: current,
      ),
    );

    if (variable == null) {
      return;
    }

    final duplicate = _variables.any(
      (item) =>
          item.variableCode ==
              variable.variableCode &&
          item.id != variable.id,
    );

    if (duplicate) {
      _showMessage(
        'Questa variabile è già presente.',
      );
      return;
    }

    setState(() {
      final index = _variables.indexWhere(
        (item) => item.id == variable.id,
      );

      if (index == -1) {
        _variables = [
          ..._variables,
          variable,
        ];
      } else {
        _variables = [
          ..._variables,
        ]..[index] = variable;
      }
    });
  }

  void _validateTokens(
    String subject,
    String html,
  ) {
    final supported = _variables
        .map((item) => item.variableCode)
        .toSet();

    final pattern =
        RegExp(r'\{\{([A-Z][A-Z0-9_]*)\}\}');

    final found = pattern
        .allMatches('$subject\n$html')
        .map((match) => match.group(1)!)
        .toSet();

    final unknown =
        found.difference(supported);

    if (unknown.isNotEmpty) {
      throw StateError(
        'Variabili non dichiarate: '
        '${unknown.join(', ')}',
      );
    }
  }

  String? _emptyToNull(String value) {
    return value.trim().isEmpty
        ? null
        : value.trim();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _showError(Object error) {
    _showMessage(
      'Operazione non riuscita: $error',
    );
  }

  @override
  Widget build(BuildContext context) {
    final readOnlyVersion =
        _template.status == 'active';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_template.templateCode} · '
          '${_template.language} · '
          'v${_template.version}',
        ),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(
              Icons.save_outlined,
            ),
            label: const Text('Salva bozza'),
          ),
          if (_template.status == 'draft')
            FilledButton.icon(
              onPressed:
                  _saving || _publishing
                      ? null
                      : _publish,
              icon: const Icon(
                Icons.publish_outlined,
              ),
              label: const Text('Pubblica'),
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding:
                    const EdgeInsets.all(20),
                children: [
                  if (readOnlyVersion)
                    const Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.history,
                        ),
                        title: Text(
                          'Versione pubblicata',
                        ),
                        subtitle: Text(
                          'Il salvataggio creerà '
                          'automaticamente una nuova bozza.',
                        ),
                      ),
                    ),

                  TextFormField(
                    controller: _subject,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Oggetto email',
                    ),
                    maxLength: 200,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'L’oggetto è obbligatorio.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _description,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Descrizione interna',
                    ),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 24),

                  _VariablesPanel(
                    variables: _variables,
                    onAdd: () =>
                        _editVariable(),
                    onEdit: _editVariable,
                    onDelete: (variable) {
                      setState(() {
                        _variables
                            .remove(variable);
                      });
                    },
                    onInsert:
                        _insertVariable,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Text(
                        'Corpo email',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge,
                      ),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed:
                            _insertImage,
                        icon: const Icon(
                          Icons
                              .add_photo_alternate_outlined,
                        ),
                        label: const Text(
                          'Carica immagine',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  _buildRichTextEditor(),

                  const SizedBox(height: 24),

                  Text(
                    'Le variabili testuali vengono '
                    'inserite come {{CODICE}}. '
                    'Per un link dinamico, crea una '
                    'variabile di tipo URL e usa '
                    '{{CODICE}} nel campo URL del link.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRichTextEditor() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outline,
        ),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Material(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            child: QuillSimpleToolbar(
              controller: _editor,
              config:
                  QuillSimpleToolbarConfig(
                multiRowsDisplay: true,
                showDividers: true,

                // Font
                showFontFamily: true,
                showFontSize: true,

                // Formattazione
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showStrikeThrough: true,

                // Colori
                showColorButton: true,
                showBackgroundColorButton: true,

                // Pulizia formattazione
                showClearFormat: true,

                // Paragrafo
                showAlignmentButtons: true,
                showHeaderStyle: true,

                // Liste
                showListNumbers: true,
                showListBullets: true,

                // Rientro
                showIndent: true,

                // Link
                showLink: true,

                // Cronologia
                showUndo: true,
                showRedo: true,

                // Non necessari per le email
                showInlineCode: false,
                showCodeBlock: false,
                showQuote: false,
                showDirection: false,
                showSubscript: false,
                showSuperscript: false,
                showSearchButton: false,

                axis: Axis.horizontal,
              ),
            ),
          ),

          const Divider(
            height: 1,
          ),

          SizedBox(
            height: 460,
            child: QuillEditor(
              controller: _editor,
              focusNode: _editorFocusNode,
              scrollController:
                  _editorScrollController,
              config: QuillEditorConfig(
                placeholder:
                    'Scrivi il contenuto della mail…',
                padding:
                    const EdgeInsets.all(16),
                expands: false,
                scrollable: true,
                enableInteractiveSelection:
                    true,
                enableSelectionToolbar: true,
                autoFocus: false,
                embedBuilders:
                    FlutterQuillEmbeds
                        .editorBuilders(),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Variabili dinamiche',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge,
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(
                    Icons.add,
                  ),
                  label: const Text(
                    'Aggiungi',
                  ),
                ),
              ],
            ),

            if (variables.isEmpty)
              const Padding(
                padding:
                    EdgeInsets.only(top: 8),
                child: Text(
                  'Nessuna variabile. '
                  'Puoi comunque scrivere '
                  'una mail statica.',
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: variables
                    .map(
                      (variable) =>
                          InputChip(
                        label: Text(
                          '{{${variable.variableCode}}}'
                          ' · '
                          '${variable.dataType}',
                        ),
                        tooltip:
                            variable.description ??
                                variable.label,
                        onPressed: () =>
                            onInsert(
                          variable.variableCode,
                        ),
                        onDeleted: () =>
                            onDelete(variable),
                        avatar: IconButton(
                          icon: const Icon(
                            Icons
                                .edit_outlined,
                            size: 18,
                          ),
                          onPressed: () =>
                              onEdit(variable),
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
  const _VariableDialog({
    this.variable,
  });

  final EmailTemplateVariableModel? variable;

  @override
  State<_VariableDialog> createState() =>
      _VariableDialogState();
}

class _VariableDialogState
    extends State<_VariableDialog> {
  final _formKey =
      GlobalKey<FormState>();

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

    _code = TextEditingController(
      text: value?.variableCode ?? '',
    );

    _label = TextEditingController(
      text: value?.label ?? '',
    );

    _description =
        TextEditingController(
      text: value?.description ?? '',
    );

    _defaultValue =
        TextEditingController(
      text: value?.defaultValue ?? '',
    );

    _exampleValue =
        TextEditingController(
      text: value?.exampleValue ?? '',
    );

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
    return AlertDialog(
      title: Text(
        widget.variable == null
            ? 'Nuova variabile'
            : 'Modifica variabile',
      ),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _code,
                  textCapitalization:
                      TextCapitalization
                          .characters,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Codice, es. FIRST_NAME',
                  ),
                  validator: (value) =>
                      RegExp(
                        r'^[A-Z][A-Z0-9_]*$',
                      ).hasMatch(
                        value ?? '',
                      )
                          ? null
                          : 'Usa maiuscole, '
                            'numeri e _.',
                ),

                TextFormField(
                  controller: _label,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Etichetta',
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'L’etichetta '
                          'è obbligatoria.';
                    }

                    return null;
                  },
                ),

                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                  ),
                  items: const [
                    'text',
                    'number',
                    'date',
                    'datetime',
                    'url',
                    'email',
                  ]
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _type = value;
                    });
                  },
                ),

                SwitchListTile(
                  contentPadding:
                      EdgeInsets.zero,
                  title: const Text(
                    'Obbligatoria',
                  ),
                  value: _required,
                  onChanged: (value) {
                    setState(() {
                      _required = value;
                    });
                  },
                ),

                TextFormField(
                  controller: _defaultValue,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Valore predefinito',
                  ),
                ),

                TextFormField(
                  controller: _exampleValue,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Valore per anteprima',
                  ),
                ),

                TextFormField(
                  controller: _description,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Descrizione',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: const Text(
            'Annulla',
          ),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!
                .validate()) {
              return;
            }

            Navigator.pop(
              context,
              EmailTemplateVariableModel(
                id: widget.variable?.id ?? '',
                templateId:
                    widget.variable?.templateId ??
                        '',
                variableCode:
                    _code.text
                        .trim()
                        .toUpperCase(),
                label:
                    _label.text.trim(),
                description:
                    _emptyToNull(
                  _description.text,
                ),
                dataType: _type,
                required: _required,
                defaultValue:
                    _emptyToNull(
                  _defaultValue.text,
                ),
                validation:
                    widget.variable
                            ?.validation ??
                        const {},
                exampleValue:
                    _emptyToNull(
                  _exampleValue.text,
                ),
                createdAt:
                    widget.variable
                            ?.createdAt ??
                        DateTime.now(),
              ),
            );
          },
          child: const Text(
            'Conferma',
          ),
        ),
      ],
    );
  }
}

String? _emptyToNull(String value) {
  return value.trim().isEmpty
      ? null
      : value.trim();
}