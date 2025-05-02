const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.deleteUserFromFirestore = functions.https.onRequest(async (req, res) => {
  // Si GET sans paramètre, juste répondre 200 OK
  if (req.method === "GET" && !req.query.userId) {
    return res.status(200).send("OK");
  }

  // Vérifie méthode GET avec paramètre userId
  if (req.method !== "GET") {
    return res.status(405).send("Méthode non autorisée");
  }

  const userId = req.query.userId;

  if (!userId) {
    return res.status(400).send("Paramètre 'userId' requis");
  }

  try {
    await admin.firestore().collection("users").doc(userId).delete();
    return res.status(200).send(`Utilisateur ${userId} supprimé avec succès`);
  } catch (error) {
    console.error("Erreur :", error);
    return res.status(500).send("Erreur serveur");
  }
});
