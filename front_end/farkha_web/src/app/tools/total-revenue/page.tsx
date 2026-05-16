"use client";

import { CalcTool } from "@/components/tools/calc-tool";

export default function TotalRevenuePage() {
  return (
    <CalcTool
      title="إجمالي الإيرادات"
      fields={[
        { key: "birds", label: "عدد الطيور المباعة", placeholder: "مثال: 9500" },
        { key: "weight", label: "متوسط وزن الطائر (كجم)", placeholder: "مثال: 2" },
        { key: "price", label: "سعر الكيلو (ج.م)", placeholder: "مثال: 38" },
      ]}
      calculate={(v) => {
        const revenue = v.birds * v.weight * v.price;
        return [
          { label: "إجمالي الإيرادات (ج.م)", value: revenue.toFixed(2) },
          { label: "إجمالي الوزن المباع (كجم)", value: (v.birds * v.weight).toFixed(0) },
        ];
      }}
    />
  );
}
