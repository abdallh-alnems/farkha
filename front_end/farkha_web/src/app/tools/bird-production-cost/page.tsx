"use client";

import { CalcTool } from "@/components/tools/calc-tool";

export default function BirdProductionCostPage() {
  return (
    <CalcTool
      title="تكلفة إنتاج الفرخ"
      fields={[
        { key: "chickCost", label: "سعر الكتاكيت (ج.م)", placeholder: "مثال: 8" },
        { key: "feedCost", label: "تكلفة العلف الكلية (ج.م)", placeholder: "مثال: 25" },
        { key: "medicine", label: "تكلفة الأدوية والتحصينات (ج.م)", placeholder: "مثال: 2" },
        { key: "other", label: "مصروفات أخرى (ج.م)", placeholder: "مثال: 1" },
        { key: "mortality", label: "نسبة النفوق (%)", placeholder: "مثال: 5" },
      ]}
      calculate={(v) => {
        const totalCost = v.chickCost + v.feedCost + v.medicine + v.other;
        const mortalityFactor = 1 + v.mortality / 100;
        const costPerBird = totalCost * mortalityFactor;
        return [
          { label: "التكلفة الأساسية للطائر", value: `${totalCost.toFixed(2)} ج.م` },
          { label: "التكلفة الفعلية (مع النفوق)", value: `${costPerBird.toFixed(2)} ج.م` },
        ];
      }}
    />
  );
}
