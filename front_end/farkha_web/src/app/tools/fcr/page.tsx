"use client";

import { CalcTool } from "@/components/tools/calc-tool";

export default function FCRPage() {
  return (
    <CalcTool
      title="معامل التحويل الغذائي"
      fields={[
        { key: "feed", label: "كمية العلف المستهلكة (كجم)", placeholder: "مثال: 5" },
        { key: "weight", label: "زيادة الوزن (كجم)", placeholder: "مثال: 2" },
      ]}
      calculate={(v) => {
        if (v.weight === 0) return null;
        const fcr = v.feed / v.weight;
        return [
          { label: "معامل التحويل الغذائي (FCR)", value: fcr.toFixed(3) },
          {
            label: "التقييم",
            value: fcr <= 1.5 ? "ممتاز" : fcr <= 1.8 ? "جيد جداً" : fcr <= 2.0 ? "جيد" : "يحتاج تحسين",
          },
        ];
      }}
    />
  );
}
