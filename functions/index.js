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
    // Validate request method
    if (req.method !== 'POST') {
        return res.status(405).send({ error: 'Method not allowed. Use POST.' });
    }

    try {
        // Validate input parameters
        const { fcmToken, title, body } = req.body;

        if (!fcmToken || !title || !body) {
            return res.status(400).send({ 
                error: "Missing required parameters",
                details: {
                    fcmToken: !fcmToken ? "Token is required" : null,
                    title: !title ? "Title is required" : null,
                    body: !body ? "Body is required" : null
                }
            });
        }

        // Define notification message with improved configuration
        const message = {
            notification: {
                title: title,
                body: body,
            },
            data: {
                title: title,
                body: body,
                timestamp: Date.now().toString(),
            },
            android: {
                notification: {
                    sound: 'default',
                    priority: 'high',
                    defaultSound: true,
                    channelId: 'high_importance_channel',
                    visibility: 'public',
                    vibrateTimingsMillis: [200, 500, 200],
                },
                priority: 'high',
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        badge: 1,
                    },
                },
            },
            token: fcmToken,
        };

        // Send notification with retry logic
        let retries = 3;
        let lastError = null;

        while (retries > 0) {
            try {
                const response = await admin.messaging().send(message);
                logger.info("Notification sent successfully:", response);
                return res.status(200).send({ 
                    success: true, 
                    messageId: response,
                    timestamp: Date.now()
                });
            } catch (error) {
                lastError = error;
                retries--;
                if (retries > 0) {
                    await new Promise(resolve => setTimeout(resolve, 1000)); // Wait 1s before retry
                }
            }
        }

        // If all retries failed
        logger.error("Failed to send notification after retries:", lastError);
        throw lastError;

    } catch (error) {
        logger.error("Error in sendNotification:", error);
        return res.status(500).send({
            error: "Failed to send notification",
            details: error.message,
            code: error.code
        });
    }
});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
