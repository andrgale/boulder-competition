import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/category_service.dart';
import '../models/category_model.dart';

class CategoriesPage extends StatefulWidget {
  final String competitionId;
  final String competitionName;

  const CategoriesPage({
    super.key,
    required this.competitionId,
    required this.competitionName,
  });

  @override
  State<CategoriesPage> createState() =>
      _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final service = CategoryService();

  List<CategoryModel> categories = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadRealtime();
  }

  Future<void> refreshData() async {
    final rows = await service.getCategories(widget.competitionId);

    if (!mounted) return;

    setState(() {
      categories = rows;
      loading = false;
    });
  }
  // =====================================================
  // REALTIME
  // =====================================================
  void loadRealtime() {
    service
        .watchCategories(widget.competitionId)
        .listen((rows) {
      if (!mounted) return;

      setState(() {
        categories = rows;
        loading = false;
      });
    });
  }

  // =====================================================
  // DELETE
  // =====================================================
  Future<void> deleteCategory(String id) async {
    try {
      await service.deleteCategory(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Categoria eliminata'),
          
        ),
        
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
    }
     await refreshData();
  }
 // =====================================================
  // NAV CREATE
  // =====================================================
  Future<void> openCreate() async {
    final res = await context.push(
      '/categories/new',
      extra: widget.competitionId,
    );

    if (res == true) {
      refreshData();
    }
  }
  // =====================================================
  // NAV EDIT
  // =====================================================
  Future<void> openEdit(CategoryModel c) async {
    final res = await context.push(
      '/categories/edit',
      extra: {
        'competitionId': widget.competitionId,
        'category': c,
      },
    );

    if (res == true) {
      await refreshData();
    }
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: AppBar(
        title: Text('Categorie - ${widget.competitionName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: openCreate,
          ),
        ],
      ),

      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: openCreate,
              child: const Icon(Icons.add),
            )
          : null,

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? const Center(child: Text('Nessuna categoria'))
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, i) {
                    final c = categories[i];

                    return ListTile(
                      title: Text(c.nome),
                      subtitle: Text(
                        '${c.sesso ?? "-"} | ${c.etaMin ?? "-"} - ${c.etaMax ?? "-"}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => openEdit(c),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteCategory(c.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}