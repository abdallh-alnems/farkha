"use client";

import { ToolPageScaffold } from "@/components/tools/tool-page-scaffold";
import Link from "next/link";

const diseases = [
  { name: "نيوكاسل", desc: "مرض فيروسي شديد العدوى", link: "/diseases/1" },
  { name: "إنفلونزا الطيور", desc: "فيروس H5N1 — خطير جداً", link: "/diseases/2" },
  { name: "جمبورو", desc: "يصيب الجهاز المناعي", link: "/diseases/3" },
  { name: "التهاب الشعب الهوائية", desc: "فيروسي — يؤثر على التنفس", link: "/diseases/4" },
  { name: "كوكسيديا", desc: "طفيلي معوي — شائع", link: "/diseases/5" },
  { name: "الميكوبلازما", desc: "بكتيري — التهاب تنفسي", link: "/diseases/6" },
  { name: "السالمونيلا", desc: "بكتيري — مشاكل معوية", link: "/diseases/7" },
  { name: "التسمم البكتيري", desc: "سموم في العلف أو الماء", link: "/diseases/8" },
];

export default function DiseasesPage() {
  return (
    <ToolPageScaffold title="الأمراض">
      <div className="space-y-2">
        {diseases.map((d, i) => (
          <Link
            key={i}
            href={`/articles/${i + 1}?title=${encodeURIComponent(d.name)}`}
            className="flex items-center justify-between rounded-2xl border border-border/40 bg-card p-4 shadow-elev-sm transition-colors hover:bg-surface"
          >
            <div>
              <p className="text-title-md text-foreground">{d.name}</p>
              <p className="text-body-sm text-foreground/50">{d.desc}</p>
            </div>
          </Link>
        ))}
      </div>
    </ToolPageScaffold>
  );
}
