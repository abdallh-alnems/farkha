"use client";

import { CalcTool } from "@/components/tools/calc-tool";

export default function FeedCostPerKiloPage() {
  return (
    <CalcTool
      title="تكلفة العلف لكل كيلو وزن"
      fields={[
        { key: "feedPrice", label: "سعر طن العلف (ج.م)", placeholder: "مثال: 18000" },
        { key: "fcr", label: "معامل التحويل الغذائي", placeholder: "مثال: 1.6" },
      ]}
      calculate={(v) => {
        const costPerKilo = (v.fcr * v.feedPrice) / 1000;
        return [
          { label: "تكلفة العلف لكل كجم لحم (ج.م)", value: costPerKilo.toFixed(2) },
        ];
      }}
    />
  );
}
