"use client";

import { CalcTool } from "@/components/tools/calc-tool";

export default function ROIPage() {
  return (
    <CalcTool
      title="العائد على الاستثمار"
      fields={[
        { key: "totalRevenue", label: "إجمالي الإيرادات (ج.م)", placeholder: "مثال: 100000" },
        { key: "totalCost", label: "إجمالي التكاليف (ج.م)", placeholder: "مثال: 80000" },
      ]}
      calculate={(v) => {
        const profit = v.totalRevenue - v.totalCost;
        const roi = (profit / v.totalCost) * 100;
        return [
          { label: "صافي الربح (ج.م)", value: profit.toFixed(2) },
          { label: "العائد على الاستثمار (%)", value: `${roi.toFixed(1)}%` },
        ];
      }}
    />
  );
}
