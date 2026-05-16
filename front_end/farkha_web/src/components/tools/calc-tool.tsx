"use client";

import { useState } from "react";
import { ToolPageScaffold } from "@/components/tools/tool-page-scaffold";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";

interface CalcToolProps {
  title: string;
  fields: { key: string; label: string; placeholder?: string }[];
  calculate: (values: Record<string, number>) => { label: string; value: string }[] | null;
}

export function CalcTool({ title, fields, calculate }: CalcToolProps) {
  const [values, setValues] = useState<Record<string, string>>({});
  const [results, setResults] = useState<{ label: string; value: string }[] | null>(null);

  const handleCalc = () => {
    const nums: Record<string, number> = {};
    for (const f of fields) {
      const v = parseFloat(values[f.key] ?? "");
      if (isNaN(v)) {
        setResults(null);
        return;
      }
      nums[f.key] = v;
    }
    setResults(calculate(nums));
  };

  return (
    <ToolPageScaffold title={title}>
      <div className="grid grid-cols-2 gap-3">
        {fields.map((f) => (
          <div key={f.key}>
            <label className="mb-1 block text-label-md text-foreground/70">
              {f.label}
            </label>
            <Input
              type="number"
              placeholder={f.placeholder ?? f.label}
              value={values[f.key] ?? ""}
              onChange={(e) =>
                setValues((prev) => ({ ...prev, [f.key]: e.target.value }))
              }
              className="h-11 rounded-xl"
              dir="ltr"
            />
          </div>
        ))}

        <Button
          onClick={handleCalc}
          className="col-span-full mt-1 h-12 w-full rounded-2xl text-label-lg"
          size="lg"
        >
          احسب
        </Button>

        {results && (
          <Card className="mt-4 space-y-2 rounded-2xl border border-primary/20 bg-primary/5 p-4">
            {results.map((r, i) => (
              <div key={i} className="flex items-center justify-between">
                <span className="text-body-md text-foreground/70">{r.label}</span>
                <span className="text-title-md font-bold text-primary">{r.value}</span>
              </div>
            ))}
          </Card>
        )}
      </div>
    </ToolPageScaffold>
  );
}
