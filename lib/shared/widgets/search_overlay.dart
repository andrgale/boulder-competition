import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'search_result.dart';
import 'search_service.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

/// Campo di ricerca con overlay dropdown.
///
/// Sostituisce il [TextField] statico in AppShell.
/// Uso:
///   SearchBar(width: 300, height: 42)
class GlobalSearchBar extends StatefulWidget {
  const GlobalSearchBar({
    super.key,
    this.width = 300,
    this.height = 42,
  });

  final double width;
  final double height;

  @override
  State<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends State<GlobalSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _service = SearchService();
  final _layerLink = LayerLink();

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  OverlayEntry? _overlay;
  Timer? _debounce;

  List<SearchResult> _results = [];
  bool _loading = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Focus
  // ---------------------------------------------------------------------------

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      if (_controller.text.trim().isNotEmpty) _showOverlay();
    } else {
      // Piccolo delay per permettere il tap sui risultati prima di chiudere.
      Future.delayed(const Duration(milliseconds: 150), _removeOverlay);
    }
  }

  // ---------------------------------------------------------------------------
  // Ricerca con debounce 350 ms
  // ---------------------------------------------------------------------------

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      _removeOverlay();
      setState(() {
        _results = [];
        _loading = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _runSearch(value));
  }

  Future<void> _runSearch(String query) async {
    if (query == _lastQuery) return;
    _lastQuery = query;

    setState(() => _loading = true);
    _updateOverlay();

    try {
      final results = await _service.search(query);
      if (!mounted || query != _lastQuery) return;
      setState(() {
        _results = results;
        _loading = false;
      });
      _updateOverlay();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _updateOverlay();
    }
  }

  // ---------------------------------------------------------------------------
  // Overlay
  // ---------------------------------------------------------------------------

  void _showOverlay() {
    _removeOverlay();
    _overlay = _buildOverlayEntry();
    Overlay.of(context).insert(_overlay!);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _updateOverlay() {
    if (_overlay == null) {
      _showOverlay();
    } else {
      _overlay!.markNeedsBuild();
    }
  }

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (ctx) => Positioned(
        width: widget.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, widget.height + 4),
          child: _SearchDropdown(
            loading: _loading,
            results: _results,
            query: _controller.text,
            onSelect: _onSelect,
          ),
        ),
      ),
    );
  }

  void _onSelect(SearchResult result) {
    _controller.clear();
    _removeOverlay();
    _focusNode.unfocus();

    // Le rotte parametriche (es. /competitions/:id/registrations) hanno già
    // l'id interpolato in result.route. Per ascents-boulders serve anche extra.
    if (result.extra != null) {
      context.go(result.route, extra: result.extra);
    } else {
      context.go(result.route);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
   // final l10n = AppLocalizations.of(context)!;
    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: l10n.administrationMessageCustom155, // 'Cerca competizioni, atleti…'
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.search),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _controller.clear();
                      _removeOverlay();
                      setState(() {
                        _results = [];
                        _lastQuery = '';
                      });
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dropdown widget
// ---------------------------------------------------------------------------

class _SearchDropdown extends StatelessWidget {
  const _SearchDropdown({
    required this.loading,
    required this.results,
    required this.query,
    required this.onSelect,
  });

  final bool loading;
  final List<SearchResult> results;
  final String query;
  final ValueChanged<SearchResult> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final grouped = <SearchResultType, List<SearchResult>>{};
    for (final r in results) {
      grouped.putIfAbsent(r.type, () => []).add(r);
    }

    final children = <Widget>[];

    if (loading && results.isEmpty) {
      children.add(const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ));
    } else if (results.isEmpty && !loading) {
      children.add(Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          l10n.administrationMessageCustom156(query), // 'Nessun risultato per "{query}"'
          style: const TextStyle(color: Colors.grey),
        ),
      ));
    } else {
      for (final type in SearchResultType.values) {
        final group = grouped[type];
        if (group == null || group.isEmpty) continue;

        // Intestazione gruppo
        children.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            group.first.localizedTypeLabel(context).toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.blue.shade700,
              letterSpacing: 0.8,
            ),
          ),
        ));

        for (final result in group) {
          children.add(_ResultTile(result: result, onTap: () => onSelect(result)));
        }
      }
    }

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 420),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          shrinkWrap: true,
          children: children,
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result, required this.onTap});

  final SearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.blue.shade50,
        child: Icon(result.icon, size: 16, color: Colors.blue.shade700),
      ),
      title: Text(
        result.title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        result.subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}