"use client";

import { CalcTool } from "@/components/tools/calc-tool";

export default function WaterConsumptionPage() {
  return (
    <CalcTool
      title="استهلاك الماء"
      fields={[
        { key: "birds", label: "عدد الطيور", placeholder: "مثال: 10000" },
        { key: "waterPerBird", label: "استهلاك الماء لكل طائر (مل/يوم)", placeholder: "مثال: 250" },
      ]}
      calculate={(v) => {
        const dailyLiters = (v.birds * v.waterPerBird) / 1000;
        return [
          { label: "استهلاك الماء اليومي (لتر)", value: dailyLiters.toFixed(1) },
          { label: "استهلاك الماء اليومي (م³)", value: (dailyLiters / 1000).toFixed(3) },
        ];
      }}
    />
  );
}
