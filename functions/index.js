
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {setGlobalOptions} = require("firebase-functions/v2");

setGlobalOptions({
  region: "asia-south1",
  maxInstances: 5,
});

// Basic emergency keyword detection in English and Hindi.
const EMERGENCY_TERMS = [
  "chest pain",
  "difficulty breathing",
  "can't breathe",
  "cannot breathe",
  "unconscious",
  "seizure",
  "overdose",
  "severe bleeding",
  "बेहोश",
  "सांस नहीं",
  "साँस नहीं",
  "सीने में दर्द",
  "ज्यादा दवा",
  "अधिक मात्रा",
];

exports.askMedicineAssistant = onCall(
    {
    // Enable and enforce App Check before production.
      enforceAppCheck: false,
    },
    async (request) => {
    // Require Firebase Authentication.
      if (!request.auth) {
        throw new HttpsError(
            "unauthenticated",
            "Please log in to use the Medicine Assistant.",
        );
      }

      // Read and validate the message.
      const message =
      request.data &&
      typeof request.data.message === "string" ?
        request.data.message.trim() :
        "";

      const language =
      request.data && request.data.language === "hi" ?
        "hi" :
        "en";

      if (!message || message.length > 1000) {
        throw new HttpsError(
            "invalid-argument",
            "Enter a message of up to 1000 characters.",
        );
      }

      const normalizedMessage = message.toLowerCase();

      const emergencyDetected = EMERGENCY_TERMS.some(
          (term) => normalizedMessage.includes(term),
      );

      // Give an emergency warning when a keyword matches.
      if (emergencyDetected) {
        const emergencyReply = language === "hi" ?
        "यह आपातकाल हो सकता है। कृपया तुरंत स्थानीय आपातकालीन " +
        "सेवा या नजदीकी अस्पताल से संपर्क करें। ऑनलाइन जवाब " +
        "की प्रतीक्षा न करें।" :
        "This may be a medical emergency. Contact your local " +
        "emergency service or go to the nearest emergency " +
        "department now. Do not wait for an online reply.";

        return {
          reply: emergencyReply,
          emergency: true,
        };
      }

      // Safe starter response. No AI provider is connected yet.
      const generalReply = language === "hi" ?
      "मैं दवाओं के बारे में सामान्य जानकारी देने के लिए बनाया " +
      "गया सहायक हूँ। अभी मेरा चिकित्सा जानकारी स्रोत कनेक्ट " +
      "नहीं है। दवा की खुराक बदलने या नई दवा लेने से पहले " +
      "डॉक्टर या फार्मासिस्ट से सलाह लें।" :
      "I can help with general medicine information, but my " +
      "reviewed medical information source is not connected " +
      "yet. Ask a doctor or pharmacist before starting a " +
      "medicine or changing its dose.";

      return {
        reply: generalReply,
        emergency: false,
      };
    },
);
