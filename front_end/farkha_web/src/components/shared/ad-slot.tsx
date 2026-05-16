"use client";

import { useEffect, useRef } from "react";

declare global {
  interface Window {
    adsbygoogle?: unknown[];
  }
}

export function AdSlot() {
  const client = process.env.NEXT_PUBLIC_ADSENSE_CLIENT;
  const slot = process.env.NEXT_PUBLIC_AD_SLOT_ARTICLE;
  const pushed = useRef(false);

  useEffect(() => {
    if (!client || !slot || pushed.current) return;
    try {
      (window.adsbygoogle = window.adsbygoogle || []).push({});
      pushed.current = true;
    } catch {}
  }, [client, slot]);

  if (!client || !slot) return null;

  return (
    <div className="my-6 flex justify-center overflow-hidden">
      <ins
        className="adsbygoogle"
        style={{ display: "block", width: "100%" }}
        data-ad-client={client}
        data-ad-slot={slot}
        data-ad-format="auto"
        data-full-width-responsive="true"
      />
    </div>
  );
}
