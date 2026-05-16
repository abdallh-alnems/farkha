"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Phone, Shield } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { sendOtp } from "@/lib/api/auth";
import { getFirebaseToken } from "@/lib/firebase/auth";
import { toast } from "sonner";

export default function VerifyPhonePage() {
  const router = useRouter();
  const [phone, setPhone] = useState("");
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const handleSend = async () => {
    const trimmed = phone.trim();
    if (!trimmed || trimmed.length < 10) {
      setError("أدخل رقم هاتف صحيح");
      return;
    }
    setError("");
    setIsLoading(true);

    try {
      const token = await getFirebaseToken(true);
      if (!token) {
        setError("يرجى تسجيل الدخول أولاً");
        setIsLoading(false);
        return;
      }

      const response = await sendOtp(token, trimmed);
      const resp = response as unknown as Record<string, unknown>;
      const errObj = (resp.error ?? {}) as Record<string, unknown>;
      const sessionToken =
        (resp.session_token as string) ??
        (errObj.session_token as string) ??
        "";
      const errMessage =
        (resp.message as string) ??
        (errObj.message as string) ??
        "";
      const isSuccess =
        resp.success === true || resp.status === "success";

      if (isSuccess || sessionToken) {
        if (isSuccess) {
          toast.success("تم إرسال رمز التحقق");
        } else {
          toast.info(errMessage || "تم إرسال الرمز");
        }
        router.push(
          `/enter-otp?phone=${encodeURIComponent(trimmed)}&session=${encodeURIComponent(sessionToken)}`,
        );
      } else {
        setError(errMessage || "فشل إرسال الرمز");
      }
    } catch (err) {
      setError(`فشل الاتصال بالخادم: ${String(err)}`);
    } finally {
      setIsLoading(false);
    }
  };

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
          <div className="relative flex h-20 w-20 items-center justify-center">
            <div className="absolute inset-0 rounded-full bg-primary/10 shadow-[0_0_24px_4px_rgba(78,122,62,0.15)]" />
            <Phone className="relative z-10 h-8 w-8 text-primary" />
            <div className="absolute -bottom-0.5 -right-0.5 flex h-6.5 w-6.5 items-center justify-center rounded-full border-2 border-background bg-terracotta">
              <Shield className="h-3.5 w-3.5 text-white" />
            </div>
          </div>

          <h1 className="mt-6 text-display-sm text-primary">
            تأكيد رقم الهاتف
          </h1>
          <p className="mt-2 text-center text-body-sm text-foreground/55">
            سجّل رقمك لتأكيد هويتك وحماية حسابك
          </p>

          <div className="mt-8 w-full" dir="ltr">
            <div className="flex gap-3">
              <div className="flex h-11 w-[72px] items-center justify-center rounded-xl border border-border bg-surface text-body-md font-semibold text-foreground">
                🇪🇬 +20
              </div>
              <Input
                type="tel"
                placeholder="01xxxxxxxxx"
                value={phone}
                onChange={(e) => {
                  setPhone(e.target.value);
                  if (error) setError("");
                }}
                className="h-11 flex-1 rounded-xl text-base"
                maxLength={11}
              />
            </div>
            {error && (
              <p className="mt-2 text-body-sm text-destructive">{error}</p>
            )}
          </div>

          <div className="mt-6 w-full">
            <Button
              onClick={handleSend}
              disabled={isLoading}
              className="h-12 w-full rounded-2xl text-label-lg"
              size="lg"
            >
              {isLoading ? "جاري الإرسال..." : "إرسال رمز التحقق"}
            </Button>
          </div>

          <div className="mt-5 flex items-center gap-1.5 text-foreground/35">
            <span className="text-sm">💬</span>
            <span className="text-label-sm">سيتم إرسال الرمز عبر واتساب</span>
          </div>
        </div>
      </div>
    </div>
  );
}
