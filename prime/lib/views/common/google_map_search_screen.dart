// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class MapWithSearch extends StatefulWidget {
//   const MapWithSearch({super.key});

//   @override
//   _MapWithSearchState createState() => _MapWithSearchState();
// }

// class _MapWithSearchState extends State<MapWithSearch> {
//   Completer<GoogleMapController> _controller = Completer();

//   Set<Marker> _markers = Set<Marker>();
//   Set<Polyline> _polylines = Set<Polyline>();
//   Set<Circle> _circles = Set<Circle>();

//   CameraPosition _initialCameraPosition = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );

//   TextEditingController searchController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     // Assuming placeResultsProvider and searchToggleProvider are provided higher up in the widget tree
//     //final allSearchResults = ref.watch(placeResultsProvider);
//     //final searchFlag = ref.watch(searchToggleProvider);

//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             height: MediaQuery.of(context).size.height,
//             width: MediaQuery.of(context).size.width,
//             child: GoogleMap(
//               mapType: MapType.normal,
//               markers: _markers,
//               polylines: _polylines,
//               circles: _circles,
//               initialCameraPosition: _initialCameraPosition,
//               onMapCreated: (GoogleMapController controller) {
//                 _controller.complete(controller);
//               },
//               onTap: (point) {
//                 // Handle map tap here
//               },
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.fromLTRB(15.0, 40.0, 15.0, 5.0),
//             child: Column(
//               children: [
//                 Container(
//                   height: 50.0,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10.0),
//                     color: Colors.white,
//                   ),
//                   child: TextFormField(
//                     controller: searchController,
//                     decoration: InputDecoration(
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 20.0,
//                         vertical: 15.0,
//                       ),
//                       border: InputBorder.none,
//                       hintText: 'Search',
//                       suffixIcon: IconButton(
//                         onPressed: () {
//                           setState(() {
//                             // Handle search icon tap
//                           });
//                         },
//                         icon: Icon(Icons.close),
//                       ),
//                     ),
//                     onChanged: (value) {
//                       // Handle search text changes
//                     },
//                   ),
//                 )
//               ],
//             ),
//           ),
//           searchFlag.searchToggle
//               ? Positioned(
//                   top: 100.0,
//                   left: 15.0,
//                   child: Container(
//                     height: 200.0,
//                     width: MediaQuery.of(context).size.width - 30.0,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10.0),
//                       color: Colors.white.withOpacity(0.7),
//                     ),
//                     child: ListView(
//                       children: [
//                         // Display search results here
//                       ],
//                     ),
//                   ),
//                 )
//               : Container(),
//         ],
//       ),
//     );
//   }
// }
