import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../domain/entities/customer_details.dart';
import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart';

/// Step 2 of the buy flow: collects the customer's contact details, then
/// moves on to the order review.
///
/// Prefilled from the details saved in [CheckoutBloc], so they survive going
/// back and starting a new checkout.
class CustomerDetailsScreen extends StatefulWidget {
  const CustomerDetailsScreen({super.key});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Errors only show up once the customer has tried to continue.
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  late final TextEditingController _fullName;
  late final TextEditingController _email;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final customer = context.read<CheckoutBloc>().state.customer;
    _fullName = TextEditingController(text: customer?.fullName);
    _email = TextEditingController(text: customer?.email);
    _phone = TextEditingController(text: customer?.phone);
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    TextInput.finishAutofillContext();
    context.read<CheckoutBloc>().add(
      CheckoutCustomerDetailsSubmitted(
        CustomerDetails(
          fullName: _fullName.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
        ),
      ),
    );
    Navigator.of(context).pushNamed(AppRoutes.orderSummary);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact details')),
      body: AutofillGroup(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppLayout.pagePadding),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ResponsiveCenter(
              maxWidth: AppLayout.formMaxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  _DetailsTextField(
                    fieldKey: const ValueKey('field-fullName'),
                    controller: _fullName,
                    label: 'Full name',
                    autofillHints: const [AutofillHints.name],
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    validator: Validators.fullName,
                  ),
                  _DetailsTextField(
                    fieldKey: const ValueKey('field-email'),
                    controller: _email,
                    label: 'Email',
                    autofillHints: const [AutofillHints.email],
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    validator: Validators.email,
                  ),
                  _DetailsTextField(
                    fieldKey: const ValueKey('field-phone'),
                    controller: _phone,
                    label: 'Mobile number',
                    autofillHints: const [
                      AutofillHints.telephoneNumberNational,
                    ],
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: Validators.phone,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        maxWidth: AppLayout.formMaxWidth,
        action: FilledButton(onPressed: _submit, child: const Text('Continue')),
      ),
    );
  }
}

/// A [TextFormField] with the decoration and keyboard behaviour shared by
/// every field on this form. [fieldKey] goes on the [TextFormField] itself.
class _DetailsTextField extends StatelessWidget {
  const _DetailsTextField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.autofillHints,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.inputFormatters,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.validator,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final List<String> autofillHints;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      decoration: InputDecoration(labelText: label, errorMaxLines: 3),
      autofillHints: autofillHints,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      autocorrect: autocorrect,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
    );
  }
}
