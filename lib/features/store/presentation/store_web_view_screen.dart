import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';

/// In-app storefront that loads the Shopify product page so the user can
/// complete a purchase without feeling like they left the app.
///
/// When the Shopify checkout reaches its confirmation ("thank you") page we
/// treat the purchase as complete and move the user on to login, replacing the
/// navigation stack so the back gesture can't return to the checkout.
class StoreWebViewScreen extends StatefulWidget {
  const StoreWebViewScreen({super.key});

  /// Shopify product page that opens the ritual-system purchase flow.
  static const String productUrl =
      'https://hikarulift.com/products/the-hikaru-lift-ritual-system';

  @override
  State<StoreWebViewScreen> createState() => _StoreWebViewScreenState();
}

class _StoreWebViewScreenState extends State<StoreWebViewScreen> {
  late final WebViewController _controller;

  bool _loading = true;
  bool _hasError = false;
  bool _purchaseHandled = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.darkIndigoBlue)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            _maybeHandlePurchase(url);
            if (!mounted) return;
            setState(() {
              _loading = true;
              _hasError = false;
            });
          },
          onUrlChange: (change) {
            final url = change.url;
            if (url != null) _maybeHandlePurchase(url);
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            // Only surface errors for the main document, not sub-resources
            // (ads, trackers, fonts) that frequently fail without breaking
            // the page.
            if (error.isForMainFrame == false) return;
            if (!mounted) return;
            setState(() {
              _loading = false;
              _hasError = true;
            });
          },
        ),
      );
    _load();
  }

  void _load() {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    _controller.loadRequest(Uri.parse(StoreWebViewScreen.productUrl));
  }

  /// Returns true when [url] looks like a completed Shopify checkout.
  ///
  /// Shopify sends shoppers to a confirmation page once payment goes through.
  /// Its exact shape varies by store and checkout version, so we match on a
  /// set of known markers rather than a single fixed URL. Adjust this list if
  /// the live checkout redirects somewhere else.
  static bool _isPurchaseComplete(String url) {
    final lower = url.toLowerCase();
    const markers = <String>[
      '/thank_you',
      '/thank-you',
      'order-confirmation',
      'order_confirmation',
      'checkouts/thank',
      '/orders/', // post-purchase order status page
    ];
    return markers.any(lower.contains);
  }

  void _maybeHandlePurchase(String url) {
    if (_purchaseHandled) return;
    if (!_isPurchaseComplete(url)) return;
    _purchaseHandled = true;
    // Defer so we don't navigate during a WebView callback / build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go(AppRoutes.login);
    });
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.ritual);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        // Let the in-page back button work before leaving the store.
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else if (mounted) {
          _close();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.darkIndigoBlue,
        body: SafeArea(
          child: Column(
            children: [
              _StoreHeader(
                title: l10n.storeTitle,
                closeLabel: l10n.storeClose,
                onClose: _close,
              ),
              Expanded(
                child: Stack(
                  children: [
                    if (!_hasError)
                      WebViewWidget(controller: _controller)
                    else
                      _StoreError(
                        message: l10n.storeLoadError,
                        retryLabel: l10n.storeRetry,
                        onRetry: _load,
                      ),
                    if (_loading && !_hasError)
                      const ColoredBox(
                        color: AppColors.darkIndigoBlue,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.champagneGold,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({
    required this.title,
    required this.closeLabel,
    required this.onClose,
  });

  final String title;
  final String closeLabel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.s56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
      decoration: const BoxDecoration(
        color: AppColors.darkIndigoBlue,
        border: Border(
          bottom: BorderSide(color: AppColors.champagneGold, width: 0.4),
        ),
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: closeLabel,
            child: IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: AppColors.champagneGold),
              tooltip: closeLabel,
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.pathLabel.copyWith(
                color: AppColors.fog,
                letterSpacing: 2.4,
              ),
            ),
          ),
          // Balances the leading close button so the title stays centered.
          const SizedBox(width: AppSpacing.s44),
        ],
      ),
    );
  }
}

class _StoreError extends StatelessWidget {
  const _StoreError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.fog),
            ),
            const SizedBox(height: AppSpacing.s24),
            TextButton(
              onPressed: onRetry,
              child: Text(
                retryLabel,
                style: AppTypography.pathLabel.copyWith(
                  color: AppColors.champagneGold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
