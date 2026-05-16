"use client";

import { ToolPageScaffold } from "@/components/tools/tool-page-scaffold";

const darknessTable = [
  { age: "1-3", hours: "0", note: "إضاءة 24 ساعة" },
  { age: "4-7", hours: "1", note: "زيادة تدريجية" },
  { age: "8-14", hours: "2-4", note: "زيادة تدريجية" },
  { age: "15-21", hours: "4-6", note: "مراقبة الطيور" },
  { age: "22-28", hours: "6-8", note: "ثبات" },
  { age: "29-35", hours: "8", note: "أقصى حد" },
];

export default function DarknessLevelsPage() {
  return (
    <ToolPageScaffold title="ساعات الإظلام">
      <div className="overflow-x-auto rounded-2xl border border-border/40 bg-card shadow-elev-card">
        <table className="w-full">
          <thead>
            <tr className="border-b border-border/50 bg-primary/5">
              <th className="px-4 py-3 text-start text-label-md text-primary">العمر (يوم)</th>
              <th className="px-4 py-3 text-start text-label-md text-primary">ساعات الإظلام</th>
              <th className="px-4 py-3 text-start text-label-md text-primary">ملاحظات</th>
            </tr>
          </thead>
          <tbody>
            {darknessTable.map((row, i) => (
              <tr key={i} className="border-b border-border/30 last:border-0">
                <td className="px-4 py-3 text-body-md text-foreground">{row.age}</td>
                <td className="px-4 py-3 text-body-md font-semibold text-primary">{row.hours}</td>
                <td className="px-4 py-3 text-body-sm text-foreground/60">{row.note}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </ToolPageScaffold>
  );
}
