/* eslint-disable max-len */
const admin = require("firebase-admin");
const {onDocumentWritten} = require("firebase-functions/v2/firestore");

// Import helper functions
const {sendNotification, getUserFCMToken, getAdminsFCMTokens} = require("./helpers");

// Enums
const IssueReportStatus = {
  open: "open",
  inProgress: "inProgress",
  resolved: "resolved",
  closed: "closed",
};

const issueReportDocumentWritten = onDocumentWritten(
    "IssueReport/{issueReportId}",
    async (event) => {
      const issueReportData = event.data.after.data();

      if (!issueReportData) {
        console.log("Document is deleted. Exiting function.");
        return null;
      }
      const issueReportId = event.params.issueReportId;
      const issueReportStatus = issueReportData.status;
      const reporterId = issueReportData.reporterId;
      const carRentalId = issueReportData.carRentalId;

      const adminsFCMTokens = await getAdminsFCMTokens();
      const userFCMToken = await getUserFCMToken(reporterId);

      // Get CarRental using carRentalId
      const carRentalSnapshot = await admin.firestore().collection("CarRental").doc(carRentalId).get();
      const carRentalData = carRentalSnapshot.data();
      const carRentalReferenceNumber = carRentalData.referenceNumber;

      switch (issueReportStatus) {
        case IssueReportStatus.open:
          // Admins Notifications
          for (const {fcmToken, userId} of adminsFCMTokens) {
            await sendNotification(
                `New Issue Reported!`,
                `Car Rental with reference number ${carRentalReferenceNumber} has a new issue reported. waiting for your action.`,
                fcmToken,
                userId,
                issueReportId,
                issueReportStatus,
            );
          }
          // User Notification
          await sendNotification(
              `Issue Reported!`,
              `Your issue for car rental with reference number ${carRentalReferenceNumber} has been reported.`,
              userFCMToken,
              reporterId,
              issueReportId,
              issueReportStatus,
          );
          break;
        case IssueReportStatus.inProgress:
          // No Admins Notifications
          // User Notification
          await sendNotification(
              `Issue In Progress!`,
              `Your issue for car rental with reference number ${carRentalReferenceNumber} is in progress.`,
              userFCMToken,
              reporterId,
              issueReportId,
              issueReportStatus,
          );
          break;
        case IssueReportStatus.resolved:
          // No Admins Notifications
          // User Notification
          await sendNotification(
              `Issue Resolved!`,
              `Your issue for car rental with reference number ${carRentalReferenceNumber} is resolved.`,
              userFCMToken,
              reporterId,
              issueReportId,
              issueReportStatus,
          );
          break;
        case IssueReportStatus.closed:
          // No Admins Notifications
          // User Notification
          await sendNotification(
              `Issue Closed!`,
              `Your issue for car rental with reference number ${carRentalReferenceNumber} is closed.`,
              userFCMToken,
              reporterId,
              issueReportId,
              issueReportStatus,
          );
          break;
        default:
        // No Admins Notifications
        // No User Notification
          break;
      }
    },
);

module.exports = {
  issueReportDocumentWritten,
};
