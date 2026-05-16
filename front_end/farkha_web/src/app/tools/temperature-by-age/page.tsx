"use client";

import { ToolPageScaffold } from "@/components/tools/tool-page-scaffold";

const tempTable = [
  { age: "1", temp: "33-35°C" },
  { age: "3", temp: "32-34°C" },
  { age: "7", temp: "30-32°C" },
  { age: "14", temp: "27-29°C" },
  { age: "21", temp: "24-26°C" },
  { age: "28", temp: "22-24°C" },
  { age: "35+", temp: "20-22°C" },
];

export default function TemperatureByAgePage() {
  return (
    <ToolPageScaffold title="درجة الحرارة حسب العمر">
      <div className="overflow-x-auto rounded-2xl border border-border/40 bg-card shadow-elev-card">
        <table className="w-full">
          <thead>
            <tr className="border-b border-border/50 bg-primary/5">
              <th className="px-4 py-3 text-start text-label-md text-primary">العمر (يوم)</th>
              <th className="px-4 py-3 text-start text-label-md text-primary">درجة الحرارة</th>
            </tr>
          </thead>
          <tbody>
            {tempTable.map((row, i) => (
              <tr key={i} className="border-b border-border/30 last:border-0">
                <td className="px-4 py-3 text-body-md text-foreground">{row.age}</td>
                <td className="px-4 py-3 text-body-md font-semibold text-primary">{row.temp}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </ToolPageScaffold>
  );
}
