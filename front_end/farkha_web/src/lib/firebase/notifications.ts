import { getMessaging, getToken, isSupported } from "firebase/messaging";
import { app } from "./config";

const VAPID_KEY =
  "BBKM2kxHNPycwlcFlXvsApEtP2e4TMlEdsRm7BuZiq4C9VujFp-kiPXfDD1XJxVyb00GsckqXaHMFm2VtaBNqSs";

export async function requestNotificationPermission(): Promise<string | null> {
  const supported = await isSupported();
  if (!supported) return null;

  if (!("Notification" in window)) return null;

  const permission = await Notification.requestPermission();
  if (permission !== "granted") return null;

  try {
    const messaging = getMessaging(app);
    return await getToken(messaging, { vapidKey: VAPID_KEY });
  } catch {
    return null;
  }
}
