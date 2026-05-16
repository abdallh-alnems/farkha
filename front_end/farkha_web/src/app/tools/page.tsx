"use client";

import Image from "next/image";
import Link from "next/link";
import { allToolsList } from "@/lib/constants/tools-list";

const iconBgColors = [
  "bg-olive/10",
  "bg-terracotta/10",
  "bg-wheat/10",
  "bg-info/10",
];

export default function ToolsPage() {
  return (
    <div className="px-4 py-4">
      <h1 className="mb-5 text-headline-md text-primary">الأدوات الحسابية</h1>
      <div className="grid grid-cols-3 gap-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6">
        {allToolsList.map((tool, i) => (
          <Link
            key={tool.toolId}
            href={tool.route}
            className="group flex flex-col items-center gap-2.5 rounded-2xl border border-border/30 bg-card p-3 shadow-elev-sm transition-all hover:border-primary/30 hover:shadow-elev-md active:scale-[0.97]"
          >
            <div
              className={`flex h-14 w-14 items-center justify-center rounded-2xl ${iconBgColors[i % iconBgColors.length]} transition-colors group-hover:${iconBgColors[i % iconBgColors.length].replace("/10", "/20")}`}
            >
              <Image
                src={tool.icon}
                alt={tool.text}
                width={28}
                height={28}
                className="h-7 w-7"
              />
            </div>
            <span className="text-center text-title-sm text-foreground/80 leading-snug line-clamp-2">
              {tool.text}
            </span>
          </Link>
        ))}
      </div>
    </div>
  );
}
