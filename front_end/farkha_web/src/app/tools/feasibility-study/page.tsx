"use client";

import { useState } from "react";
import { ToolPageScaffold } from "@/components/tools/tool-page-scaffold";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { getFirebaseToken } from "@/lib/firebase/auth";
import { apiPost } from "@/lib/api/client";

export default function FeasibilityStudyPage() {
  const [birds, setBirds] = useState("");
  const [chickCost, setChickCost] = useState("");
  const [feedPrice, setFeedPrice] = useState("");
  const [fcr, setFcr] = useState("");
  const [targetWeight, setTargetWeight] = useState("");
  const [sellingPrice, setSellingPrice] = useState("");
  const [result, setResult] = useState<Record<string, unknown> | null>(null);
  const [loading, setLoading] = useState(false);

  const calculate = async () => {
    setLoading(true);
    try {
      const token = await getFirebaseToken();
      const res = await apiPost<Record<string, unknown>>(
        "app/tools/feasibility_study.php",
        {
          token,
          birds: Number(birds),
          chick_cost: Number(chickCost),
          feed_price: Number(feedPrice),
          fcr: Number(fcr),
          target_weight: Number(targetWeight),
          selling_price: Number(sellingPrice),
        },
      );
      setResult(res);
    } catch {
    } finally {
      setLoading(false);
    }
  };

  return (
    <ToolPageScaffold title="دراسة جدوى">
      <div className="space-y-3">
        {[
          { val: birds, set: setBirds, label: "عدد الطيور", ph: "مثال: 10000" },
          { val: chickCost, set: setChickCost, label: "سعر الكتاكيت (ج.م)", ph: "مثال: 8" },
          { val: feedPrice, set: setFeedPrice, label: "سعر طن العلف (ج.م)", ph: "مثال: 18000" },
          { val: fcr, set: setFcr, label: "معامل التحويل الغذائي", ph: "مثال: 1.6" },
          { val: targetWeight, set: setTargetWeight, label: "الوزن المستهدف (كجم)", ph: "مثال: 2" },
          { val: sellingPrice, set: setSellingPrice, label: "سعر البيع (ج.م/كجم)", ph: "مثال: 38" },
        ].map((f) => (
          <div key={f.label}>
            <label className="mb-1 block text-label-md text-foreground/70">{f.label}</label>
            <Input
              type="number"
              placeholder={f.ph}
              value={f.val}
              onChange={(e) => f.set(e.target.value)}
              className="h-11 rounded-xl"
              dir="ltr"
            />
          </div>
        ))}

        <Button onClick={calculate} className="mt-4 h-12 w-full rounded-2xl text-label-lg" size="lg" disabled={loading}>
          {loading ? "جاري الحساب..." : "احسب دراسة الجدوى"}
        </Button>

        {result && (
          <Card className="mt-4 space-y-2 rounded-2xl border border-primary/20 bg-primary/5 p-4">
            {Object.entries(result).map(([key, val]) => (
              <div key={key} className="flex items-center justify-between">
                <span className="text-body-md text-foreground/70">{key}</span>
                <span className="text-title-md font-bold text-primary">{String(val)}</span>
              </div>
            ))}
          </Card>
        )}
      </div>
    </ToolPageScaffold>
  );
}
