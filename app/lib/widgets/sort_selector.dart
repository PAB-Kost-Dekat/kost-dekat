import 'package:flutter/material.dart';

enum SortOption { hargaAsc, hargaDesc, jarakTerdekat }

class SortSelector extends StatelessWidget {
  final SortOption currentSort;
  final ValueChanged<SortOption?> onSortChanged;

  const SortSelector({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            'Urutkan: ',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          DropdownButton<SortOption>(
            value: currentSort,
            items: const [
              DropdownMenuItem(
                value: SortOption.jarakTerdekat,
                child: Text('Jarak Terdekat'),
              ),
              DropdownMenuItem(
                value: SortOption.hargaAsc,
                child: Text('Harga Terendah'),
              ),
              DropdownMenuItem(
                value: SortOption.hargaDesc,
                child: Text('Harga Tertinggi'),
              ),
            ],
            onChanged: onSortChanged,
          ),
        ],
      ),
    );
  }
}
