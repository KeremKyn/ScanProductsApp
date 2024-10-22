import 'package:flutter/material.dart';
import 'package:scan_products_app/data/ingredientCategory_service.dart';
import 'package:scan_products_app/data/ingredient_service.dart';
import 'package:scan_products_app/models/ingredient.dart';
import 'package:scan_products_app/models/ingredientCategory.dart';

class IngredientListScreen extends StatefulWidget {
  @override
  _IngredientListScreenState createState() => _IngredientListScreenState();
}

class _IngredientListScreenState extends State<IngredientListScreen> with SingleTickerProviderStateMixin {
  final IngredientCategoryService _categoryService = IngredientCategoryService();
  final IngredientService _ingredientService = IngredientService();
  String _searchQuery = '';
  String? _selectedCategoryId;
  TextEditingController _searchController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _ingredientService.getAllIngredients(); // İçerikleri getirme işlemi
    _categoryService.getAllIngredientCategories(); // Kategorileri getirme işlemi

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _categoryService.dispose();
    _ingredientService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _applyFilters();
    });
  }

  void _onCategorySelected(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _applyFilters();
    });
  }

  void _clearCategorySelection() {
    setState(() {
      _selectedCategoryId = null;
      _applyFilters();
    });
  }

  void _applyFilters() {
    if (_searchQuery.isNotEmpty &&
        _selectedCategoryId != null &&
        _selectedCategoryId!.isNotEmpty) {
      _ingredientService.filterIngredientsByCategoryAndSearchQuery(
          _selectedCategoryId!, _searchQuery);
    } else if (_searchQuery.isNotEmpty) {
      _ingredientService.filterIngredientsBySearchQuery(_searchQuery);
    } else if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
      _ingredientService.filterIngredientsByCategory(_selectedCategoryId!);
    } else {
      _ingredientService.getAllIngredients();
    }
  }

  void _showAnimatedDialog(Ingredient ingredient) {
    _controller.forward();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return ScaleTransition(
          scale: _animation,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
                minHeight: 100, // Minimum height for the dialog
                maxWidth: MediaQuery.of(context).size.width * 0.85, // Sabit genişlik
                minWidth: MediaQuery.of(context).size.width * 0.85, // Sabit genişlik
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        ingredient.ingredientName ?? 'İsim yok',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                ingredient.ingredientDescription ?? 'Açıklama yok',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text.rich(
                        TextSpan(
                          text: 'Bu içerik ',
                          style: TextStyle(fontSize: 16),
                          children: <TextSpan>[
                            TextSpan(
                              text: ingredient.isHarmful ?? false ? 'şüpheli ' : 'güvenli ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: ingredient.isHarmful ?? false ? 'olabilir.' : 'görünüyor.',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop(); // Dialogu kapat
                          _controller.reset();
                        },
                        child: Text('Kapat', style: TextStyle(color: Colors.pink)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.pink),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0), // Yuvarlak kenarlar
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
    ).then((_) => _controller.reset());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'İçerikler',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          buildSearchBar(),
          SizedBox(height: 10),
          buildCategorySection(),
          Expanded(child: buildIngredientList()),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          labelText: 'Ara',
          hintText: 'İçerik adı',
          prefixIcon: Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear),
            onPressed: _clearSearchQuery,
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)), // Yuvarlak kenarlar
          ),
        ),
      ),
    );
  }

  Widget buildCategorySection() {
    return StreamBuilder<List<IngredientCategory>>(
      stream: _categoryService.categoryStream, // Stream kullanılıyor
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Snapshot error: ${snapshot.error}'); // Log errors
          return Center(child: Text('Hata: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('No categories found'); // Log no data
          return Center(child: Text('Kategori yok.'));
        } else {
          print('Categories loaded: ${snapshot.data}'); // Log loaded data
          return buildCategoryList(snapshot.data!);
        }
      },
    );
  }

  Widget buildCategoryList(List<IngredientCategory> categories) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isSelected = category.categoryId == _selectedCategoryId;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Stack(
              children: [
                ElevatedButton(
                  onPressed: () => _onCategorySelected(category.categoryId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.pink : Colors.white, // Seçili kategori rengi
                    side: BorderSide(color: Colors.pink), // Kenar mor
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0), // Yuvarlak kenarlar
                    ),
                  ),
                  child: Text(
                    category.categoryName ?? 'isimsiz',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.pink, // Seçili kategori metin rengi
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _clearCategorySelection,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildIngredientList() {
    return StreamBuilder<List<Ingredient>>(
      stream: _ingredientService.ingredientStream, // IngredientService içinde stream
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Snapshot error: ${snapshot.error}'); // Log errors
          return Center(child: Text('Hata: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('No ingredients found'); // Log no data
          return Center(child: Text('İçerik bulunamadı.'));
        } else {
          print('Ingredients loaded: ${snapshot.data}'); // Log loaded data
          return buildIngredientListItems(snapshot);
        }
      },
    );
  }

  Widget buildIngredientListItems(AsyncSnapshot<List<Ingredient>> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data!.length,
      itemBuilder: (BuildContext context, int index) {
        final ingredient = snapshot.data![index];
        final bool isHarmful = ingredient.isHarmful ?? false;

        return Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0), // Yuvarlak kenarlar
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            contentPadding: EdgeInsets.all(10),
            leading: CircleAvatar(
              backgroundColor: Colors.pink,
              child: Text(
                ingredient.ingredientName?.substring(0, 1) ?? 'N/A',
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              ingredient.ingredientName ?? 'İsim yok',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            trailing: isHarmful
                ? Icon(
              Icons.help_outline,
              color: Colors.orange[700],
            )
                : null,
            onTap: () {
              _showAnimatedDialog(ingredient);
            },
          ),
        );
      },
    );
  }
}
