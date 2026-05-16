"use client";

import { useState, useCallback, useEffect, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { Lock, Phone, MessageCircle } from "lucide-react";
import {
  InputOTP,
  InputOTPGroup,
  InputOTPSlot,
} from "@/components/ui/input-otp";
import { Button } from "@/components/ui/button";
import { verifyOtp, resendOtp } from "@/lib/api/auth";
import { getFirebaseToken } from "@/lib/firebase/auth";
import { useAuthStore } from "@/lib/stores/auth-store";
import { toast } from "sonner";

function EnterOtpContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const phone = searchParams.get("phone") ?? "";
  const sessionToken = searchParams.get("session") ?? "";
  const updateUser = useAuthStore((s) => s.updateUser);

  const [otp, setOtp] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");
  const [resendCountdown, setResendCountdown] = useState(60);
  const [canResend, setCanResend] = useState(false);

  useEffect(() => {
    if (resendCountdown <= 0) {
      setCanResend(true);
      return;
    }
    const timer = setInterval(() => {
      setResendCountdown((prev) => prev - 1);
    }, 1000);
    return () => clearInterval(timer);
  }, [resendCountdown]);

  const handleVerify = useCallback(
    async (code: string) => {
      if (code.length < 6) return;
      setIsLoading(true);
      setError("");

      try {
        const token = await getFirebaseToken(true);
        if (!token) {
          setError("يرجى تسجيل الدخول أولاً");
          setIsLoading(false);
          return;
        }

        const response = await verifyOtp(token, sessionToken, code);
        if (response.success && response.verified) {
          updateUser({ phone });
          toast.success("تم تأكيد رقم الهاتف بنجاح");
          router.push("/");
        } else {
          setError(response.message ?? "رمز التحقق غير صحيح");
          setOtp("");
        }
      } catch {
        setError("فشل الاتصال بالخادم");
        setOtp("");
      } finally {
        setIsLoading(false);
      }
    },
    [phone, sessionToken, router, updateUser],
  );

  const handleResend = async () => {
    setCanResend(false);
    setResendCountdown(60);
    setOtp("");
    setError("");

    try {
      const token = await getFirebaseToken(true);
      if (!token) {
        setError("يرجى تسجيل الدخول أولاً");
        return;
      }

      const response = await resendOtp(token, sessionToken);
      if (!response.success) {
        setError(response.message ?? "فشل إعادة الإرسال");
      } else {
        toast.success("تم إعادة إرسال الرمز");
      }
    } catch {
      setError("فشل الاتصال بالخادم");
    }
  };

  const displayPhone = phone.startsWith("+20")
    ? `0${phone.substring(3)}`
    : phone;

  return (
    <div className="flex min-h-svh flex-col items-center bg-gradient-to-b from-background to-page">
      <div className="flex w-full max-w-md flex-1 flex-col px-6 py-6">
        <button
          onClick={() => router.back()}
          className="me-auto flex h-10 w-10 items-center justify-center rounded-xl text-foreground/45 hover:bg-foreground/[0.04]"
        >
          →
        </button>

        <div className="mt-4 flex flex-1 flex-col items-center">
          <div className="flex h-16 w-16 items-center justify-center rounded-full bg-primary/10 shadow-[0_0_20px_3px_rgba(78,122,62,0.12)]">
            <Lock className="h-7 w-7 text-primary" />
          </div>

          <h1 className="mt-5 text-headline-lg text-primary">
            أدخل رمز التحقق
          </h1>
          <p className="mt-2 text-center text-body-sm text-foreground/55">
            تم إرسال الرمز إلى
          </p>

          <div
            className="mt-1.5 flex items-center gap-1.5 rounded-xl bg-primary/8 px-3.5 py-1.5"
            dir="ltr"
          >
            <Phone className="h-3.5 w-3.5 text-primary" />
            <span className="text-body-md font-bold text-primary tracking-wide">
              {displayPhone}
            </span>
          </div>

          <div className="mt-8" dir="ltr">
            <InputOTP
              maxLength={6}
              value={otp}
              onChange={(value) => {
                setOtp(value);
                setError("");
              }}
              onComplete={handleVerify}
            >
              <InputOTPGroup>
                <InputOTPSlot index={0} />
                <InputOTPSlot index={1} />
                <InputOTPSlot index={2} />
                <InputOTPSlot index={3} />
                <InputOTPSlot index={4} />
                <InputOTPSlot index={5} />
              </InputOTPGroup>
            </InputOTP>
          </div>

          {error && (
            <div className="mt-4 w-full rounded-xl border border-destructive/25 bg-destructive/6 px-3.5 py-3 text-body-sm text-destructive">
              {error}
            </div>
          )}

          {isLoading && (
            <div className="mt-4 text-body-sm text-primary">
              جاري التحقق...
            </div>
          )}

          <div className="mt-5">
            {canResend ? (
              <Button
                variant="ghost"
                onClick={handleResend}
                className="text-label-md text-primary"
              >
                إعادة إرسال الرمز
              </Button>
            ) : (
              <p className="text-body-sm text-foreground/40">
                إعادة الإرسال بعد {resendCountdown} ثانية
              </p>
            )}
          </div>

          <div className="mt-3 flex items-center gap-1 text-foreground/30">
            <MessageCircle className="h-3.5 w-3.5" />
            <span className="text-label-sm">تم الإرسال عبر واتساب</span>
          </div>
        </div>
      </div>
    </div>
  );
}

export default function EnterOtpPage() {
  return (
    <Suspense
      fallback={
        <div className="flex min-h-svh items-center justify-center">
          جاري التحميل...
        </div>
      }
    >
      <EnterOtpContent />
    </Suspense>
  );
}
