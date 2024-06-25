/* eslint-disable max-len */
// helpers.js
const {messaging, admin} = require("./firebase");


/**
 * Sends a notification to the specified token.
 * @param {string} title - The title of the notification.
 * @param {string} body - The body of the notification.
 * @param {string} token - The FCM token of the recipient.
 * @param {string} userId - The ID of the recipient user.
 * @param {string} linkedObjectId - The ID of the linked object.
 * @param {string} linkedObjectType - The type of the linked object.
 */
async function sendNotification(title, body, token, userId, linkedObjectId, linkedObjectType) {
  const notificationDoc = {
    userId: userId,
    title: title,
    body: body,
    linkedObjectId: linkedObjectId,
    linkedObjectType: linkedObjectType,
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await admin.firestore().collection("Notification").add(notificationDoc);

  const userSnapshot = await admin.firestore().collection("User").doc(userId).get();
  const notificationsEnabled = userSnapshot.data().notificationsEnabled;

  if (!notificationsEnabled) {
    return;
  }

  if (!token) {
    console.error("FCM Token is required to send a notification. current token: ", token);
    return;
  }
  const message = {
    notification: {title, body},
    token,
  };
  try {
    await messaging.send(message);
    console.log(`Notification sent successfully to FCM Token: ${token}`);
  } catch (error) {
    console.error("Error sending notification:", error);
  }
}

// create js doc for this function
/**
 * Gets the FCM token for the specified user ID.
 * @param {string} userId - The ID of the user.
 * @return {Promise<string>} The FCM token of the user.
 */
async function getUserFCMToken(userId) {
  // Implementation to fetch FCM token from Firestore based on user ID
  const userSnapshot = await admin.firestore().
      collection("User").doc(userId).get();
  const fcmToken = userSnapshot.data().userFcmToken;
  return fcmToken;
}

// create a method called getAdminsFCMTokens

// create a method called getAdminsFCMTokens
/**
 * Gets the FCM tokens for all admin users.
 * @return {Promise<string[]>} The FCM tokens of all admin users.
 */
async function getAdminsFCMTokens() {
  // Implementation to fetch FCM tokens and user IDs from Firestore for all admin users
  const adminsSnapshot = await admin.firestore()
      .collection("User")
      .where("userRole", "in", ["primaryAdmin", "secondaryAdmin"])
      .get();
  const fcmTokens = [];
  adminsSnapshot.forEach((doc) => {
    const data = doc.data();
    const fcmToken = data.userFcmToken;
    const userId = doc.id;
    fcmTokens.push({fcmToken, userId});
  });
  return fcmTokens;
}

module.exports = {
  sendNotification,
  getUserFCMToken,
  getAdminsFCMTokens,
};
