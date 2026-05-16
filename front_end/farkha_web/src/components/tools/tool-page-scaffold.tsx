"use client";

import { useRouter } from "next/navigation";
import { ArrowRight } from "lucide-react";

interface ToolPageScaffoldProps {
  title: string;
  children: React.ReactNode;
}

export function ToolPageScaffold({ title, children }: ToolPageScaffoldProps) {
  const router = useRouter();

  return (
    <div className="px-4 py-4">
      <div className="mx-auto max-w-lg">
        <div className="mb-4 flex items-center gap-3">
          <button
            onClick={() => router.back()}
            className="flex h-9 w-9 items-center justify-center rounded-lg text-foreground/60 hover:bg-foreground/[0.04]"
          >
            <ArrowRight className="h-5 w-5" />
          </button>
          <h1 className="text-headline-sm text-primary">{title}</h1>
        </div>
        {children}
      </div>
    </div>
  );
}
