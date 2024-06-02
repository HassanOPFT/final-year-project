// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:prime/utils/assets_paths.dart';
import 'package:prime/utils/snackbar.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';
import 'package:prime/widgets/images/update_car_images.dart';
import 'package:provider/provider.dart';

import '../../models/car.dart';
import '../../models/verification_document.dart';
import '../../providers/bank_account_provider.dart';
import '../../providers/car_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/verification_document_provider.dart';
import '../../services/firebase/firebase_auth_service.dart';
import '../../widgets/section_divider.dart';

class UpdateHostCarScreen extends StatefulWidget {
  final Car car;
  const UpdateHostCarScreen({
    super.key,
    required this.car,
  });

  @override
  State<UpdateHostCarScreen> createState() => _UpdateCarScreenState();
}

class _UpdateCarScreenState extends State<UpdateHostCarScreen> {
  final _formKey = GlobalKey<FormState>();
  Car? car;
  List<String>? _imagePaths;
  final currentUserId = FirebaseAuthService().currentUser?.uid;
  bool _updateCarLoading = false;

  void setUpdateCarLoading(bool value) {
    setState(() {
      _updateCarLoading = value;
    });
  }

  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _hourPriceController = TextEditingController();
  final TextEditingController _dayPriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final _manufacturerFocusNode = FocusNode();
  final _modelFocusNode = FocusNode();
  final _yearFocusNode = FocusNode();
  final _colorFocusNode = FocusNode();
  final _engineTypeFocusNode = FocusNode();
  final _transmissionTypeFocusNode = FocusNode();
  final _seatsFocusNode = FocusNode();
  final carTypeFocusNode = FocusNode();
  final _hourPriceFocusNode = FocusNode();
  final _dayPriceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  @override
  void initState() {
    car = widget.car;
    _manufacturerController.text = car?.manufacturer ?? '';
    _modelController.text = car?.model ?? '';
    _yearController.text = car?.manufactureYear?.toString() ?? '';
    _colorController.text = car?.color ?? '';
    _seatsController.text = car?.seats?.toString() ?? '';
    _hourPriceController.text = car?.hourPrice?.toString() ?? '';
    _dayPriceController.text = car?.dayPrice?.toString() ?? '';
    _descriptionController.text = car?.description ?? '';
    _imagePaths = car?.imagesUrl ?? [];
    super.initState();
  }

  @override
  void dispose() {
    _manufacturerController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _seatsController.dispose();
    _hourPriceController.dispose();
    _dayPriceController.dispose();
    _descriptionController.dispose();
    _manufacturerFocusNode.dispose();
    _modelFocusNode.dispose();
    _yearFocusNode.dispose();
    _colorFocusNode.dispose();
    _engineTypeFocusNode.dispose();
    _transmissionTypeFocusNode.dispose();
    _seatsFocusNode.dispose();
    carTypeFocusNode.dispose();
    _hourPriceFocusNode.dispose();
    _dayPriceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _updateImagePaths(List<String> paths) {
    setState(() {
      _imagePaths = paths;
    });
  }

  String? _validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<bool> hasApprovedIdentityDocument() async {
    try {
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );

      if (currentUserId == null || currentUserId!.isEmpty) {
        return false;
      }

      final identityDocumentId = await customerProvider.getIdentityDocumentId(
        currentUserId ?? '',
      );

      if (identityDocumentId.isEmpty) {
        return false;
      }

      // Check the status of the identity document
      final verificationDocumentProvider =
          Provider.of<VerificationDocumentProvider>(
        context,
        listen: false,
      );
      final identityDocument = await verificationDocumentProvider
          .getVerificationDocumentById(identityDocumentId);

      if (identityDocument == null ||
          identityDocument.status != VerificationDocumentStatus.approved) {
        // Identity document is not approved
        return false;
      }

      return true;
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<bool> hasBankAccount() async {
    try {
      if (currentUserId == null || currentUserId!.isEmpty) {
        return false;
      }

      final bankAccountProvider = Provider.of<BankAccountProvider>(
        context,
        listen: false,
      );
      final userBankAccount =
          await bankAccountProvider.getBankAccountByHostId(currentUserId ?? '');

      if (userBankAccount == null ||
          userBankAccount.accountHolderName!.isEmpty ||
          userBankAccount.accountNumber!.isEmpty ||
          userBankAccount.bankName!.isEmpty) {
        // User has no bank account record or incomplete bank account record
        return false;
      }

      return true;
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<void> _updateCar() async {
    try {
      // validate if the user has a approved identity in the database
      final hasApprovedIdentity = await hasApprovedIdentityDocument();
      if (!hasApprovedIdentity) {
        setUpdateCarLoading(false);
        if (mounted) {
          buildAlertSnackbar(
            context: context,
            message:
                'You need to have an approved identity document to update the car.',
          );
        }
        return;
      }

      // validate if the user has a bank account in the database
      final hasBankAccountRecord = await hasBankAccount();
      if (!hasBankAccountRecord) {
        setUpdateCarLoading(false);
        if (mounted) {
          buildAlertSnackbar(
            context: context,
            message:
                'You need to have a bank account or complete bank account details to update the car.',
          );
        }
        return;
      }
      // Validate form
      if (!_formKey.currentState!.validate()) {
        return;
      }
      // validate car images between 1 and 15
      if (_imagePaths == null ||
          _imagePaths?.isEmpty == true ||
          _imagePaths!.length > 15) {
        if (mounted) {
          buildAlertSnackbar(
            context: context,
            message: 'Please select between 1 to 15 images',
          );
        }
        return;
      }

      setUpdateCarLoading(true);

      final carProvider = Provider.of<CarProvider>(
        context,
        listen: false,
      );

      await carProvider.updateCar(
        carId: widget.car.id ?? '',
        manufacturer: car?.manufacturer ?? '',
        model: car?.model ?? '',
        manufactureYear: car?.manufactureYear ?? 0,
        color: car?.color ?? '',
        engineType: car?.engineType ?? EngineType.gasoline,
        transmissionType: car?.transmissionType ?? TransmissionType.automatic,
        seats: car?.seats ?? 0,
        carType: car?.carType ?? CarType.sedan,
        hourPrice: car?.hourPrice ?? 0.0,
        dayPrice: car?.dayPrice ?? 0.0,
        carImagesPaths: _imagePaths ?? [],
        description: car?.description,
        modifiedById: currentUserId ?? '',
        previousStatus: car?.status ?? CarStatus.pendingApproval,
        referenceNumber: car?.referenceNumber ?? '',
      );

      setUpdateCarLoading(false);
      if (mounted) {
        buildSuccessSnackbar(
          context: context,
          message: 'Car Updated successfully.',
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      setUpdateCarLoading(false);
      if (mounted) {
        buildFailureSnackbar(
          context: context,
          message: 'Error while updating car. Please try again later.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Car')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionDivider(sectionTitle: 'Car Details'),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _manufacturerController,
                  focusNode: _manufacturerFocusNode,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Manufacturer',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixIcon: const Icon(Icons.directions_car),
                  ),
                  validator: _validateField,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_modelFocusNode);
                  },
                  onChanged: (value) => car?.manufacturer = value.trim(),
                ),
                const SizedBox(height: 15.0),
                TextFormField(
                  controller: _modelController,
                  focusNode: _modelFocusNode,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Model',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixIcon: const Icon(Icons.directions_car_rounded),
                  ),
                  validator: _validateField,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_yearFocusNode);
                  },
                  onChanged: (value) => car?.model = value.trim(),
                ),
                const SizedBox(height: 15.0),
                TextFormField(
                  controller: _yearController,
                  focusNode: _yearFocusNode,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Manufacture Year',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixIcon: const Icon(Icons.calendar_month_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid year';
                    }
                    final nextYear = DateTime.now().year + 1;
                    final minimumYear = nextYear - 15;
                    if (int.tryParse(value)! < minimumYear ||
                        int.tryParse(value)! > nextYear) {
                      return 'Please enter a year between $minimumYear and $nextYear';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_colorFocusNode);
                  },
                  onChanged: (value) =>
                      car?.manufactureYear = int.tryParse(value),
                ),
                const SizedBox(height: 15.0),
                TextFormField(
                  controller: _colorController,
                  focusNode: _colorFocusNode,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Color',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixIcon: const Icon(Icons.color_lens),
                  ),
                  validator: _validateField,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_engineTypeFocusNode);
                  },
                  onChanged: (value) => car?.color = value.trim(),
                ),
                const SizedBox(height: 15.0),
                DropdownButtonFormField<EngineType>(
                  focusNode: _engineTypeFocusNode,
                  value: car?.engineType,
                  decoration: InputDecoration(
                    labelText: 'Engine Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixIcon: Image.asset(
                      AssetsPaths.engineTypeIcon,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      maxHeight: 25.0,
                      minHeight: 25.0,
                      maxWidth: 50.0,
                      minWidth: 50.0,
                    ),
                  ),
                  items: EngineType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.engineTypeString),
                          ))
                      .toList(),
                  onChanged: (value) => car?.engineType = value,
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an engine type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15.0),
                DropdownButtonFormField<TransmissionType>(
                  focusNode: _transmissionTypeFocusNode,
                  value: car?.transmissionType,
                  decoration: InputDecoration(
                    labelText: 'Transmission',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixIcon: Image.asset(
                      AssetsPaths.transmissionTypeIcon,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      maxHeight: 20.0,
                      minHeight: 20.0,
                      maxWidth: 50.0,
                      minWidth: 50.0,
                    ),
                  ),
                  items: TransmissionType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.transmissionTypeString),
                          ))
                      .toList(),
                  onChanged: (value) => car?.transmissionType = value,
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a transmission type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15.0),
                TextFormField(
                  controller: _seatsController,
                  focusNode: _seatsFocusNode,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Seats',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    // prefixIcon: const Icon(Icons.event_seat),
                    prefixIcon: Image.asset(
                      AssetsPaths.carSeatIcon,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      maxHeight: 25.0,
                      minHeight: 25.0,
                      maxWidth: 45.0,
                      minWidth: 45.0,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }

                    if (int.tryParse(value) == null ||
                        int.tryParse(value)! <= 0) {
                      return 'Please enter a valid number of seats';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(carTypeFocusNode);
                  },
                  onChanged: (value) => car?.seats = int.tryParse(value),
                ),
                const SizedBox(height: 15.0),
                DropdownButtonFormField<CarType>(
                  focusNode: carTypeFocusNode,
                  value: car?.carType,
                  decoration: InputDecoration(
                    labelText: 'Car Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixIcon: const Icon(Icons.directions_car_rounded),
                  ),
                  items: CarType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.getCarTypeString()),
                          ))
                      .toList(),
                  onChanged: (value) => car?.carType = value,
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a car type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15.0),
                TextFormField(
                  controller: _descriptionController,
                  focusNode: _descriptionFocusNode,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  maxLines: 3,
                  validator: (_) => null,
                  onChanged: (value) => car?.description = value.trim(),
                ),
                const SizedBox(height: 20.0),
                const SectionDivider(sectionTitle: 'Car Pricing'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'To provide flexibility for the customers, they can select the total period they want to rent. The period will be calculated to the total duration. If the period includes days and extra hours, both prices will be used to calculate the total cost. If the period is equivalent to full days, then the day price will be used. If it\'s less than a day, the hour price will be used. Both prices will be used to get the total cost.',
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _hourPriceController,
                  focusNode: _hourPriceFocusNode,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Hour Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    double? price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Price must be a positive number';
                    }
                    // Check if price has more than one decimal point
                    List<String> splitValue = value.split('.');
                    if (splitValue.length > 2 ||
                        (splitValue.length == 2 && splitValue[1].length > 1)) {
                      return 'Please enter a valid price with at most one decimal point';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_dayPriceFocusNode);
                  },
                  onChanged: (value) => car?.hourPrice = double.tryParse(value),
                ),
                const SizedBox(height: 15.0),
                TextFormField(
                  controller: _dayPriceController,
                  focusNode: _dayPriceFocusNode,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Day Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    double? price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Price must be a positive number';
                    }
                    // Check if price has more than one decimal point
                    List<String> splitValue = value.split('.');
                    if (splitValue.length > 2 ||
                        (splitValue.length == 2 && splitValue[1].length > 1)) {
                      return 'Please enter a valid price with at most one decimal point';
                    }
                    return null;
                  },
                  onChanged: (value) => car?.dayPrice = double.tryParse(value),
                ),
                const SizedBox(height: 20.0),
                const SectionDivider(sectionTitle: 'Car Images'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Please provide between 1 to 15 images of the car. The first image will be used as the cover image.',
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(height: 20.0),
                UpdateCarImages(
                  onImagesChanged: _updateImagePaths,
                  initialImageUrls: car?.imagesUrl ?? [],
                ),
                const SizedBox(height: 30.0),
                SizedBox(
                  height: 50.0,
                  child: _updateCarLoading
                      ? const CustomProgressIndicator()
                      : FilledButton(
                          onPressed: _updateCar,
                          child: const Text(
                            'Update Car',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
