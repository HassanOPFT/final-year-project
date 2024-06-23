const {
  onDocumentCreated,
  onDocumentUpdated,
  onDocumentDeleted,
  onDocumentWritten,
} = require("firebase-functions/v2/firestore");
const { info } = require("firebase-functions/logger");

const verificationDocumentCreated = onDocumentCreated(
  "VerificationDocument/{docId}",
  (event) => {
    info("VerificationDocument created", { docId: event.params.docId });
    console.log("VerificationDocument created with ID:", event.params.docId);
  }
);

const verificationDocumentUpdated = onDocumentUpdated(
  "VerificationDocument/{docId}",
  (event) => {
    info("VerificationDocument updated", { docId: event.params.docId });
    console.log("VerificationDocument updated with ID:", event.params.docId);
  }
);

const verificationDocumentDeleted = onDocumentDeleted(
  "VerificationDocument/{docId}",
  (event) => {
    info("VerificationDocument deleted", { docId: event.params.docId });
    console.log("VerificationDocument deleted with ID:", event.params.docId);
  }
);

const verificationDocumentWritten = onDocumentWritten(
  "VerificationDocument/{docId}",
  (event) => {
    info("VerificationDocument written", { docId: event.params.docId });
    console.log("VerificationDocument written with ID:", event.params.docId);
  }
);

module.exports = {
  verificationDocumentCreated,
  verificationDocumentUpdated,
  verificationDocumentDeleted,
  verificationDocumentWritten,
};
