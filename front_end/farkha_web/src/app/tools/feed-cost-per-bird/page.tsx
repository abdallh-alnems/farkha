"use client";

import { CalcTool } from "@/components/tools/calc-tool";

export default function FeedCostPerBirdPage() {
  return (
    <CalcTool
      title="تكلفة العلف لكل طائر"
      fields={[
        { key: "feedPrice", label: "سعر طن العلف (ج.م)", placeholder: "مثال: 18000" },
        { key: "fcr", label: "معامل التحويل الغذائي", placeholder: "مثال: 1.6" },
        { key: "weight", label: "وزن الطائر عند البيع (كجم)", placeholder: "مثال: 2" },
      ]}
      calculate={(v) => {
        const feedKgPerBird = v.fcr * v.weight;
        const costPerBird = (feedKgPerBird * v.feedPrice) / 1000;
        return [
          { label: "كمية العلف لكل طائر (كجم)", value: feedKgPerBird.toFixed(2) },
          { label: "تكلفة العلف لكل طائر (ج.م)", value: costPerBird.toFixed(2) },
        ];
      }}
    />
  );
}
