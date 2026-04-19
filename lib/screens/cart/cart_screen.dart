import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatelessWidget {
  final String userId;

  const CartScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(child: _buildCartContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        'Mon Panier',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1C1C1E),
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('items')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Erreur lors du chargement.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyCart();
        }

        final cartItems = snapshot.data!.docs;

        return FutureBuilder<List<CartItemData>>(
          future: _fetchCartDetails(cartItems),
          builder: (context, detailsSnapshot) {
            if (detailsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
              );
            }

            if (detailsSnapshot.hasError || !detailsSnapshot.hasData) {
              return const Center(child: Text('Erreur lors du chargement.'));
            }

            final items = detailsSnapshot.data!;
            final total = items.fold<double>(0.0, (sum, item) => sum + item.price);

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) => CartItemCard(
                      cartItemId: items[index].cartItemId,
                      clothingId: items[index].clothingId,
                      title: items[index].title,
                      brand: items[index].brand,
                      size: items[index].size,
                      price: items[index].price,
                      imageUrl: items[index].imageUrl,
                      userId: userId,
                    ),
                  ),
                ),
                _buildTotalSection(total),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.shopping_bag_outlined, size: 40, color: Color(0xFF8E8E93)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Votre panier est vide',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ajoutez des articles pour commencer',
            style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection(double total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
                ),
                Text(
                  '${total.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Commander',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<CartItemData>> _fetchCartDetails(
      List<QueryDocumentSnapshot> cartItems) async {
    final List<CartItemData> items = [];

    for (var doc in cartItems) {
      final data = doc.data() as Map<String, dynamic>;
      final clothingId = data['clothingId'] as String;

      try {
        final clothingDoc = await FirebaseFirestore.instance
            .collection('clothes')
            .doc(clothingId)
            .get();

        if (clothingDoc.exists) {
          final clothingData = clothingDoc.data() as Map<String, dynamic>;
          items.add(CartItemData(
            cartItemId: doc.id,
            clothingId: clothingId,
            title: clothingData['title'] ?? 'Sans titre',
            brand: clothingData['brand'] ?? '',
            size: clothingData['size'] ?? '-',
            price: (clothingData['price'] ?? 0).toDouble(),
            imageUrl: clothingData['image'] ?? '',
          ));
        }
      } catch (e) {
        debugPrint('Error fetching clothing $clothingId: $e');
      }
    }

    return items;
  }
}

class CartItemData {
  final String cartItemId;
  final String clothingId;
  final String title;
  final String brand;
  final String size;
  final double price;
  final String imageUrl;

  CartItemData({
    required this.cartItemId,
    required this.clothingId,
    required this.title,
    required this.brand,
    required this.size,
    required this.price,
    required this.imageUrl,
  });
}

class CartItemCard extends StatelessWidget {
  final String cartItemId;
  final String clothingId;
  final String title;
  final String brand;
  final String size;
  final double price;
  final String imageUrl;
  final String userId;

  const CartItemCard({
    super.key,
    required this.cartItemId,
    required this.clothingId,
    required this.title,
    required this.brand,
    required this.size,
    required this.price,
    required this.imageUrl,
    required this.userId,
  });

  Future<void> _removeFromCart(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(cartItemId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Article retiré du panier'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Taille $size',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8E8E93),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${price.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _removeFromCart(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image_outlined, color: Color(0xFFAAAAAA), size: 32),
    );
  }
}
