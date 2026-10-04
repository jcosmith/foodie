/// Public API of the receipt scanning feature.
library;

export 'domain.dart';
export 'src/application/receipt_capture.dart';
export 'src/application/receipt_page_images.dart';
export 'src/application/receipt_query_service.dart';
export 'src/application/receipt_review.dart';
export 'src/application/receipt_scanning_providers.dart';
export 'src/application/receipt_use_cases.dart' hide learnedMapping;
export 'src/l10n/generated/receipt_scanning_localizations.dart';
export 'src/presentation/receipt_scanning_routes.dart' show ReceiptScanningRoutes;
export 'src/receipt_scanning_feature_module.dart';
