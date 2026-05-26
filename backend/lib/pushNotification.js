import admin from 'firebase-admin';
import path from 'path';
import fs from 'fs';

let isFirebaseInitialized = false;

// Attempt to initialize Firebase Admin SDK
try {
  let serviceAccount;

  // Option 1: Read from Railway Environment Variable (easiest for deployment)
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    console.log('📦 Using Firebase credentials from Environment Variable.');
  } 
  // Option 2: Read from local JSON file (easiest for local development)
  else {
    const serviceAccountPath = path.resolve(process.cwd(), 'firebase-service-account.json');
    if (fs.existsSync(serviceAccountPath)) {
      serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
      console.log('📄 Using Firebase credentials from local file.');
    }
  }

  if (serviceAccount) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    
    isFirebaseInitialized = true;
    console.log('✅ Firebase Admin SDK initialized successfully.');
  } else {
    console.warn('⚠️ Firebase credentials not found. Push notifications will be simulated but not delivered.');
  }
} catch (error) {
  console.error('❌ Error initializing Firebase Admin SDK:', error.message);
}

/**
 * Sends a push notification to a specific device token.
 * 
 * @param {string} token - The FCM token of the target device.
 * @param {string} title - The title of the notification.
 * @param {string} body - The body message of the notification.
 * @param {object} data - Optional extra data payload.
 */
export const sendPushNotification = async (token, title, body, data = {}) => {
  if (!token) {
    console.log('Push notification skipped: No FCM token provided.');
    return;
  }

  const message = {
    notification: {
      title,
      body,
    },
    data,
    token,
  };

  if (!isFirebaseInitialized) {
    // If Firebase isn't configured yet, we just log it to the console
    console.log('\n======================================================');
    console.log('📢 SIMULATED PUSH NOTIFICATION:');
    console.log(`TO: ${token}`);
    console.log(`TITLE: ${title}`);
    console.log(`BODY: ${body}`);
    console.log('======================================================\n');
    return;
  }

  try {
    const response = await admin.messaging().send(message);
    console.log('Successfully sent push notification:', response);
    return response;
  } catch (error) {
    console.error('Error sending push notification:', error);
    throw error;
  }
};
