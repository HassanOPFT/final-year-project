import 'package:flutter/material.dart';
import 'package:prime/services/google_maps_service.dart';
import 'package:prime/utils/snackbar.dart';

import '../models/address.dart';
import '../models/auto_complete_results.dart';

class AddressSearchBar extends StatefulWidget {
  final Function(Address) selectAddress;
  const AddressSearchBar({super.key, required this.selectAddress});

  @override
  State<AddressSearchBar> createState() => _AddressSearchBarState();
}

class _AddressSearchBarState extends State<AddressSearchBar> {
  final _googleMapsService = GoogleMapsService();
  List<AutoCompleteResult>? _autoCompleteResults = [];

  void unFocusKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  List<Widget> _buildSuggestions() {
    return _autoCompleteResults?.map((suggestion) {
          return ListTile(
            leading: const Icon(Icons.location_on_rounded),
            title: Text(suggestion.description),
            onTap: () async {
              final placeDetails =
                  await _googleMapsService.getPlaceDetails(suggestion.placeId);

              if (mounted) {
                if (placeDetails != null) {
                  widget.selectAddress(placeDetails);
                  unFocusKeyboard(context);
                  Navigator.pop(context);
                } else {
                  buildFailureSnackbar(
                    context: context,
                    message: 'Failed to get place details. Please try again.',
                  );
                }
              }
            },
          );
        }).toList() ??
        [
          const ListTile(
            title: Text('No results found'),
          ),
        ];
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      barHintText: 'Search here',
      isFullScreen: false,
      barLeading: IconButton(
        onPressed: () {
          // check keyboard focus, if focused, unfocus
          unFocusKeyboard(context);
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      barTrailing: const [
        IconButton(
          onPressed: null,
          icon: Icon(Icons.search),
        ),
      ],
      onChanged: (value) async {
        if (value.isNotEmpty) {
          final results = await _googleMapsService.addressAutoComplete(value);
          setState(() {
            if (results != null) {
              _autoCompleteResults = results;
            } else {
              _autoCompleteResults = [];
            }
          });
        }
      },
      suggestionsBuilder: (context, controller) {
        return Future.value(_buildSuggestions());
      },
    );
  }

  
}
