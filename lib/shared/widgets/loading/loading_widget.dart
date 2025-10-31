import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingListTile extends StatelessWidget {
  const LoadingListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Colors.white, radius: 24),
        title: Container(
          height: 16,
          width: double.infinity,
          color: Colors.white,
        ),
        subtitle: Container(
          height: 12,
          width: double.infinity,
          color: Colors.white,
        ),
      ),
    );
  }
}

class LoadingGridView extends StatelessWidget {
  final int itemCount;
  const LoadingGridView({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 3 / 2,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          );
        },
      ),
    );
  }
}
