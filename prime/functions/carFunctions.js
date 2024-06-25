/* eslint-disable max-len */
const {onDocumentWritten} = require("firebase-functions/v2/firestore");

// Import helper functions
const {sendNotification, getUserFCMToken, getAdminsFCMTokens} = require("./helpers");

// Enums
const CarStatus = {
  currentlyRented: "currentlyRented",
  upcomingRental: "upcomingRental",
  uploaded: "uploaded",
  pendingApproval: "pendingApproval",
  updated: "updated",
  approved: "approved",
  rejected: "rejected",
  haltedByHost: "haltedByHost",
  haltedByAdmin: "haltedByAdmin",
  unhaltRequested: "unhaltRequested",
  deletedByHost: "deletedByHost",
  deletedByAdmin: "deletedByAdmin",
};

const carDocumentWritten = onDocumentWritten(
    "Car/{carId}",
    async (event) => {
      const carData = event.data.after.data();

      if (!carData) {
        console.log("Document is deleted. Exiting function.");
        return null;
      }
      const carId = event.params.carId;
      const carStatus = carData.status;
      const hostId = carData.hostId;

      const adminsFCMTokens = await getAdminsFCMTokens();
      const userFCMToken = await getUserFCMToken(hostId);

      switch (carStatus) {
        case CarStatus.upcomingRental:
          // No Admins Notifications
          // User Notification
          await sendNotification(
              `Good News! Upcoming Rental!`,
              `Your ${carData.manufacturer} ${carData.model} has an Upcoming Rental`,
              userFCMToken,
              hostId,
              carId,
              carStatus,
          );
          break;
        case CarStatus.currentlyRented:
          // No Admins Notifications
          // No User Notification
          await sendNotification(
              `Good News! Rental Started!`,
              `Your ${carData.manufacturer} ${carData.model} rental has started!`,
              userFCMToken,
              hostId,
              carId,
              carStatus,
          );
          break;
        case CarStatus.uploaded:
        // Admins Notifications
          for (const {fcmToken, userId} of adminsFCMTokens) {
            await sendNotification(
                `New Car Uploaded!`,
                `Car with reference number ${carData.referenceNumber} has been Uploaded to the platform. waiting for approval.`,
                fcmToken,
                userId,
                carId,
                carStatus,
            );
          }
          // No User Notification
          break;
        case CarStatus.updated:
        // Admins Notifications
          for (const {fcmToken, userId} of adminsFCMTokens) {
            await sendNotification(
                `Car Updated!`,
                `Car with reference number ${carData.referenceNumber} has been Updated. waiting for approval.`,
                fcmToken,
                userId,
                carId,
                carStatus,
            );
          }
          // No User Notification
          break;
        case CarStatus.pendingApproval:
        // Admins Notifications
          for (const {fcmToken, userId} of adminsFCMTokens) {
            await sendNotification(
                `Car Pending Approval!`,
                `Car with reference number ${carData.referenceNumber} is Pending Approval. waiting for approval.`,
                fcmToken,
                userId,
                carId,
                carStatus,
            );
          }
          // No User Notification
          break;
        case CarStatus.approved:
        // No Admins Notifications
        // User Notification
          await sendNotification(
              `Good News! Car Approved!`,
              `Your ${carData.manufacturer} ${carData.model} has been Approved`,
              userFCMToken,
              hostId,
              carId,
              carStatus,
          );
          break;
        case CarStatus.rejected:
        // No Admins Notifications
        // User Notification
          await sendNotification(
              `Car Rejected!`,
              `Your ${carData.manufacturer} ${carData.model} has been Rejected. Please update and re-upload.`,
              userFCMToken,
              hostId,
              carId,
              carStatus,
          );
          break;
        case CarStatus.haltedByHost:
        // No Admins Notifications
        // No User Notification
          break;
        case CarStatus.haltedByAdmin:
        // No Admins Notifications
        // User Notification
          await sendNotification(
              `Car Halted by Admin!`,
              `Your ${carData.manufacturer} ${carData.model} has been Halted by the Admin.`,
              userFCMToken,
              hostId,
              carId,
              carStatus,
          );
          break;
        case CarStatus.unhaltRequested:
        // Admins Notifications
          for (const {fcmToken, userId} of adminsFCMTokens) {
            await sendNotification(
                `Unhalt Requested for Car!`,
                `Car with reference number ${carData.referenceNumber} has an Unhalt Request. waiting for unhalt.`,
                fcmToken,
                userId,
                carId,
                carStatus,
            );
          }
          // No User Notification
          break;
        case CarStatus.deletedByHost:
        // Admins Notifications
          for (const {fcmToken, userId} of adminsFCMTokens) {
            await sendNotification(
                `Car Deleted by Host!`,
                `Car with reference number ${carData.referenceNumber} has been Deleted by Host.`,
                fcmToken,
                userId,
                carId,
                carStatus,
            );
          }
          // No User Notification
          break;
        case CarStatus.deletedByAdmin:
        // No Admins Notifications
        // No User Notification
          break;
        default:
        // No Admins Notifications
        // No User Notification
          break;
      }
    },
);

module.exports = {
  carDocumentWritten,
};
