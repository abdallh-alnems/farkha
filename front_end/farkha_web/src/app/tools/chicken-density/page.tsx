"use client";

import { CalcTool } from "@/components/tools/calc-tool";

export default function ChickenDensityPage() {
  return (
    <CalcTool
      title="كثافة الفراخ"
      fields={[
        { key: "birds", label: "عدد الطيور", placeholder: "مثال: 10000" },
        { key: "area", label: "مساحة المزرعة (م²)", placeholder: "مثال: 500" },
      ]}
      calculate={(v) => {
        if (v.area === 0) return null;
        const density = v.birds / v.area;
        return [
          { label: "الكثافة (طائر/م²)", value: density.toFixed(1) },
          { label: "المساحة لكل طائر (م²)", value: (1 / density).toFixed(3) },
          {
            label: "التقييم",
            value: density <= 12 ? "ممتاز — مساحة مريحة" : density <= 16 ? "جيد" : density <= 20 ? "مقبول" : "عالي — خطر على صحة الطيور",
          },
        ];
      }}
    />
  );
}
