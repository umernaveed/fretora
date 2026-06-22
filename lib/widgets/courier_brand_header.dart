import 'package:flutter/material.dart';

import '../core/network/api_models.dart';

class CourierBrandHeader extends StatelessWidget {
  const CourierBrandHeader({
    super.key,
    required this.courier,
    this.title,
    this.subtitle,
    this.compact = false,
  });

  final CourierWorkspace? courier;
  final String? title;
  final String? subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = title ?? courier?.companyName ?? 'Customer Portal';
    final code = subtitle ?? courier?.courierCode;
    final logoUrl = courier?.logoUrl;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 16 : 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 14 : 18),
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          _LogoBox(logoUrl: logoUrl, compact: compact),
          SizedBox(width: compact ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                if (code != null && code.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(.84),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoBox extends StatelessWidget {
  const _LogoBox({required this.logoUrl, required this.compact});

  final String? logoUrl;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 48.0 : 64.0;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: logoUrl == null || logoUrl!.isEmpty
          ? Icon(Icons.local_shipping, color: Theme.of(context).colorScheme.primary, size: compact ? 26 : 34)
          : Image.network(
              logoUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.local_shipping,
                color: Theme.of(context).colorScheme.primary,
                size: compact ? 26 : 34,
              ),
            ),
    );
  }
}
