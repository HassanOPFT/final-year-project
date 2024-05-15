import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/address_provider.dart';
import 'custom_progress_indicator.dart';
import '../models/address.dart';
import '../providers/customer_provider.dart';
import '../utils/snackbar.dart';
import '../views/common/google_maps_screen.dart';

class AddressForm extends StatefulWidget {
  final Address? selectedAddress;
  final AddressPurpose addressPurpose;
  final AddressAction addressAction;

  const AddressForm({
    super.key,
    required this.selectedAddress,
    required this.addressPurpose,
    required this.addressAction,
  });

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  bool _defaultAddress = true;
  bool saveAddressLoading = false;

  late TextEditingController addressLabelController;
  late TextEditingController streetController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController postalCodeController;
  late TextEditingController countryController;

  late FocusNode _addressLabelFocusNode;
  late FocusNode _streetFocusNode;
  late FocusNode _cityFocusNode;
  late FocusNode _stateFocusNode;
  late FocusNode _postalCodeFocusNode;
  late FocusNode _countryFocusNode;

  @override
  void initState() {
    super.initState();
    addressLabelController = TextEditingController(
      text: widget.selectedAddress?.street ?? '',
    );
    streetController = TextEditingController(
      text: widget.selectedAddress?.street ?? '',
    );
    cityController = TextEditingController(
      text: widget.selectedAddress?.city ?? '',
    );
    stateController = TextEditingController(
      text: widget.selectedAddress?.state ?? '',
    );
    postalCodeController = TextEditingController(
      text: widget.selectedAddress?.postalCode ?? '',
    );
    countryController = TextEditingController(
      text: widget.selectedAddress?.country ?? '',
    );

    _addressLabelFocusNode = FocusNode();
    _streetFocusNode = FocusNode();
    _cityFocusNode = FocusNode();
    _stateFocusNode = FocusNode();
    _postalCodeFocusNode = FocusNode();
    _countryFocusNode = FocusNode();
  }

  @override
  void dispose() {
    addressLabelController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    countryController.dispose();

    _addressLabelFocusNode.dispose();
    _streetFocusNode.dispose();
    _cityFocusNode.dispose();
    _stateFocusNode.dispose();
    _postalCodeFocusNode.dispose();
    _countryFocusNode.dispose();
    super.dispose();
  }

  void updateSaveAddressLoading(bool value) {
    setState(() {
      saveAddressLoading = value;
    });
  }

  void popOneTime() {
    Navigator.of(context).pop();
  }

  void popTwoTimes() {
    popOneTime();
    popOneTime();
  }

  void _createUserAddress(Address address, bool defaultAddress) async {
    try {
      updateSaveAddressLoading(true);
      final addressProvider = Provider.of<AddressProvider>(
        context,
        listen: false,
      );
      final newAddressId = await addressProvider.createAddress(address);
      // Set default address if selected
      if (defaultAddress) {
        if (mounted) {
          final customerProvider = Provider.of<CustomerProvider>(
            context,
            listen: false,
          );
          await customerProvider.setDefaultAddress(
            userId: address.linkedObjectId as String,
            addressId: newAddressId,
          );
        }
      }
      updateSaveAddressLoading(false);
      if (mounted) {
        popTwoTimes();
        buildSuccessSnackbar(
          context: context,
          message: 'Address saved successfully.',
        );
      }
    } catch (e) {
      updateSaveAddressLoading(false);
      if (mounted) {
        popOneTime();
        buildFailureSnackbar(
          context: context,
          message:
              'Error occurred while saving address. Please try again later.',
        );
      }
    }
  }

  void _updateUserAddress(Address address, bool defaultAddress) async {
    try {
      updateSaveAddressLoading(true);
      final addressProvider = Provider.of<AddressProvider>(
        context,
        listen: false,
      );
      await addressProvider.updateAddress(address);
      // Set default address if selected
      if (defaultAddress) {
        if (mounted) {
          final customerProvider = Provider.of<CustomerProvider>(
            context,
            listen: false,
          );
          await customerProvider.setDefaultAddress(
            userId: address.linkedObjectId as String,
            addressId: address.id as String,
          );
        }
      }
      updateSaveAddressLoading(false);
      if (mounted) {
        popTwoTimes();
        buildSuccessSnackbar(
          context: context,
          message: 'Address updated successfully.',
        );
      }
    } catch (e) {
      updateSaveAddressLoading(false);
      if (mounted) {
        popOneTime();
        buildFailureSnackbar(
          context: context,
          message:
              'Error occurred while updating address. Please try again later.',
        );
      }
    }
  }

  void _createCarAddress(Address address, bool defaultAddress) async {}
  void _updateCarAddress(Address address, bool defaultAddress) async {}

  void _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final address = Address(
      id: widget.selectedAddress?.id ?? '',
      label: addressLabelController.text.trim(),
      street: streetController.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      postalCode: postalCodeController.text.trim(),
      country: countryController.text.trim(),
      latitude: widget.selectedAddress?.latitude,
      longitude: widget.selectedAddress?.longitude,
      linkedObjectId: widget.selectedAddress?.linkedObjectId,
    );

    if (address.latitude == null ||
        address.longitude == null ||
        address.linkedObjectId == null) {
      buildFailureSnackbar(
        context: context,
        message: 'Error occurred while saving address. Please try again later.',
      );
      return;
    }
    switch (widget.addressAction) {
      case AddressAction.create:
        switch (widget.addressPurpose) {
          case AddressPurpose.user:
            // Create user address
            _createUserAddress(address, _defaultAddress);
            break;
          case AddressPurpose.car:
            // Create car address
            _createCarAddress(address, _defaultAddress);
            break;
        }
        break;
      case AddressAction.update:
        switch (widget.addressPurpose) {
          case AddressPurpose.user:
            // update user address
            _updateUserAddress(address, _defaultAddress);
            break;
          case AddressPurpose.car:
            // update car address
            _updateCarAddress(address, _defaultAddress);
            break;
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Address Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15.0),
            const Divider(),
            const SizedBox(height: 20.0),
            TextFormField(
              focusNode: _addressLabelFocusNode,
              textInputAction: TextInputAction.next,
              validator: _validateAddressLabel,
              onFieldSubmitted: (_) {
                _addressLabelFocusNode.unfocus();
                FocusScope.of(context).requestFocus(_streetFocusNode);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                labelText: 'Address Label',
              ),
              controller: addressLabelController,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              focusNode: _streetFocusNode,
              textInputAction: TextInputAction.next,
              validator: _validateStreet,
              onFieldSubmitted: (_) {
                _streetFocusNode.unfocus();
                FocusScope.of(context).requestFocus(_cityFocusNode);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                labelText: 'Street',
              ),
              controller: streetController,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              focusNode: _cityFocusNode,
              textInputAction: TextInputAction.next,
              validator: _validateCity,
              onFieldSubmitted: (_) {
                _cityFocusNode.unfocus();
                FocusScope.of(context).requestFocus(_stateFocusNode);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                labelText: 'City',
              ),
              controller: cityController,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              focusNode: _stateFocusNode,
              textInputAction: TextInputAction.next,
              validator: _validateState,
              onFieldSubmitted: (_) {
                _stateFocusNode.unfocus();
                FocusScope.of(context).requestFocus(_postalCodeFocusNode);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                labelText: 'State',
              ),
              controller: stateController,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              focusNode: _postalCodeFocusNode,
              textInputAction: TextInputAction.next,
              validator: _validatePostalCode,
              onFieldSubmitted: (_) {
                _postalCodeFocusNode.unfocus();
                FocusScope.of(context).requestFocus(_countryFocusNode);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                labelText: 'Postal Code',
              ),
              controller: postalCodeController,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              focusNode: _countryFocusNode,
              textInputAction: TextInputAction.done,
              validator: _validateCountry,
              onFieldSubmitted: (_) {
                _countryFocusNode.unfocus();
                _saveAddress();
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                labelText: 'Country',
              ),
              controller: countryController,
            ),
            const SizedBox(height: 5.0),
            CheckboxListTile(
              title: const Text('Save as Default Address'),
              value: _defaultAddress,
              onChanged: (newValue) {
                setState(() {
                  _defaultAddress = newValue ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 5.0),
            SizedBox(
              height: 50.0,
              child: saveAddressLoading
                  ? const CustomProgressIndicator()
                  : FilledButton(
                      onPressed: _saveAddress,
                      child: const Text(
                        'Save Address',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateAddressLabel(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the address label.';
    }
    return null;
  }

  String? _validateStreet(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the street.';
    }
    return null;
  }

  String? _validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the city.';
    }
    return null;
  }

  String? _validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the state.';
    }
    return null;
  }

  String? _validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the postal code.';
    }
    return null;
  }

  String? _validateCountry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the country.';
    }
    return null;
  }
}
