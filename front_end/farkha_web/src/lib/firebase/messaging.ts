import { getMessaging, isSupported, onMessage } from "firebase/messaging";
import { app } from "./config";

let messaging: ReturnType<typeof getMessaging> | null = null;

isSupported().then((supported) => {
  if (supported) {
    messaging = getMessaging(app);
    onMessage(messaging, (payload) => {
      const { title, body } = payload.notification ?? {};
      if (title && body && "Notification" in window) {
        new Notification(title, { body, icon: "/icons/pwa-192.png" });
      }
    });
  }
});

export { messaging };
