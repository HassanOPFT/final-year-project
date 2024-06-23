// const functions = require("firebase-functions");
// const logger = require("firebase-functions/logger");

// Import the VerificationDocument functions
const {
  verificationDocumentCreated,
  verificationDocumentUpdated,
  verificationDocumentDeleted,
  verificationDocumentWritten,
} = require("./verificationDocumentFunctions").default;

// Export the VerificationDocument functions
exports.verificationDocumentCreated = verificationDocumentCreated;
exports.verificationDocumentUpdated = verificationDocumentUpdated;
exports.verificationDocumentDeleted = verificationDocumentDeleted;
exports.verificationDocumentWritten = verificationDocumentWritten;

// You can add more functions here as needed

// /**
//  * Import function triggers from their respective submodules:
//  *
//  * const {onCall} = require("firebase-functions/v2/https");
//  * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
//  *
//  * See a full list of supported triggers at https://firebase.google.com/docs/functions
//  */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
