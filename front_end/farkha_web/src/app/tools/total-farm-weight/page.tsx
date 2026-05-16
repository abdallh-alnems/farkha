"use client";

import { CalcTool } from "@/components/tools/calc-tool";

export default function TotalFarmWeightPage() {
  return (
    <CalcTool
      title="الوزن الإجمالي"
      fields={[
        { key: "birds", label: "عدد الطيور", placeholder: "مثال: 10000" },
        { key: "avgWeight", label: "متوسط وزن الطائر (كجم)", placeholder: "مثال: 2" },
      ]}
      calculate={(v) => {
        const totalWeight = v.birds * v.avgWeight;
        return [
          { label: "الوزن الإجمالي (كجم)", value: totalWeight.toFixed(0) },
          { label: "الوزن الإجمالي (طن)", value: (totalWeight / 1000).toFixed(2) },
        ];
      }}
    />
  );
}
