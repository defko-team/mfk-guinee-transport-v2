/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const onRequest = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialiser Firebase Admin
admin.initializeApp();

exports.sendNotification = functions.https.onRequest(async (req, res) => {
    try {
        // Valider les paramètres d'entrée
        const { fcmToken, title, body } = req.body;

        if (!fcmToken || !title || !body) {
            return res.status(400).send({ error: "fcmToken, title, and body are required" });
        }

        // Définir le message de notification
        const message = {
            notification: {
                title: title,
                body: body,
            },
            token: fcmToken,
        };

        // Envoyer la notification
        const response = await admin.messaging().send(message);
        console.log("Notification sent successfully:", response);

        res.status(200).send({ success: true, response });
    } catch (error) {
        console.error("Error sending notification:", error);
        res.status(500).send({ error: error.message });
    }
});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
