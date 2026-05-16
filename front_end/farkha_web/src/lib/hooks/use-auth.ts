"use client";

import { useCallback, useEffect } from "react";
import { useRouter } from "next/navigation";
import { signInWithGoogle, signInWithApple, signOutUser, getFirebaseToken, onAuthChange } from "@/lib/firebase/auth";
import { loginWithToken } from "@/lib/api/auth";
import { useAuthStore } from "@/lib/stores/auth-store";
import { toast } from "sonner";

export function useAuth() {
  const router = useRouter();
  const { user, isLoggedIn, setUser, setLoggedIn, logout: storeLogout, updateUser } = useAuthStore();

  useEffect(() => {
    const unsubscribe = onAuthChange((firebaseUser) => {
      if (!firebaseUser && isLoggedIn) {
        storeLogout();
      }
    });
    return unsubscribe;
  }, [isLoggedIn, storeLogout]);

  const handleFirebaseLogin = useCallback(async () => {
    const token = await getFirebaseToken(true);
    if (!token) {
      toast.error("فشل الحصول على رمز الدخول");
      return false;
    }

    const response = await loginWithToken(token);
    const isSuccess = response.success || response.status === "success";

    const userData = response.user ?? response.data?.user;

    if (isSuccess && userData) {
      setUser({
        name: userData.name ?? null,
        phone: userData.phone ?? null,
        email: null,
        uid: null,
        photoUrl: null,
      });
      return true;
    }

    toast.error("فشل الاتصال بالخادم");
    return false;
  }, [setUser]);

  const loginGoogle = useCallback(async () => {
    try {
      const firebaseUser = await signInWithGoogle();
      if (!firebaseUser) {
        toast.error("فشل تسجيل الدخول");
        return false;
      }
      return await handleFirebaseLogin();
    } catch (error: unknown) {
      const firebaseError = error as { code?: string };
      if (firebaseError.code === "auth/popup-closed-by-user" || firebaseError.code === "auth/cancelled") {
        return false;
      }
      toast.error(getFirebaseErrorMessage(firebaseError.code ?? ""));
      return false;
    }
  }, [handleFirebaseLogin]);

  const loginApple = useCallback(async () => {
    try {
      const firebaseUser = await signInWithApple();
      if (!firebaseUser) {
        toast.error("فشل تسجيل الدخول");
        return false;
      }
      return await handleFirebaseLogin();
    } catch (error: unknown) {
      const firebaseError = error as { code?: string };
      if (firebaseError.code === "auth/popup-closed-by-user" || firebaseError.code === "auth/cancelled" || firebaseError.code === "auth/web-context-canceled") {
        return false;
      }
      toast.error(getFirebaseErrorMessage(firebaseError.code ?? ""));
      return false;
    }
  }, [handleFirebaseLogin]);

  const logout = useCallback(async () => {
    try {
      await signOutUser();
      storeLogout();
      toast.success("تم تسجيل الخروج بنجاح");
      router.push("/");
    } catch {
      toast.error("حدث خطأ أثناء تسجيل الخروج");
    }
  }, [storeLogout, router]);

  return {
    user,
    isLoggedIn,
    loginGoogle,
    loginApple,
    logout,
    updateUser,
  };
}

function getFirebaseErrorMessage(code: string): string {
  const messages: Record<string, string> = {
    "auth/account-exists-with-different-credential": "يوجد حساب مسجل بهذا البريد بطريقة أخرى",
    "auth/invalid-credential": "بيانات الاعتماد غير صالحة",
    "auth/operation-not-allowed": "تسجيل الدخول غير مفعل",
    "auth/user-disabled": "تم تعطيل هذا الحساب",
    "auth/user-not-found": "لم يتم العثور على المستخدم",
    "auth/network-request-failed": "فشل الاتصال بالشبكة",
    "auth/unauthorized-domain": "النطاق غير مصرح به",
  };
  return messages[code] ?? "حدث خطأ غير متوقع";
}
