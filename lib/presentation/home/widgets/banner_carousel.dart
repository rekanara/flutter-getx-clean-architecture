import 'dart:async';

import 'package:flutter/material.dart';

import '../../../components/molecules/custom_cached_image.dart';
import '../../../domain/home/entities/banner_entity.dart';

/// Widget carousel untuk menampilkan list banner dengan auto-slide.
///
/// Fitur:
/// - Auto-slide setiap 4 detik
/// - Swipe manual kiri/kanan
/// - Dot indicator animated
/// - Cached network image
class BannerCarousel extends StatefulWidget {
  final List<BannerEntity> banners;

  const BannerCarousel({super.key, required this.banners});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final Timer _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    // Auto-slide setiap 4 detik
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.banners.isEmpty) return;
      final nextPage = (_currentPage + 1) % widget.banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── PageView ──
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CustomCachedImage(
                  imageUrl: banner.bannerUrl,
                  width: double.infinity,
                  height: 180,
                  borderRadius: 16,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // ── Dot Indicators ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 8,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
