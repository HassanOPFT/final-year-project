/* eslint-disable max-len */
const {admin} = require("./firebase");
const {
  onDocumentWritten,
} = require("firebase-functions/v2/firestore");

// Import helper functions
const {sendNotification, getUserFCMToken, getAdminsFCMTokens} = require("./helpers");

// Enums
const VerificationDocumentLinkedObjectType = {
  user: "user",
  car: "car",
};

const VerificationDocumentTypeReadable = {
  identity: "Identity Document",
  drivingLicense: "Driving License",
  carRegistration: "Car Registration",
  carInsurance: "Car Insurance",
  carRoadTax: "Car Road Tax",
};

/**
 * Get the readable document type based on the document type.
 * @param {string} docType - The document type.
 * @return {string} - The readable document type.
 */
function getReadableDocumentType(docType) {
  return VerificationDocumentTypeReadable[docType] || "Verification Document";
}

const VerificationDocumentStatus = {
  uploaded: "uploaded",
  pendingApproval: "pendingApproval",
  approved: "approved",
  rejected: "rejected",
  updated: "updated",
  halted: "halted",
  unHaltRequested: "unHaltRequested",
  deletedByCustomer: "deletedByCustomer",
  deletedByAdmin: "deletedByAdmin",
};

const verificationDocumentWritten = onDocumentWritten(
    "VerificationDocument/{docId}",
    async (event) => {
      const docData = event.data.after.data();

      if (!docData) {
        console.log("Document is deleted. Exiting function.");
        return null;
      }
      const documentId = event.params.docId;
      const docType = docData.documentType;
      const docStatus = docData.status;
      let userId = "";

      // Determine userId based on linkedObjectType
      if (docData.linkedObjectType === VerificationDocumentLinkedObjectType.user) {
        userId = docData.linkedObjectId || "";
      } else if (docData.linkedObjectType === VerificationDocumentLinkedObjectType.car) {
      // Fetch car data from Firestore based on linkedObjectId
        const carSnapshot = await admin.firestore().collection("Car").doc(docData.linkedObjectId).get();
        if (carSnapshot.exists) {
          userId = carSnapshot.data().hostId || "";
        }
      }

      const adminsFCMTokens = await getAdminsFCMTokens();
      const userFCMToken = await getUserFCMToken(userId);

      const documentName = getReadableDocumentType(docType);

      switch (docStatus) {
        case VerificationDocumentStatus.uploaded:
          // Admins Notifications
          for (const {fcmToken, userId} of adminsFCMTokens) {
            await sendNotification(
                `New ${documentName} Uploaded`,
                `${documentName} with reference number ${docData.referenceNumber} has been Uploaded`,
                fcmToken,
                userId,
                documentId,
                docData.documentType,
            );
          }
          // No User Notification
          break;
        case VerificationDocumentStatus.updated:
          // Admins Notifications
          for (const {fcmToken, userId} of adminsFCMTokens) {
            await sendNotification(
                `${documentName} Updated`,
                `${documentName} with reference number ${docData.referenceNumber} has been Updated`,
                fcmToken,
                userId,
                documentId,
                docData.documentType,
            );
          }
          // No User Notification
          break;
        case VerificationDocumentStatus.pendingApproval:

          // Admins Notifications
          for (const {fcmToken, userId} of adminsFCMTokens) {
            await sendNotification(
                `${documentName} Pending Approval`,
                `${documentName} with reference number ${docData.referenceNumber} is Pending Approval`,
                fcmToken,
                userId,
                documentId,
                docData.documentType,
            );
          }
          // No User Notification
          break;
        case VerificationDocumentStatus.approved:

          // No Admins Notifications
          // User Notification
          await sendNotification(
              `${documentName} Approved`,
              `${documentName} with reference number ${docData.referenceNumber} has been Approved`,
              userFCMToken,
              userId,
              documentId,
              docData.documentType,
          );
          break;
        case VerificationDocumentStatus.rejected:

          // No Admins Notifications
          // User Notification
          await sendNotification(
              `${documentName} Rejected`,
              `${documentName} with reference number ${docData.referenceNumber} has been Rejected`,
              userFCMToken,
              userId,
              documentId,
              docData.documentType,
          );
          break;
        case VerificationDocumentStatus.halted:
          // No Admins Notifications
          // User Notification
          await sendNotification(
              `${documentName} Halted`,
              `${documentName} with reference number ${docData.referenceNumber} has been Halted`,
              userFCMToken,
              userId,
              documentId,
              docData.documentType,
          );
          break;
        case VerificationDocumentStatus.unHaltRequested:
          // Admins Notifications
          for (const {fcmToken, userId} of adminsFCMTokens) {
            await sendNotification(
                `${documentName} Unhalt Requested`,
                `${documentName} with reference number ${docData.referenceNumber} has an Unhalt Request`,
                fcmToken,
                userId,
                documentId,
                docData.documentType,
            );
          }
          // No User Notification
          break;
        case VerificationDocumentStatus.deletedByCustomer:
          // Admins Notifications
          for (const {fcmToken, userId} of adminsFCMTokens) {
            await sendNotification(
                `${documentName} Deleted by Customer`,
                `${documentName} with reference number ${docData.referenceNumber} has been Deleted by Customer`,
                fcmToken,
                userId,
                documentId,
                docData.documentType,
            );
          }
          // No User Notification
          break;
        case VerificationDocumentStatus.deletedByAdmin:
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
  verificationDocumentWritten,
};

