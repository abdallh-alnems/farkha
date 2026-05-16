"use client";

import { useEffect, useState, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { ArrowRight } from "lucide-react";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import { getArticleDetail } from "@/lib/api/prices";
import { Skeleton } from "@/components/ui/skeleton";

function ArticleDetailContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const articleId = searchParams.get("id") ?? "";
  const articleTitle = searchParams.get("title") ?? "مقال";
  const [content, setContent] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!articleId) return;
    loadArticle();
  }, [articleId]);

  const loadArticle = async () => {
    try {
      const res = await getArticleDetail(articleId);
      if (res.data) {
        setContent((res.data as unknown as Record<string, unknown>).content as string ?? "");
      }
    } catch {
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-svh bg-background">
      <header className="sticky top-0 z-10 flex h-14 items-center justify-center border-b border-border/50 bg-background/95 px-4 backdrop-blur-sm">
        <button
          onClick={() => router.back()}
          className="absolute start-4 flex h-9 w-9 items-center justify-center rounded-lg text-foreground/60 hover:bg-foreground/[0.04]"
        >
          <ArrowRight className="h-5 w-5" />
        </button>
        <h1 className="text-headline-md text-primary line-clamp-1 max-w-[60%]">
          {articleTitle}
        </h1>
      </header>

      <div className="px-4 py-4">
        {loading ? (
          <div className="space-y-3">
            <Skeleton className="h-8 w-3/4" />
            <Skeleton className="h-4 w-full" />
            <Skeleton className="h-4 w-full" />
            <Skeleton className="h-4 w-2/3" />
          </div>
        ) : (
          <article
            className="prose prose-sm max-w-none
              prose-headings:text-foreground prose-headings:font-bold
              prose-h1:text-headline-md prose-h1:text-center
              prose-h2:text-title-lg prose-h2:text-center
              prose-h3:text-title-md prose-h3:text-terracotta
              prose-p:text-body-md prose-p:text-foreground/88 prose-p:leading-[1.85]
              prose-strong:text-foreground prose-strong:font-bold
              prose-em:text-foreground/70
              prose-blockquote:text-foreground/60 prose-blockquote:bg-primary/6 prose-blockquote:rounded-lg prose-blockquote:p-3
              prose-li:text-foreground/85
              prose-hr:border-border/20
              prose-table:border prose-table:border-border/40
              prose-th:bg-primary/5 prose-th:px-3 prose-th:py-2 prose-th:text-label-md prose-th:text-primary
              prose-td:border-t prose-td:border-border/30 prose-td:px-3 prose-td:py-2
              prose-img:rounded-xl"
            dir="rtl"
          >
            <ReactMarkdown remarkPlugins={[remarkGfm]}>
              {content}
            </ReactMarkdown>
          </article>
        )}
      </div>
    </div>
  );
}

export default function ArticleDetailPage() {
  return (
    <Suspense
      fallback={
        <div className="flex min-h-svh items-center justify-center">
          جاري التحميل...
        </div>
      }
    >
      <ArticleDetailContent />
    </Suspense>
  );
}
