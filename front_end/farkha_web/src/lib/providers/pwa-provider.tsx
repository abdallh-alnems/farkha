"use client";

import { useEffect } from "react";
import { useAuthStore } from "@/lib/stores/auth-store";
import { requestNotificationPermission } from "@/lib/firebase/notifications";
import { updateFcmToken } from "@/lib/api/auth";
import { getAuthToken } from "@/lib/hooks/use-auth-token";

export function PwaProvider({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    if ("serviceWorker" in navigator) {
      navigator.serviceWorker.register("/sw.js").catch(() => {});
      navigator.serviceWorker
        .register("/firebase-messaging-sw.js")
        .catch(() => {});
    }
  }, []);

  useEffect(() => {
    const registerFcm = async () => {
      const { isLoggedIn } = useAuthStore.getState();
      if (!isLoggedIn) return;

      const token = await getAuthToken();
      if (!token) return;

      const fcmToken = await requestNotificationPermission();
      if (fcmToken) {
        await updateFcmToken(token, fcmToken);
      }
    };

    registerFcm();
  }, []);

  return <>{children}</>;
}
