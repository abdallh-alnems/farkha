"use client";

import { getFirebaseToken } from "@/lib/firebase/auth";
import { useAuthStore } from "@/lib/stores/auth-store";

export async function getAuthToken(): Promise<string | null> {
  const { isLoggedIn } = useAuthStore.getState();
  if (!isLoggedIn) return null;
  return getFirebaseToken();
}
