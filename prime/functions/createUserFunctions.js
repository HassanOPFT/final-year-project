/* eslint-disable max-len */
const functions = require("firebase-functions");
const {getAuth} = require("firebase-admin/auth");

exports.createUser = functions.https.onCall(async (data, context) => {
  const {email, password, displayName} = data;

  try {
    console.log("Admin performing the action:", context.auth.token.email);

    // Check if the caller is authenticated and authorized
    if (!context.auth || !context.auth.token.admin) {
      throw new functions.https.HttpsError(
          "permission-denied",
          "Must be an administrative user to create other users and grant admin permissions.",
      );
    }
    // Create the user using Firebase Admin SDK
    const userRecord = await getAuth().createUser({
      email: email,
      password: password,
      displayName: displayName,
    });

    console.log(`Successfully created new user with UID: ${userRecord.uid}`);

    // Log the admin user performing the action
    console.log("Admin performing the action:", context.auth.token.email);

    // Return the UID of the newly created user
    return {
      uid: userRecord.uid,
    };
  } catch (error) {
    console.error("Error creating user:", error);
    throw new functions.https.HttpsError(
        "internal",
        "Error creating user",
        error.message,
    );
  }
});
