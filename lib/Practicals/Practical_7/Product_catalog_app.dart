import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const ProductCatalogApp());
}

class ProductCatalogApp extends StatelessWidget {
  const ProductCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Catalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      home: const ProductCatalogScreen(),
    );
  }
}

class Product {
  final String title;
  final String price;
  final String imageUrl;
  final String description;
  bool isFavorite;

  Product({
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.description,
    this.isFavorite = false,
  });
}

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final List<Product> products = [
    Product(
      title: "Apple iPhone 15 Pro",
      price: "\$999",
      imageUrl:
          "https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-pro-max-finish-select-202309-6-1inch?wid=940&hei=1112&fmt=png-alpha&.v=1692927175536",
      description:
          "Apple's latest flagship smartphone with A17 Pro chip, 48MP camera, and titanium design.",
    ),
    Product(
      title: "Sony WH-1000XM5 Headphones",
      price: "\$399",
      imageUrl:
          "https://m.media-amazon.com/images/I/71o8Q5XJS5L._AC_SL1500_.jpg",
      description:
          "Industry-leading noise cancellation, 30 hours battery, and premium sound quality.",
    ),
    Product(
      title: "Samsung Galaxy Watch 6",
      price: "\$299",
      imageUrl:
          "https://images.samsung.com/is/image/samsung/p6pim/in/galaxy-watch6-r930-sm-r930nzaainu-thumb-537727237?wid=720&hei=720",
      description:
          "Advanced health tracking, AMOLED display, and long battery life.",
    ),
    Product(
      title: "Canon EOS R8 Mirrorless Camera",
      price: "\$1499",
      imageUrl:
          "https://m.media-amazon.com/images/I/81QpFQwQJGL._AC_SL1500_.jpg",
      description:
          "Full-frame sensor, 24.2MP, 4K video, and fast autofocus for creators.",
    ),
    Product(
      title: "JBL Flip 6 Bluetooth Speaker",
      price: "\$129",
      imageUrl:
          "https://m.media-amazon.com/images/I/71QKQ9mwV7L._AC_SL1500_.jpg",
      description:
          "Waterproof, powerful bass, and 12 hours playtime for outdoor fun.",
    ),
    Product(
      title: "Oculus Quest 2 VR Headset",
      price: "\$399",
      imageUrl:
          "https://m.media-amazon.com/images/I/61z0pK9QGvL._AC_SL1500_.jpg",
      description:
          "Wireless VR gaming, 128GB storage, and immersive experiences.",
    ),
  ];

  final List<Product> cart = [];

  void toggleFavorite(Product product) {
    setState(() {
      product.isFavorite = !product.isFavorite;
    });
  }

  void addToCart(Product product) {
    setState(() {
      cart.add(product);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Added to cart: ${product.title}")));
  }

  void removeFromCart(Product product) {
    setState(() {
      cart.remove(product);
    });
  }

  void goToCartPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartPage(cart: cart, onRemove: removeFromCart),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Product Catalog"),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: goToCartPage,
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cart.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onFavorite: () => toggleFavorite(product),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(
                        product: product,
                        onAddToCart: () => addToCart(product),
                        onFavorite: () => toggleFavorite(product),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: product.title,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    height: 140,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: onFavorite,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        product.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        key: ValueKey(product.isFavorite),
                        color: product.isFavorite ? Colors.red : Colors.grey,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.price,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onFavorite;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              product.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: product.isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: onFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: product.title,
              child: Image.network(
                product.imageUrl,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.price,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: const Text(
                      "Add to Cart",
                      style: TextStyle(fontSize: 18),
                    ),
                    onPressed: onAddToCart,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  final List<Product> cart;
  final Function(Product) onRemove;

  const CartPage({super.key, required this.cart, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: cart.isEmpty
          ? const Center(
              child: Text("Your cart is empty", style: TextStyle(fontSize: 20)),
            )
          : ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final product = cart[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: Image.network(
                      product.imageUrl,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(product.title),
                    subtitle: Text(product.price),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onRemove(product),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.payment),
                label: const Text("Checkout", style: TextStyle(fontSize: 18)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Checkout is not implemented."),
                    ),
                  );
                },
              ),
            )
          : null,
    );
  }
}
