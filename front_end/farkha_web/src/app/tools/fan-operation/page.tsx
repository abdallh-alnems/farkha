"use client";

import { ToolPageScaffold } from "@/components/tools/tool-page-scaffold";

const fanTable = [
  { age: "1-7", fans: "حسب الحرارة", note: "الاعتماد على التهوية الدنيا" },
  { age: "8-14", fans: "1-2 شفاط", note: "تشغيل تدريجي" },
  { age: "15-21", fans: "2-4 شفاط", note: "زيادة مع نمو الطيور" },
  { age: "22-28", fans: "4-6 شفاط", note: "مراقبة الأمونيا" },
  { age: "29-35", fans: "6+ شفاط", note: "تهوية قصوى" },
];

export default function FanOperationPage() {
  return (
    <ToolPageScaffold title="تشغيل الشفاطات">
      <div className="overflow-x-auto rounded-2xl border border-border/40 bg-card shadow-elev-card">
        <table className="w-full">
          <thead>
            <tr className="border-b border-border/50 bg-primary/5">
              <th className="px-4 py-3 text-start text-label-md text-primary">العمر (يوم)</th>
              <th className="px-4 py-3 text-start text-label-md text-primary">عدد الشفاطات</th>
              <th className="px-4 py-3 text-start text-label-md text-primary">ملاحظات</th>
            </tr>
          </thead>
          <tbody>
            {fanTable.map((row, i) => (
              <tr key={i} className="border-b border-border/30 last:border-0">
                <td className="px-4 py-3 text-body-md text-foreground">{row.age}</td>
                <td className="px-4 py-3 text-body-md font-semibold text-primary">{row.fans}</td>
                <td className="px-4 py-3 text-body-sm text-foreground/60">{row.note}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </ToolPageScaffold>
  );
}
