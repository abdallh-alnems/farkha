"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { ArrowRight } from "lucide-react";
import { getArticlesList } from "@/lib/api/prices";
import { Skeleton } from "@/components/ui/skeleton";

interface Article {
  id: string | number;
  title: string;
}

export default function ArticlesPage() {
  const router = useRouter();
  const [articles, setArticles] = useState<Article[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadArticles();
  }, []);

  const loadArticles = async () => {
    try {
      const res = await getArticlesList();
      if (res.data) {
        setArticles(res.data as Article[]);
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
        <h1 className="text-headline-md text-primary">مقالات</h1>
      </header>

      <div className="px-4 py-4">
        {loading ? (
          <div className="grid grid-cols-2 gap-3">
            {[1, 2, 3, 4, 5, 6].map((i) => (
              <Skeleton key={i} className="h-36 rounded-2xl" />
            ))}
          </div>
        ) : articles.length === 0 ? (
          <div className="flex flex-col items-center py-20">
            <p className="text-body-lg text-foreground/50">لا توجد مقالات</p>
          </div>
        ) : (
          <div className="grid grid-cols-2 gap-3 md:grid-cols-3 lg:grid-cols-4">
            {articles.map((article) => (
              <button
                key={article.id}
                onClick={() =>
                  router.push(
                    `/articles/${article.id}?title=${encodeURIComponent(article.title)}`,
                  )
                }
                className="flex min-h-[120px] items-center justify-center rounded-2xl border border-border/40 bg-card p-4 text-center shadow-elev-sm transition-colors hover:bg-surface"
              >
                <span className="text-title-md text-foreground leading-relaxed">
                  {article.title}
                </span>
              </button>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
