import 'package:flutter/material.dart';
import 'package:prime/widgets/tiles/issue_report_tile.dart';
import 'package:provider/provider.dart';
import '../providers/issue_report_provider.dart';
import '../providers/car_rental_provider.dart';
import '../providers/user_provider.dart';
import '../providers/search_issue_reports_provider.dart';
import 'custom_progress_indicator.dart';
import 'no_data_found.dart';

class AdminIssueReportsTabBody extends StatefulWidget {
  const AdminIssueReportsTabBody({super.key});

  @override
  State<AdminIssueReportsTabBody> createState() =>
      _AdminIssueReportsTabBodyState();
}

class _AdminIssueReportsTabBodyState extends State<AdminIssueReportsTabBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchIssueReports(
      BuildContext context) async {
    final issueReportProvider =
        Provider.of<IssueReportProvider>(context, listen: false);
    final carRentalProvider =
        Provider.of<CarRentalProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final issueReportsWithDetails = <Map<String, dynamic>>[];

    final issueReports = await issueReportProvider.getAllIssueReports();

    for (var report in issueReports) {
      if (report.carRentalId != null && report.reporterId != null) {
        final rental =
            await carRentalProvider.getCarRentalById(report.carRentalId!);
        final user = await userProvider.getUserDetails(report.reporterId!);
        issueReportsWithDetails.add({
          'report': report,
          'rental': rental,
          'user': user,
        });
      }
    }

    return issueReportsWithDetails;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchIssueReports(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const NoDataFound(
                title: 'Nothing Found',
                subTitle: 'No issue reports found.',
              );
            } else {
              final issueReportsWithDetails = snapshot.data!;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!Provider.of<SearchIssueReportsProvider>(context,
                        listen: false)
                    .issueReportsListEquals(issueReportsWithDetails)) {
                  Provider.of<SearchIssueReportsProvider>(context,
                          listen: false)
                      .setIssueReportsList(issueReportsWithDetails);
                }
              });

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    toolbarHeight: 80.0,
                    title: Consumer<SearchIssueReportsProvider>(
                      builder: (context, searchProvider, _) {
                        return SearchBar(
                          hintText: 'Search Issue Reports',
                          leading: const Icon(Icons.search_rounded),
                          trailing: [
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  searchProvider.clearFilters();
                                },
                                icon: const Icon(Icons.clear_rounded),
                              ),
                          ],
                          controller: _searchController,
                          onChanged: searchProvider.filterIssueReports,
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.fromLTRB(20.0, 0.0, 10.0, 0.0),
                          ),
                        );
                      },
                    ),
                  ),
                  Consumer<SearchIssueReportsProvider>(
                    builder: (_, searchIssueReportsProvider, __) {
                      final childCount = searchIssueReportsProvider
                              .isSearchFilterActive
                          ? searchIssueReportsProvider
                              .filteredIssueReports.length
                          : searchIssueReportsProvider.issueReportsList.length;
                      if (childCount <= 0) {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return const NoDataFound(
                                title: 'No Results Found!',
                                subTitle:
                                    'There are no issue reports matching your search criteria. Please try again with different keywords.',
                              );
                            },
                            childCount: 1,
                          ),
                        );
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final issueReportWithDetails =
                                searchIssueReportsProvider.isSearchFilterActive
                                    ? searchIssueReportsProvider
                                        .filteredIssueReports[index]
                                    : searchIssueReportsProvider
                                        .issueReportsList[index];

                            return IssueReportTile(
                              issueReport: issueReportWithDetails['report'],
                              userFullName:
                                  '${issueReportWithDetails['user'].userFirstName ?? ''} ${issueReportWithDetails['user'].userLastName ?? ''}',
                            );
                          },
                          childCount:
                              searchIssueReportsProvider.isSearchFilterActive
                                  ? searchIssueReportsProvider
                                      .filteredIssueReports.length
                                  : searchIssueReportsProvider
                                      .issueReportsList.length,
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/issue_report.dart';
// import '../models/user.dart';
// import '../providers/issue_report_provider.dart';
// import '../providers/user_provider.dart';
// import '../widgets/custom_progress_indicator.dart';
// import '../widgets/no_data_found.dart';
// import '../widgets/tiles/issue_report_tile.dart';

// class AdminReportedIssuesTabBody extends StatelessWidget {
//   const AdminReportedIssuesTabBody({super.key});

//   Future<List<Map<String, dynamic>>> fetchIssueReportsWithUsers(
//     BuildContext context,
//   ) async {
//     final issueReportProvider = Provider.of<IssueReportProvider>(context);
//     final userProvider = Provider.of<UserProvider>(
//       context,
//       listen: false,
//     );

//     final issueReports = await issueReportProvider.getAllIssueReports();
//     final List<Map<String, dynamic>> issueReportsWithUsers = [];

//     for (var report in issueReports) {
//       User? reporterDetails;
//       if (report.reporterId != null) {
//         reporterDetails = await userProvider.getUserDetails(report.reporterId!);
//       }
//       final userFullName = reporterDetails != null
//           ? '${reporterDetails.userFirstName ?? ''} ${reporterDetails.userLastName ?? ''}'
//           : 'Unknown User';

//       issueReportsWithUsers.add({
//         'issueReport': report,
//         'userFullName': userFullName,
//       });
//     }

//     return issueReportsWithUsers;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: fetchIssueReportsWithUsers(context),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const CustomProgressIndicator();
//           } else if (snapshot.hasError) {
//             return const Center(
//               child: Text('Error loading data'),
//             );
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const NoDataFound(
//               title: 'Nothing Found',
//               subTitle: 'No rentals reported issues found.',
//             );
//           } else {
//             final issueReportsWithUsers = snapshot.data!;
//             return ListView.builder(
//               itemCount: issueReportsWithUsers.length,
//               padding: const EdgeInsets.all(10.0),
//               itemBuilder: (context, index) {
//                 final IssueReport issueReport =
//                     issueReportsWithUsers[index]['issueReport'];
//                 final String userFullName =
//                     issueReportsWithUsers[index]['userFullName'];

//                 return IssueReportTile(
//                   issueReport: issueReport,
//                   userFullName: userFullName,
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
