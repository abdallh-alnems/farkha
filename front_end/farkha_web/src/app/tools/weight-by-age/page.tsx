"use client";

import { CalcTool } from "@/components/tools/calc-tool";

export default function WeightByAgePage() {
  return (
    <CalcTool
      title="الوزن حسب العمر"
      fields={[
        { key: "adg", label: "متوسط النمو اليومي (جم)", placeholder: "مثال: 50" },
        { key: "days", label: "عمر الطيور (يوم)", placeholder: "مثال: 35" },
        { key: "initialWeight", label: "وزن الكتاكيت عند البداية (جم)", placeholder: "مثال: 42" },
      ]}
      calculate={(v) => {
        const weightGrams = v.initialWeight + v.adg * v.days;
        return [
          { label: "الوزن المتوقع (كجم)", value: (weightGrams / 1000).toFixed(3) },
          { label: "الوزن المتوقع (جم)", value: weightGrams.toFixed(0) },
        ];
      }}
    />
  );
}
