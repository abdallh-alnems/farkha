"use client";

import { CalcTool } from "@/components/tools/calc-tool";

export default function ADGPage() {
  return (
    <CalcTool
      title="متوسط النمو اليومي"
      fields={[
        { key: "currentWeight", label: "الوزن الحالي (كجم)", placeholder: "مثال: 2.5" },
        { key: "previousWeight", label: "الوزن السابق (كجم)", placeholder: "مثال: 2.0" },
        { key: "days", label: "عدد الأيام", placeholder: "مثال: 7" },
      ]}
      calculate={(v) => {
        if (v.days === 0) return null;
        const adg = (v.currentWeight - v.previousWeight) / v.days;
        return [
          { label: "متوسط النمو اليومي (ADG)", value: `${adg.toFixed(3)} كجم/يوم` },
          { label: "متوسط النمو اليومي (جرام)", value: `${(adg * 1000).toFixed(1)} جم/يوم` },
        ];
      }}
    />
  );
}
