import 'package:get_it/get_it.dart';

/// The one container, and the only place a dependency is looked up.
///
/// The app's `main.dart` is the composition root: it is the only code that
/// sees every package, so it registers the infrastructure implementations
/// against the domain's ports and the use cases and Cubits on top of them.
/// Pages resolve their Cubit here inside their `BlocProvider`; everything
/// else receives its dependencies through its constructor, so a test can hand
/// in fakes.
final GetIt getIt = GetIt.instance;
