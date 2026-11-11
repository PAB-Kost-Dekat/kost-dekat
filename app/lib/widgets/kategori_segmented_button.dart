import 'package:flutter/material.dart';

enum TipeKosFilter { semua, putra, putri, campur }

class KategoriSegmentedButton extends StatelessWidget {
  final TipeKosFilter selectedFilter;
  final ValueChanged<TipeKosFilter> onSelectionChanged;

  const KategoriSegmentedButton({
    super.key,
    required this.selectedFilter,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SegmentedButton<TipeKosFilter>(
        segments: const [
          ButtonSegment(value: TipeKosFilter.semua, label: Text('Semua')),
          ButtonSegment(value: TipeKosFilter.putra, label: Text('Putra')),
          ButtonSegment(value: TipeKosFilter.putri, label: Text('Putri')),
          ButtonSegment(value: TipeKosFilter.campur, label: Text('Campur')),
        ],
        selected: {selectedFilter},
        onSelectionChanged: (Set<TipeKosFilter> newSelection) {
          onSelectionChanged(newSelection.first);
        },
      ),
    );
  }
}
