import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/product_form_provider.dart';
import '../services/services.dart';
import '../ui/input_decorations.dart';
import '../widgets/widgets.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductsServices>(context);
    return ChangeNotifierProvider(
      create: (_) => ProductFormProvider(productService.selectedProduct!),
      child: _ProductScreenBody(productService: productService),
    );
  }
}

class _ProductScreenBody extends StatelessWidget {
  const _ProductScreenBody({
    super.key,
    required this.productService,
  });

  final ProductsServices productService;

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  ProductImage(
                    url: productService.selectedProduct?.picture,
                  ),
                  Positioned(
                    top: 60,
                    left: 20,
                    child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios,
                            size: 40, color: Colors.white)),
                  ),
                  Positioned(
                    top: 60,
                    right: 20,
                    child: IconButton(
                      onPressed: null,
                      icon: IconButton(
                          onPressed: () async {
                            final picker = ImagePicker();
                            final PickedFile? pickedFile =
                                // ignore: deprecated_member_use
                                await picker.getImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 100);
                            if (pickedFile == null) {
                              print('No selecciono nada');
                              return;
                            }
                            print('Tenemos imagen ${pickedFile.path}');
                            productService
                                .updateSelectedProductImage(pickedFile.path);
                          },
                          icon: const Icon(Icons.camera_alt,
                              size: 40, color: Colors.white)),
                      iconSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const _ProductForm(),
              const SizedBox(height: 100),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: productService.isSaving
              ? null
              : () async {
                  if (!productForm.isValidForm()) return;
                  final String? imageUrl = await productService.uploadImage();
                  if (imageUrl != null) productForm.product.picture = imageUrl;
                  await productService.saveOrCreateProduct(productForm.product);
                },
          backgroundColor: Colors.indigo,
          child: productService.isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : const Icon(Icons.save_outlined, size: 30, color: Colors.white),
        ));
  }
}

class _ProductForm extends StatelessWidget {
  const _ProductForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);
    final product = productForm.product;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: _buildBoxDecoration(),
        child: Form(
            key: productForm.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: product.name,
                    onChanged: (value) => product.name = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                    decoration: InputDecorations.authInputDecoration(
                      hintText: 'Nombre del producto',
                      labelText: 'Nombre:',
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    initialValue: '${product.price}',
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^(\d+)?\.?\d{0,2}'))
                    ],
                    onChanged: (value) {
                      if (double.tryParse(value) == null) {
                        product.price = 0;
                      } else {
                        product.price = double.parse(value);
                      }
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecorations.authInputDecoration(
                        hintText: '\$150', labelText: 'Precio:'),
                  ),
                  const SizedBox(height: 30),
                  SwitchListTile.adaptive(
                    title: const Text('Disponible'),
                    activeColor: Colors.indigo,
                    value: product.available,
                    onChanged: productForm.updateAvailability,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            )),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(25), bottomLeft: Radius.circular(25)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}
