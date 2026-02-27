import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Reusable Component untuk menampilkan gambar dari jaringan (URL)
/// dengan fitur caching otomastis menggunakan [CachedNetworkImage].
///
/// Termasuk default handling untuk status Loading (Placeholder) dan Error.
class CustomCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeDuration;

  const CustomCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8.0,
    this.placeholder,
    this.errorWidget,
    this.fadeDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: fadeDuration,
        placeholder: (context, url) =>
            placeholder ?? _buildDefaultPlaceholder(),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildDefaultError(),
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.broken_image_rounded, color: Colors.grey),
      ),
    );
  }
}
