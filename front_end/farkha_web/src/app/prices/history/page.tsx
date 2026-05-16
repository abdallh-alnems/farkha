"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { ArrowRight, TrendingUp, TrendingDown, Minus } from "lucide-react";
import { getPriceHistory } from "@/lib/api/prices";
import { getFirebaseToken } from "@/lib/firebase/auth";
import { Skeleton } from "@/components/ui/skeleton";
import {
  ResponsiveContainer,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  Tooltip,
} from "recharts";

export default function PriceHistoryPage() {
  const router = useRouter();
  const params = new URLSearchParams(
    typeof window !== "undefined" ? window.location.search : "",
  );
  const typeId = params.get("type_id") ?? "";
  const typeName = params.get("type_name") ?? "سجل الأسعار";

  const [history, setHistory] = useState<Record<string, unknown>[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!typeId) return;
    loadHistory();
  }, [typeId]);

  const loadHistory = async () => {
    try {
      const token = await getFirebaseToken();
      const res = await getPriceHistory(typeId, token ?? undefined);
      if (res.data) {
        setHistory(res.data as unknown as Record<string, unknown>[]);
      }
    } catch {
    } finally {
      setLoading(false);
    }
  };

  const chartData = history
    .slice()
    .reverse()
    .map((item) => ({
      date: String(item.date ?? "").split(" ").at(0) ?? "",
      higher: parseFloat(String(item.higher ?? "0")) || 0,
      lower: parseFloat(String(item.lower ?? "0")) || 0,
    }));

  return (
    <div className="min-h-svh bg-background">
      <header className="sticky top-0 z-10 flex h-14 items-center justify-center border-b border-border/50 bg-background/95 px-4 backdrop-blur-sm">
        <button
          onClick={() => router.back()}
          className="absolute start-4 flex h-9 w-9 items-center justify-center rounded-lg text-foreground/60 hover:bg-foreground/[0.04]"
        >
          <ArrowRight className="h-5 w-5" />
        </button>
        <h1 className="text-headline-md text-primary">
          سجل أسعار {typeName}
        </h1>
      </header>

      <div className="px-4 py-4">
        {loading ? (
          <Skeleton className="h-64 w-full rounded-2xl" />
        ) : history.length === 0 ? (
          <div className="flex flex-col items-center py-20">
            <p className="text-body-lg text-foreground/50">لا توجد سجلات</p>
          </div>
        ) : (
          <>
            {chartData.length > 1 && (
              <div className="mb-4 h-60 rounded-2xl border border-border/40 bg-card p-4 shadow-elev-card">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={chartData}>
                    <defs>
                      <linearGradient id="higherGrad" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#4E7A3E" stopOpacity={0.3} />
                        <stop offset="95%" stopColor="#4E7A3E" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <XAxis
                      dataKey="date"
                      tick={{ fontSize: 11 }}
                      tickLine={false}
                    />
                    <YAxis
                      tick={{ fontSize: 11 }}
                      tickLine={false}
                      width={45}
                    />
                    <Tooltip />
                    <Area
                      type="monotone"
                      dataKey="higher"
                      stroke="#4E7A3E"
                      fill="url(#higherGrad)"
                      strokeWidth={2}
                      name="الأعلى"
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            )}

            <div className="space-y-2">
              {history.map((item, i) => {
                const higher = parseFloat(String(item.higher ?? "0")) || 0;
                const prevHigher =
                  i + 1 < history.length
                    ? parseFloat(String(history[i + 1].higher ?? "0")) || 0
                    : 0;
                const diff = prevHigher > 0 ? higher - prevHigher : null;

                return (
                  <div
                    key={i}
                    className="flex items-center justify-between rounded-2xl border border-border/40 bg-card px-4 py-3 shadow-elev-sm"
                  >
                    <div className="flex items-center gap-3">
                      {diff !== null ? (
                        diff > 0 ? (
                          <TrendingUp className="h-4 w-4 text-success" />
                        ) : diff < 0 ? (
                          <TrendingDown className="h-4 w-4 text-destructive" />
                        ) : (
                          <Minus className="h-4 w-4 text-foreground/30" />
                        )
                      ) : (
                        <Minus className="h-4 w-4 text-foreground/30" />
                      )}
                      <span className="text-body-md text-foreground">
                        {String(item.date ?? "").split(" ").at(0)}
                      </span>
                    </div>
                    <div className="flex items-center gap-4 text-body-md">
                      <span className="text-foreground/70">
                        أعلى: <strong>{String(item.higher ?? "-")}</strong>
                      </span>
                      <span className="text-foreground/70">
                        أدنى: <strong>{String(item.lower ?? "-")}</strong>
                      </span>
                      {diff !== null && diff !== 0 && (
                        <span
                          className={`text-label-sm font-semibold ${diff > 0 ? "text-success" : "text-destructive"}`}
                        >
                          {diff > 0 ? "+" : ""}
                          {diff.toFixed(2)}
                        </span>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          </>
        )}
      </div>
    </div>
  );
}
