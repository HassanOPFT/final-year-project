/* eslint-disable max-len */
const {onDocumentWritten} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const db = admin.firestore();

// Import helper functions
const {sendNotification, getUserFCMToken, getAdminsFCMTokens} = require("./helpers");

// Enums
const CarRentalStatus = {
  rentedByCustomer: "rentedByCustomer",
  pickedUpByCustomer: "pickedUpByCustomer",
  customerReportedIssue: "customerReportedIssue",
  customerExtendedRental: "customerExtendedRental",
  customerReturnedCar: "customerReturnedCar",
  hostConfirmedPickup: "hostConfirmedPickup",
  customerCancelled: "customerCancelled",
  hostCancelled: "hostCancelled",
  hostReportedIssue: "hostReportedIssue",
  hostConfirmedReturn: "hostConfirmedReturn",
  adminConfirmedPayout: "adminConfirmedPayout",
  adminConfirmedRefund: "adminConfirmedRefund",
};

const carRentalDocumentWritten = onDocumentWritten(
    "CarRental/{rentalId}",
    async (event) => {
      const rentalData = event.data.after.data();

      if (!rentalData) {
        console.log("Document is deleted. Exiting function.");
        return null;
      }
      const rentalId = event.params.rentalId;
      const rentalStatus = rentalData.status;
      const customerId = rentalData.customerId;
      const carId = rentalData.carId;
      const carRentalReferenceNumber = rentalData.referenceNumber;

      // Fetch the Car object to get hostId
      const carDoc = await db.collection("Car").doc(carId).get();
      const carData = carDoc.data();
      const carName = `${carData.manufacturer} ${carData.model}`;
      const hostId = carData.hostId;

      const adminsFCMTokens = await getAdminsFCMTokens();
      const customerFCMToken = await getUserFCMToken(customerId);
      const hostFCMToken = await getUserFCMToken(hostId);

      switch (rentalStatus) {
        case CarRentalStatus.rentedByCustomer:
        // No Admins Notifications
        // Customer Notification
          await sendNotification(
              `Car Rental Confirmed!`,
              `Your car rental has been confirmed!.`,
              hostFCMToken,
              customerId,
              rentalId,
              rentalStatus,
          );
          // Host Notification
          await sendNotification(
              `New Car Rental!`,
              `Your ${carName} has an upcoming rental!`,
              hostFCMToken,
              hostId,
              rentalId,
              rentalStatus,
          );
          break;
        case CarRentalStatus.pickedUpByCustomer:
        // No Admins Notifications
        // No Customer Notification
        // Host Notification
          await sendNotification(
              `Car Picked Up!`,
              `Your car has been picked up by the customer!. please confirm the pickup.`,
              hostFCMToken,
              hostId,
              rentalId,
              rentalStatus,
          );
          break;
        case CarRentalStatus.customerReportedIssue:
        // Admins Notifications
          for (const {fcmToken, userId} of adminsFCMTokens) {
            await sendNotification(
                `Customer Reported Issue!`,
                `A customer has reported an issue for car rental with reference number ${carRentalReferenceNumber}.`,
                fcmToken,
                userId,
                rentalId,
                rentalStatus,
            );
          }
          // No Customer Notification
          // Host Notification
          await sendNotification(
              `Issue Reported By Customer!`,
              `The Customer has reported an issue for your car rental with reference number ${carRentalReferenceNumber}.`,
              hostFCMToken,
              hostId,
              rentalId,
              rentalStatus,
          );
          break;
        case CarRentalStatus.customerExtendedRental:
        // No Admins Notifications
        // No Customer Notification
        // Host Notification
          await sendNotification(
              `Rental Extended!`,
              `The customer has extended the rental period for car rental with reference number ${carRentalReferenceNumber}.`,
              hostFCMToken,
              hostId,
              rentalId,
              rentalStatus,
          );
          break;
        case CarRentalStatus.customerReturnedCar:
        // No Admins Notifications
        // No Customer Notification
        // Host Notification
          await sendNotification(
              `Car Returned!`,
              `The customer has returned the car for car rental with reference number ${carRentalReferenceNumber}. please confirm the return.`,
              hostFCMToken,
              hostId,
              rentalId,
              rentalStatus,
          );
          break;
        case CarRentalStatus.hostConfirmedPickup:
        // No Admins Notifications
        // Customer Notification
          await sendNotification(
              `Pickup Confirmed!`,
              `Your Car rental with reference number ${carRentalReferenceNumber} pickup has been confirmed by the host.`,
              customerFCMToken,
              customerId,
              rentalId,
              rentalStatus,
          );
          // No Host Notification
          break;
        case CarRentalStatus.customerCancelled:
        // No Admins Notifications
        // No Customer Notification
        // Host Notification
          await sendNotification(
              `Rental Cancelled by Customer!`,
              `The customer has cancelled the rental with reference number ${carRentalReferenceNumber}.`,
              hostFCMToken,
              hostId,
              rentalId,
              rentalStatus,
          );
          break;
        case CarRentalStatus.hostCancelled:
        // No Admins Notifications
        // Customer Notification
          await sendNotification(
              `Rental Cancelled by Host!`,
              `The host has cancelled your rental with reference number ${carRentalReferenceNumber}.`,
              customerFCMToken,
              customerId,
              rentalId,
              rentalStatus,
          );
          // No Host Notification
          break;
        case CarRentalStatus.hostReportedIssue:
        // Admins Notifications
          for (const {fcmToken, userId} of adminsFCMTokens) {
            await sendNotification(
                `Host Reported Issue!`,
                `A Host has reported an issue for car rental with reference number ${carRentalReferenceNumber}.`,
                fcmToken,
                userId,
                rentalId,
                rentalStatus,
            );
          }
          // Customer Notification
          await sendNotification(
              `Issue Reported By Host!`,
              `The Host has reported an issue for your car rental with reference number ${carRentalReferenceNumber}.`,
              customerFCMToken,
              customerId,
              rentalId,
              rentalStatus,
          );
          // No Host Notification
          break;
        case CarRentalStatus.hostConfirmedReturn:
        // No Admins Notifications
        // Customer Notification
          await sendNotification(
              `Return Confirmed!`,
              `Your car rental with reference number ${carRentalReferenceNumber} return has been confirmed by the host.`,
              customerFCMToken,
              customerId,
              rentalId,
              rentalStatus,
          );
          // No Host Notification
          break;
        case CarRentalStatus.adminConfirmedPayout:
        // No Admins Notifications
        // No Customer Notification
        // Host Notification
          await sendNotification(
              `Payout Confirmed!`,
              `Your payout for car rental with reference number ${carRentalReferenceNumber} has been confirmed and processed by the admin.`,
              hostFCMToken,
              hostId,
              rentalId,
              rentalStatus,
          );
          break;
        case CarRentalStatus.adminConfirmedRefund:
        // No Admins Notifications
        // Customer Notification
          await sendNotification(
              `Refund Confirmed!`,
              `Your refund for car rental with reference number ${carRentalReferenceNumber} has been confirmed and processed by the admin.`,
              customerFCMToken,
              customerId,
              rentalId,
              rentalStatus,
          );
          // No Host Notification
          break;
        default:
        // No User Notification
          break;
      }
    },
);

module.exports = {
  carRentalDocumentWritten,
};
