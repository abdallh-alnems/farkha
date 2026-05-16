import { initializeApp } from "firebase/app";
import { getMessaging, onBackgroundMessage } from "firebase/messaging/sw";

const firebaseConfig = {
  apiKey: "AIzaSyA4XoHCbInnVq9w8PwVdbDAihjY4FXCQo8",
  authDomain: "farkha-c7248.firebaseapp.com",
  projectId: "farkha-c7248",
  storageBucket: "farkha-c7248.firebasestorage.app",
  messagingSenderId: "47209702514",
  appId: "1:47209702514:web:9efae22f0b2de0c03b3b8c",
};

const app = initializeApp(firebaseConfig);
const messaging = getMessaging(app);

onBackgroundMessage(messaging, (payload) => {
  const { title, body } = payload.notification ?? {};
  if (title) {
    self.registration.showNotification(title, {
      body: body ?? "",
      icon: "/icons/pwa-192.png",
    });
  }
});
