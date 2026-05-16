"use client";

import { CalcTool } from "@/components/tools/calc-tool";

export default function DailyFeedConsumptionPage() {
  return (
    <CalcTool
      title="استهلاك العلف اليومي"
      fields={[
        { key: "birds", label: "عدد الطيور", placeholder: "مثال: 10000" },
        { key: "feedPerBird", label: "استهلاك العلف لكل طائر (جم/يوم)", placeholder: "مثال: 120" },
      ]}
      calculate={(v) => {
        const dailyTotal = (v.birds * v.feedPerBird) / 1000;
        return [
          { label: "استهلاك العلف اليومي (كجم)", value: dailyTotal.toFixed(1) },
          { label: "استهلاك العلف اليومي (طن)", value: (dailyTotal / 1000).toFixed(3) },
        ];
      }}
    />
  );
}
