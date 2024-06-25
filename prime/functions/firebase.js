const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const admin = require("firebase-admin");


const adminApp = initializeApp();
const firestore = getFirestore(adminApp);
const messaging = getMessaging(adminApp);

module.exports = {firestore, messaging, admin};
