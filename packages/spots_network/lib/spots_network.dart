// SPOTS Network Library
// Backend abstraction layer for flexible data persistence

// Core interfaces
export 'interfaces/backend_interface.dart';
export 'interfaces/auth_backend.dart';
export 'interfaces/data_backend.dart';
export 'interfaces/realtime_backend.dart';

// Backend factory
export 'backend_factory.dart';

// HTTP client
export 'clients/api_client.dart';
export 'clients/http_client.dart';

// Error handling
export 'errors/network_errors.dart';
export 'errors/backend_errors.dart';

// Models
export 'models/api_response.dart';
export 'models/connection_config.dart';
export 'models/sync_status.dart';

// Utils
export 'utils/connectivity_manager.dart';
export 'utils/request_builder.dart';
export 'utils/response_parser.dart';
