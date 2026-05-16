"use client";

import { useState } from "react";
import Image from "next/image";
import { useRouter } from "next/navigation";
import { Loader2 } from "lucide-react";
import { useAuth } from "@/lib/hooks/use-auth";

export default function LoginPage() {
  const router = useRouter();
  const { loginGoogle, loginApple } = useAuth();
  const [isGoogleLoading, setIsGoogleLoading] = useState(false);
  const [isAppleLoading, setIsAppleLoading] = useState(false);

  const handleGoogle = async () => {
    setIsGoogleLoading(true);
    const success = await loginGoogle();
    setIsGoogleLoading(false);
    if (success) router.push("/");
  };

  const handleApple = async () => {
    setIsAppleLoading(true);
    const success = await loginApple();
    setIsAppleLoading(false);
    if (success) router.push("/");
  };

  return (
    <div className="flex min-h-svh flex-col items-center bg-gradient-to-b from-background to-page">
      <div className="relative flex w-full max-w-md flex-1 flex-col px-6 py-6">
        <button
          onClick={() => router.back()}
          className="me-auto flex h-10 w-10 items-center justify-center rounded-xl text-foreground/45 hover:bg-foreground/[0.04]"
        >
          ✕
        </button>

        <div className="mt-3 flex flex-col items-center">
          <div className="relative h-[110px] w-[110px]">
            <div className="absolute inset-0 rounded-full bg-primary/20 blur-[48px]" />
            <div className="absolute inset-0 rounded-full bg-terracotta/12 blur-[64px]" />
            <Image
              src="/images/logo.png"
              alt="فرخة"
              width={110}
              height={110}
              className="relative z-10 object-contain"
            />
          </div>
          <h1 className="mt-5 text-display-lg text-primary">فرخة</h1>
          <p className="mt-1 text-body-sm text-foreground/50">
            دليلك الذكي لتربية الدواجن
          </p>
        </div>

        <div className="flex-1" />

        <div className="rounded-3xl border border-border/50 bg-card p-6 py-8 shadow-[0_8px_32px_rgba(0,0,0,0.05)]">
          <h2 className="text-center text-headline-md text-foreground">
            أهلاً بك
          </h2>
          <p className="mt-1.5 text-center text-body-sm text-foreground/50">
            سجّل دخولك للوصول لجميع أدواتك
          </p>

          <div className="mt-7">
            <button
              onClick={handleGoogle}
              disabled={isGoogleLoading || isAppleLoading}
              className="flex h-[54px] w-full items-center justify-center gap-3 rounded-2xl border border-border/35 bg-page transition-colors hover:bg-border/20 disabled:opacity-50"
            >
              {isGoogleLoading ? (
                <Loader2 className="h-5 w-5 animate-spin text-primary" />
              ) : (
                <>
                  <span className="flex h-[22px] w-[22px] items-center justify-center rounded-full bg-white text-sm font-bold text-[#4285F4] shadow-sm">
                    G
                  </span>
                  <span className="text-label-lg text-foreground">
                    المتابعة بحساب Google
                  </span>
                </>
              )}
            </button>
          </div>

          <div className="mt-5">
            <button
              onClick={handleApple}
              disabled={isGoogleLoading || isAppleLoading}
              className="flex h-[54px] w-full items-center justify-center gap-3 rounded-2xl bg-black text-white transition-colors hover:bg-black/90 disabled:opacity-50 dark:bg-white dark:text-black dark:hover:bg-white/90"
            >
              {isAppleLoading ? (
                <Loader2 className="h-5 w-5 animate-spin" />
              ) : (
                <>
                  <svg className="h-[22px] w-[22px]" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z" />
                  </svg>
                  <span className="text-label-lg">المتابعة بحساب Apple</span>
                </>
              )}
            </button>
          </div>

          <div className="mt-5 flex items-center gap-3.5">
            <div className="h-px flex-1 bg-border/25" />
            <svg className="h-3.5 w-3.5 text-foreground/22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
            <div className="h-px flex-1 bg-border/25" />
          </div>
          <p className="mt-3 text-center text-label-sm text-foreground/30">
            تسجيل دخول آمن ومحمي
          </p>
        </div>

        <div className="flex-1" />

        <div className="flex justify-center gap-6 pb-6">
          <FeaturePill icon="🔧" label="كل الأدوات" />
          <FeaturePill icon="☁️" label="حفظ البيانات" />
          <FeaturePill icon="💬" label="تواصل" />
        </div>
      </div>
    </div>
  );
}

function FeaturePill({ icon, label }: { icon: string; label: string }) {
  return (
    <div className="flex flex-col items-center gap-1.5">
      <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary/8 text-lg">
        {icon}
      </div>
      <span className="text-label-sm text-foreground/50">{label}</span>
    </div>
  );
}
