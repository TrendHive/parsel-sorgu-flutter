import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/application/auth/cubit/sign_in_cubit.dart';
import 'package:parcel_atlas/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/domain_ui/copy/exception_copy.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/domain_ui/widgets/input/parcel_info_text_field.dart';
import 'package:parcel_atlas/domain_ui/widgets/text/parcel_info_text.dart';

/// Username, password, one button. Enter in the password field signs in;
/// the browser may offer to remember both.
class SignInBody extends StatefulWidget {
  const SignInBody({super.key});

  @override
  State<SignInBody> createState() => _SignInBodyState();
}

class _SignInBodyState extends State<SignInBody> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() => context.read<SignInCubit>().submit(
    username: _username.text,
    password: _password.text,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final TextTheme text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(BaseDimens.padding.xLarge),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ParcelInfoDimens.panelMaxWidth,
          ),
          child: BlocBuilder<SignInCubit, SignInState>(
            builder: (BuildContext context, SignInState state) {
              final bool busy = state is SignInSubmitting;
              return AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(
                      Icons.map_outlined,
                      size: BaseDimens.size.large,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(height: BaseDimens.height.medium),
                    ParcelInfoText(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: text.headlineMedium,
                    ),
                    SizedBox(height: BaseDimens.height.small),
                    ParcelInfoText(
                      l10n.signInSubtitle,
                      textAlign: TextAlign.center,
                      style: text.bodyLarge,
                    ),
                    SizedBox(height: BaseDimens.height.xLarge),
                    ParcelInfoTextField(
                      controller: _username,
                      label: l10n.usernameLabel,
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.username],
                    ),
                    SizedBox(height: BaseDimens.height.medium),
                    ParcelInfoTextField(
                      controller: _password,
                      label: l10n.passwordLabel,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const <String>[AutofillHints.password],
                      onSubmitted: (_) => busy ? null : _submit(),
                      errorText: state is SignInFailed
                          ? ExceptionCopy.of(l10n, state.exception)
                          : null,
                    ),
                    SizedBox(height: BaseDimens.height.large),
                    FilledButton(
                      onPressed: busy ? null : _submit,
                      child: busy
                          ? const SizedBox.square(
                              dimension: ParcelInfoDimens.progressSize,
                              child: CircularProgressIndicator(),
                            )
                          : ParcelInfoText(l10n.signInButton),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
