import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:revive_sunnah_reminder/core/constants/app_constants.dart';

/// Enum for different types of haptic feedback
enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  vibrate,
}

/// Service for managing accessibility features
class AccessibilityService {
  static AccessibilityService? _instance;
  static AccessibilityService get instance =>
      _instance ??= AccessibilityService._();

  AccessibilityService._();

  final LoggingService _logger = LoggingService.instance;

  /// Initialize accessibility service
  void initialize() {
    _logger.info('Accessibility service initialized');
  }

  /// Announce text to screen readers
  void announceToScreenReader(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
    _logger.debug('Announced to screen reader: $message');
  }

  /// Provide haptic feedback
  void provideHapticFeedback(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }

  /// Create accessible button with proper semantics
  Widget createAccessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    String? semanticLabel,
    String? tooltip,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      excludeSemantics: excludeSemantics,
      child: Tooltip(
        message: tooltip ?? '',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed != null
                ? () {
                    provideHapticFeedback(HapticFeedbackType.selectionClick);
                    onPressed();
                  }
                : null,
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: AppConstants.minTouchTargetSize,
                minWidth: AppConstants.minTouchTargetSize,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// Create accessible text with proper contrast and sizing
  Widget createAccessibleText(
    String text, {
    TextStyle? style,
    String? semanticLabel,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
  }) {
    return Semantics(
      label: semanticLabel ?? text,
      readOnly: true,
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      ),
    );
  }

  /// Create accessible form field
  Widget createAccessibleFormField({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    String? helperText,
    String? errorText,
    bool obscureText = false,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
    bool readOnly = false,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return Semantics(
      textField: true,
      label: labelText,
      hint: hintText,
      value: controller.text,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          helperText: helperText,
          errorText: errorText,
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
        ),
      ),
    );
  }

  /// Create accessible list item
  Widget createAccessibleListItem({
    required Widget child,
    required VoidCallback? onTap,
    String? semanticLabel,
    bool selected = false,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onTap != null,
      selected: selected,
      child: Material(
        color:
            selected ? Colors.green.withValues(alpha: 0.1) : Colors.transparent,
        child: InkWell(
          onTap: onTap != null
              ? () {
                  provideHapticFeedback(HapticFeedbackType.selectionClick);
                  onTap();
                }
              : null,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppConstants.minTouchTargetSize,
            ),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Create accessible card
  Widget createAccessibleCard({
    required Widget child,
    VoidCallback? onTap,
    String? semanticLabel,
    String? semanticHint,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: onTap != null,
      child: Card(
        elevation: AppConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: onTap != null
            ? InkWell(
                onTap: () {
                  provideHapticFeedback(HapticFeedbackType.selectionClick);
                  onTap();
                },
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultBorderRadius),
                child: child,
              )
            : child,
      ),
    );
  }

  /// Create accessible switch
  Widget createAccessibleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    String? label,
    String? semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel ?? label,
      toggled: value,
      child: Row(
        children: [
          if (label != null) ...[
            Expanded(
              child: createAccessibleText(
                label,
                style: const TextStyle(fontSize: AppConstants.bodyTextSize),
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
          ],
          Switch(
            value: value,
            onChanged: (newValue) {
              provideHapticFeedback(HapticFeedbackType.selectionClick);
              announceToScreenReader(
                  '${label ?? 'Setting'} ${newValue ? 'enabled' : 'disabled'}');
              onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }

  /// Create accessible slider
  Widget createAccessibleSlider({
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    String? label,
    String? semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel ?? label,
      value: value.toString(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            createAccessibleText(
              label,
              style: const TextStyle(fontSize: AppConstants.bodyTextSize),
            ),
            const SizedBox(height: AppConstants.smallPadding),
          ],
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: (newValue) {
              provideHapticFeedback(HapticFeedbackType.selectionClick);
              onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }

  /// Create accessible loading indicator
  Widget createAccessibleLoadingIndicator({
    String? semanticLabel,
    double? value,
  }) {
    return Semantics(
      label: semanticLabel ?? 'Loading',
      child: Center(
        child: CircularProgressIndicator(
          value: value,
          semanticsLabel: semanticLabel,
        ),
      ),
    );
  }

  /// Create accessible snackbar
  SnackBar createAccessibleSnackBar({
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Announce to screen reader
    announceToScreenReader(message);

    return SnackBar(
      content: createAccessibleText(message),
      duration: duration,
      action: actionLabel != null && onActionPressed != null
          ? SnackBarAction(
              label: actionLabel,
              onPressed: () {
                provideHapticFeedback(HapticFeedbackType.selectionClick);
                onActionPressed();
              },
            )
          : null,
    );
  }

  /// Create accessible dialog
  AlertDialog createAccessibleDialog({
    String? title,
    required String content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return AlertDialog(
      title: title != null
          ? createAccessibleText(
              title,
              style: const TextStyle(
                fontSize: AppConstants.headingTextSize,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      content: createAccessibleText(content),
      actions: [
        if (cancelText != null)
          createAccessibleButton(
            onPressed: onCancel,
            semanticLabel: 'Cancel: $cancelText',
            child: Text(cancelText),
          ),
        if (confirmText != null)
          createAccessibleButton(
            onPressed: onConfirm,
            semanticLabel: 'Confirm: $confirmText',
            child: Text(confirmText),
          ),
      ],
    );
  }

  /// Check if device has accessibility features enabled
  bool isAccessibilityEnabled(BuildContext context) {
    final data = MediaQuery.of(context);
    return data.accessibleNavigation ||
        data.boldText ||
        data.highContrast ||
        data.textScaler.scale(1.0) > 1.0;
  }

  /// Get accessible theme data
  ThemeData getAccessibleTheme(BuildContext context, {required bool isDark}) {
    final isAccessibilityEnabled = this.isAccessibilityEnabled(context);

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primarySwatch: Colors.green,
      visualDensity: isAccessibilityEnabled
          ? VisualDensity.comfortable
          : VisualDensity.standard,
      textTheme: Theme.of(context).textTheme.copyWith(
            bodyLarge: TextStyle(
              fontSize: isAccessibilityEnabled ? 18 : AppConstants.bodyTextSize,
              height: 1.5,
            ),
            bodyMedium: TextStyle(
              fontSize:
                  isAccessibilityEnabled ? 16 : AppConstants.captionTextSize,
              height: 1.5,
            ),
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(
            AppConstants.minTouchTargetSize,
            AppConstants.minTouchTargetSize,
          ),
          padding: EdgeInsets.all(
            isAccessibilityEnabled
                ? AppConstants.largePadding
                : AppConstants.defaultPadding,
          ),
        ),
      ),
    );
  }
}

/// Navigation service for accessing current context
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
