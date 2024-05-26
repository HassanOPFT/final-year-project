// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:prime/utils/assets_paths.dart';
// import 'package:prime/utils/snackbar.dart';
// import 'package:provider/provider.dart';

// import '../../models/user.dart';
// import '../../providers/user_provider.dart';
// import '../../providers/verification_document_provider.dart';
// import '../../services/firebase/firebase_auth_service.dart';
// import '../../utils/navigate_with_animation.dart';
// import '../../views/profile/update_verification_document_screen.dart';
// import '../../views/profile/view_full_image_screen.dart';
// import '../bottom_sheet/edit_verification_document_bottom_sheet.dart';
// import '../verification_document_status_indicator.dart';
// import '../../models/verification_document.dart';

// class VerificationDocumentDetailsCard extends StatelessWidget {
//   final VerificationDocument verificationDocument;
//   const VerificationDocumentDetailsCard({
//     super.key,
//     required this.verificationDocument,
//   });

//   @override
//   Widget build(BuildContext context) {
//     void updateVerificationDocument() {
//       animatedPushNavigation(
//         context: context,
//         screen: UpdateVerificationDocumentScreen(
//           verificationDocument: verificationDocument,
//         ),
//       );
//     }

//     Future<bool> confirmDeleteDocument(BuildContext context) async {
//       bool isConfirmed = await showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Confirm Deletion'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Image.asset(
//                   AssetsPaths.binImage, // Change to your bin image path
//                   height: 200.0,
//                 ),
//                 const Text(
//                   'Are you sure you want to delete this document? This action cannot be undone.',
//                   style: TextStyle(fontSize: 16.0),
//                 ),
//               ],
//             ),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(true),
//                 child: const Text('Delete'),
//               ),
//             ],
//           );
//         },
//       );

//       return isConfirmed;
//     }

//     Future<void> deleteVerificationDocument() async {
//       if (verificationDocument.id == null || verificationDocument.id!.isEmpty) {
//         return;
//       }

//       bool confirmDeletion = await confirmDeleteDocument(context);
//       if (!confirmDeletion) {
//         return;
//       }
//       final verificationDocumentProvider =
//           Provider.of<VerificationDocumentProvider>(
//         context,
//         listen: false,
//       );
//       final userProvider = Provider.of<UserProvider>(
//         context,
//         listen: false,
//       );

//       try {
//         // get the current user from firebase auth service
//         final firebaseAuthService = FirebaseAuthService();
//         if (firebaseAuthService.currentUser == null) {
//           buildFailureSnackbar(
//             context: context,
//             message:
//                 'Error while uploading Identity document. Please try again.',
//           );
//           return;
//         }
//         final currentUserId = firebaseAuthService.currentUser!.uid;
//         final userRole = userProvider.user?.userRole ?? UserRole.customer;
//         await verificationDocumentProvider.deleteVerificationDocument(
//           documentId: verificationDocument.id!,
//           referenceNumber: verificationDocument.referenceNumber ?? '',
//           documentType:
//               verificationDocument.documentType as VerificationDocumentType,
//           userRole: userRole,
//           previousStatus:
//               verificationDocument.status as VerificationDocumentStatus,
//           modifiedById: currentUserId,
//         );
//         buildSuccessSnackbar(
//           context: context,
//           message: 'Document deleted successfully',
//         );
//       } on Exception catch (e) {
//         buildFailureSnackbar(
//           context: context,
//           message: 'Error deleting document. Please try again later.',
//         );
//       }
//     }

//     Future<void> showEditVerificationDocumentBottomSheet() async {
//       await showModalBottomSheet(
//         context: context,
//         showDragHandle: true,
//         builder: (BuildContext context) {
//           return EditVerificationDocumentBottomSheet(
//             updateVerificationDocument: updateVerificationDocument,
//             deleteVerificationDocument: deleteVerificationDocument,
//           );
//         },
//       );
//     }

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '${verificationDocument.documentType?.getDocumentTypeString()}',
//                   style: const TextStyle(
//                     fontSize: 28.0,
//                     // fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => showEditVerificationDocumentBottomSheet(),
//                   icon: const Icon(Icons.edit_rounded),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10.0),
//             Stack(
//               children: [
//                 GestureDetector(
//                   onTap: verificationDocument.documentUrl != null
//                       ? () => animatedPushNavigation(
//                             context: context,
//                             screen: ViewFullImageScreen(
//                               imageUrl: verificationDocument.documentUrl!,
//                               appBarTitle: 'Document Image',
//                               tag: 'document-image',
//                             ),
//                           )
//                       : null,
//                   child: Hero(
//                     tag: 'document-image',
//                     child: Container(
//                       width: double.infinity,
//                       height: 200,
//                       decoration: verificationDocument.documentUrl == null
//                           ? null
//                           : BoxDecoration(
//                               borderRadius: BorderRadius.circular(15.0),
//                               image: DecorationImage(
//                                 image: NetworkImage(
//                                     verificationDocument.documentUrl!),
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                       // display a placeholder image if documentUrl is null
//                       child: verificationDocument.documentUrl == null
//                           ? const Center(
//                               child: Text('Error loading image'),
//                             )
//                           : null,
//                     ),
//                   ),
//                 ),
//                 // display the status of the document
//                 Positioned(
//                   top: 10.0,
//                   right: 10.0,
//                   child: VerificationDocumentStatusIndicator(
//                     verificationDocumentStatus: verificationDocument.status
//                         as VerificationDocumentStatus,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20.0),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Expiry Date',
//                   style: TextStyle(
//                     color: Theme.of(context).hintColor,
//                     fontSize: 20.0,
//                   ),
//                 ),
//                 Text(
//                   verificationDocument.expiryDate != null
//                       ? DateFormat.yMMMMd()
//                           .format(verificationDocument.expiryDate as DateTime)
//                       : 'N/A',
//                   style: const TextStyle(
//                     fontSize: 20.0,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 5.0),
//             const Divider(),
//             const SizedBox(height: 5.0),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Ref No:',
//                   style: TextStyle(
//                     color: Theme.of(context).hintColor,
//                     fontSize: 16.0,
//                   ),
//                 ),
//                 Text(
//                   verificationDocument.referenceNumber ?? 'N/A',
//                   style: TextStyle(
//                     color: Theme.of(context).hintColor,
//                     fontSize: 16.0,
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Created At:',
//                   style: TextStyle(
//                     color: Theme.of(context).hintColor,
//                     fontSize: 16.0,
//                   ),
//                 ),
//                 Text(
//                   DateFormat.yMMMd()
//                       .add_jm()
//                       .format(verificationDocument.createdAt as DateTime),
//                   style: TextStyle(
//                     color: Theme.of(context).hintColor,
//                     fontSize: 16.0,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
