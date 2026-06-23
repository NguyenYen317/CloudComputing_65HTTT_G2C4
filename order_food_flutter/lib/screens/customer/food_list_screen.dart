// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension FoodListScreenBuilder on _HomePageState {
  Widget _buildShopTab() {
    return RefreshIndicator(
      onRefresh: fetchFoods,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => query = value),
            decoration: InputDecoration(
              hintText: 'Tìm món ăn, quán ăn...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffffefe7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffffd4bf)),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Deal trưa hôm nay: giảm 20.000đ cho đơn từ 150.000đ, freeship từ 200.000đ.',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Icon(Icons.local_fire_department, size: 40),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ChoiceChip(
                  label: Text(category),
                  selected: selectedCategory == category,
                  onSelected: (_) =>
                      setState(() => selectedCategory = category),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: categories.length,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Gợi ý cho bạn',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text('${filteredFoods.length} món'),
            ],
          ),
          const SizedBox(height: 8),
          ...filteredFoods.map(
            (food) => FoodCard(
              food: food,
              onAdd: () => addToCart(food),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FoodDetailScreen(
                    food: food,
                    onAdd: () => addToCart(food),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
