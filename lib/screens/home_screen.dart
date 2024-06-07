import 'package:flutter/material.dart';
import 'package:productos_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../services/services.dart';
import 'screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsService = Provider.of<ProductsServices>(context);

    if (productsService.isLoading) {
      return const LoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos',
            style: TextStyle(fontSize: 20, color: Colors.white)),
      ),
      body: ListView.builder(
        itemCount: productsService.products.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: GestureDetector(
                onTap: (){
                  productsService.selectedProduct = productsService.products[index].copy();
                  Navigator.pushNamed(context, 'product');
                },
                child:  ProductCard(
                  product: productsService.products[index],
                )),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          productsService.selectedProduct = Product(
            available: false,
            name: '',
            price: 0,
          );
          Navigator.pushNamed(context, 'product');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
