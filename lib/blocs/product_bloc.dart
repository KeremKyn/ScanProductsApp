import 'dart:async';
import 'package:scan_products_app/data/product_service.dart';
import 'package:scan_products_app/models/product.dart';

class ProductBloc {
  final productStreamController = StreamController<List<Product>>.broadcast();

  Stream<List<Product>> get getStream => productStreamController.stream;

  Future<void> fetchProducts() async {
    List<Product> products = await ProductService().getAllProducts();
    productStreamController.sink.add(products);
  }

  void dispose() {
    productStreamController.close();
  }
}

final productBloc = ProductBloc();
