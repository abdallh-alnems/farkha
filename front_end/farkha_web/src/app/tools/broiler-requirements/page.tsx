"use client";

import { ToolPageScaffold } from "@/components/tools/tool-page-scaffold";

const requirements = [
  { age: "1-7", temp: "33-35°C", feed: "ستارتر", water: "20-40 مل", space: "0.05 م²" },
  { age: "8-14", temp: "30-32°C", feed: "ستارتر/جروثر", water: "50-80 مل", space: "0.08 م²" },
  { age: "15-21", temp: "27-29°C", feed: "جروثر", water: "100-150 مل", space: "0.10 م²" },
  { age: "22-28", temp: "24-26°C", feed: "جروثر/فينيشر", water: "180-220 مل", space: "0.12 م²" },
  { age: "29-35", temp: "20-22°C", feed: "فينيشر", water: "240-300 مل", space: "0.15 م²" },
];

export default function BroilerRequirementsPage() {
  return (
    <ToolPageScaffold title="متطلبات فراخ التسمين">
      <div className="overflow-x-auto rounded-2xl border border-border/40 bg-card shadow-elev-card">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-border/50 bg-primary/5">
              <th className="px-3 py-3 text-start text-label-md text-primary">العمر</th>
              <th className="px-3 py-3 text-start text-label-md text-primary">الحرارة</th>
              <th className="px-3 py-3 text-start text-label-md text-primary">العلف</th>
              <th className="px-3 py-3 text-start text-label-md text-primary">الماء</th>
              <th className="px-3 py-3 text-start text-label-md text-primary">المساحة</th>
            </tr>
          </thead>
          <tbody>
            {requirements.map((row, i) => (
              <tr key={i} className="border-b border-border/30 last:border-0">
                <td className="px-3 py-3 text-body-sm font-semibold text-foreground">{row.age}</td>
                <td className="px-3 py-3 text-body-sm text-primary">{row.temp}</td>
                <td className="px-3 py-3 text-body-sm text-foreground">{row.feed}</td>
                <td className="px-3 py-3 text-body-sm text-foreground">{row.water}</td>
                <td className="px-3 py-3 text-body-sm text-foreground">{row.space}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </ToolPageScaffold>
  );
}
