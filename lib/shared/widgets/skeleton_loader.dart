import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
      highlightColor: isDark ? const Color(0xFF475569) : Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class UserListSkeleton extends StatelessWidget {
  final int itemCount;

  const UserListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                SkeletonLoader(width: 50, height: 50, borderRadius: 25),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(width: 140, height: 16),
                      SizedBox(height: 8),
                      SkeletonLoader(width: 200, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class UserDetailSkeleton extends StatelessWidget {
  const UserDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        children: [
          SizedBox(height: 20),
          SkeletonLoader(width: 100, height: 100, borderRadius: 50),
          SizedBox(height: 20),
          SkeletonLoader(width: 180, height: 24),
          SizedBox(height: 8),
          SkeletonLoader(width: 220, height: 14),
          SizedBox(height: 32),
          SkeletonLoader(width: double.infinity, height: 80, borderRadius: 16),
          SizedBox(height: 16),
          SkeletonLoader(width: double.infinity, height: 80, borderRadius: 16),
        ],
      ),
    );
  }
}
