import 'package:flutter/material.dart';

class AreaChipList extends StatelessWidget {
  final List<String> areas;
  final String? selectedArea;
  final ValueChanged<String?> onAreaSelected;

  const AreaChipList({
    super.key,
    required this.areas,
    required this.selectedArea,
    required this.onAreaSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: areas.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            bool isSelected = selectedArea == null;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: const Text('Semua Area'),
                selected: isSelected,
                onSelected: (_) => onAreaSelected(null),
              ),
            );
          }
          final area = areas[index - 1];
          final isSelected = selectedArea == area;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(area),
              selected: isSelected,
              onSelected: (_) => onAreaSelected(area),
            ),
          );
        },
      ),
    );
  }
}
