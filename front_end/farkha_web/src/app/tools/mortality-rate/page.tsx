"use client";

import { CalcTool } from "@/components/tools/calc-tool";

export default function MortalityRatePage() {
  return (
    <CalcTool
      title="نسبة النفوق"
      fields={[
        { key: "dead", label: "عدد النافق", placeholder: "مثال: 200" },
        { key: "total", label: "إجمالي عدد الطيور", placeholder: "مثال: 10000" },
      ]}
      calculate={(v) => {
        if (v.total === 0) return null;
        const rate = (v.dead / v.total) * 100;
        const surviving = v.total - v.dead;
        return [
          { label: "نسبة النفوق (%)", value: `${rate.toFixed(2)}%` },
          { label: "عدد الطيور الباقية", value: surviving.toFixed(0) },
          { label: "نسبة البقاء (%)", value: `${(100 - rate).toFixed(2)}%` },
        ];
      }}
    />
  );
}
