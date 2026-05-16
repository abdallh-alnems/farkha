"use client";

import { CalcTool } from "@/components/tools/calc-tool";

export default function TotalFeedConsumptionPage() {
  return (
    <CalcTool
      title="استهلاك العلف الكلي"
      fields={[
        { key: "birds", label: "عدد الطيور", placeholder: "مثال: 10000" },
        { key: "days", label: "عدد أيام الدورة", placeholder: "مثال: 35" },
        { key: "feedPerBirdDay", label: "متوسط استهلاك العلف (جم/طائر/يوم)", placeholder: "مثال: 100" },
      ]}
      calculate={(v) => {
        const totalGrams = v.birds * v.days * v.feedPerBirdDay;
        const totalKg = totalGrams / 1000;
        return [
          { label: "إجمالي استهلاك العلف (كجم)", value: totalKg.toFixed(1) },
          { label: "إجمالي استهلاك العلف (طن)", value: (totalKg / 1000).toFixed(3) },
          { label: "استهلاك العلف لكل طائر (كجم)", value: ((v.days * v.feedPerBirdDay) / 1000).toFixed(2) },
        ];
      }}
    />
  );
}
