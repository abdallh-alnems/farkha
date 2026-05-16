"use client";

import { CalcTool } from "@/components/tools/calc-tool";

export default function BirdNetProfitPage() {
  return (
    <CalcTool
      title="الربح الصافي للطائر"
      fields={[
        { key: "sellingPrice", label: "سعر البيع لكل كجم (ج.م)", placeholder: "مثال: 38" },
        { key: "weight", label: "متوسط وزن الطائر (كجم)", placeholder: "مثال: 2" },
        { key: "totalCost", label: "إجمالي تكلفة الطائر (ج.م)", placeholder: "مثال: 40" },
      ]}
      calculate={(v) => {
        const revenue = v.sellingPrice * v.weight;
        const profit = revenue - v.totalCost;
        const profitPercent = (profit / v.totalCost) * 100;
        return [
          { label: "إيراد الطائر (ج.م)", value: revenue.toFixed(2) },
          { label: "الربح الصافي للطائر (ج.م)", value: profit.toFixed(2) },
          { label: "نسبة الربح (%)", value: `${profitPercent.toFixed(1)}%` },
        ];
      }}
    />
  );
}
