"use client";

import { ToolPageScaffold } from "@/components/tools/tool-page-scaffold";

const vaccines = [
  { day: "1", vaccine: "مرة نيوكاسل + برونشيت (Hitchner)", method: "رش / ماء" },
  { day: "5-7", vaccine: "جمبورو (سلالة متوسطة)", method: "ماء" },
  { day: "10-12", vaccine: "نيوكاسل (لاسوتا)", method: "ماء / رش" },
  { day: "14-16", vaccine: "جمبورو (الجرعة الثانية)", method: "ماء" },
  { day: "18", vaccine: "برونشيت (H120)", method: "رش" },
  { day: "21", vaccine: "نيوكاسل (الجرعة الثالثة)", method: "ماء / رش" },
  { day: "25-28", vaccine: "إنفلونزا الطيور (H5)", method: "حقن" },
  { day: "35", vaccine: "نيوكاسل + برونشيت", method: "رش" },
];

export default function VaccinationSchedulePage() {
  return (
    <ToolPageScaffold title="جدول التحصينات">
      <div className="overflow-x-auto rounded-2xl border border-border/40 bg-card shadow-elev-card">
        <table className="w-full">
          <thead>
            <tr className="border-b border-border/50 bg-primary/5">
              <th className="px-4 py-3 text-start text-label-md text-primary">العمر (يوم)</th>
              <th className="px-4 py-3 text-start text-label-md text-primary">التحصين</th>
              <th className="px-4 py-3 text-start text-label-md text-primary">طريقة التطعيم</th>
            </tr>
          </thead>
          <tbody>
            {vaccines.map((row, i) => (
              <tr key={i} className="border-b border-border/30 last:border-0">
                <td className="px-4 py-3 text-body-md font-semibold text-primary">{row.day}</td>
                <td className="px-4 py-3 text-body-md text-foreground">{row.vaccine}</td>
                <td className="px-4 py-3 text-body-sm text-foreground/60">{row.method}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </ToolPageScaffold>
  );
}
