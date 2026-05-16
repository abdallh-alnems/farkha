"use client";

import { useEffect, useState, Suspense, useCallback } from "react";
import { useRouter, useSearchParams, useParams } from "next/navigation";
import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { getPricesByType } from "@/lib/api/prices";
import { getFirebaseToken } from "@/lib/firebase/auth";
import { Skeleton } from "@/components/ui/skeleton";

interface PriceItem {
  id: string | number;
  type_name: string;
  type_id: string | number;
  today_higher_price: string;
  today_lower_price: string;
  yesterday_higher_price: string;
  yesterday_lower_price: string;
  higher?: string;
  lower?: string;
}

function formatPrice(val: string | number | undefined): string {
  if (!val) return "-";
  const n = parseFloat(String(val));
  if (isNaN(n)) return String(val);
  return n % 1 === 0 ? n.toFixed(0) : n.toFixed(2);
}

function calcChange(
  todayHigher: string,
  todayLower: string,
  yesterdayHigher: string,
  yesterdayLower: string,
  isFeed: boolean,
): number {
  if (isFeed) {
    const today = parseFloat(todayHigher) || 0;
    const yesterday = parseFloat(yesterdayHigher) || 0;
    return today - yesterday;
  }
  const todayAvg = ((parseFloat(todayHigher) || 0) + (parseFloat(todayLower) || 0)) / 2;
  const yesterdayAvg = ((parseFloat(yesterdayHigher) || 0) + (parseFloat(yesterdayLower) || 0)) / 2;
  return todayAvg - yesterdayAvg;
}

function ChangeCell({ change }: { change: number }) {
  if (change === 0 || isNaN(change)) {
    return <span className="text-foreground/40">-</span>;
  }
  const isUp = change > 0;
  const formatted = Math.abs(change) % 1 === 0
    ? Math.abs(change).toFixed(0)
    : Math.abs(change).toFixed(2);
  return (
    <span className={`font-bold text-label-lg ${isUp ? "text-success" : "text-destructive"}`}>
      {isUp ? "+" : "-"}{formatted}
    </span>
  );
}

function PricesByTypeContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const params = useParams();
  const typeParam = params.type as string;
  const mainName = searchParams.get("name") ?? "الأسعار";
  const [prices, setPrices] = useState<PriceItem[]>([]);
  const [loading, setLoading] = useState(true);

  const loadPrices = useCallback(async () => {
    if (!typeParam) return;
    try {
      const token = await getFirebaseToken();
      const res = await getPricesByType(typeParam, token ?? undefined);
      if (res.data) {
        setPrices(res.data as PriceItem[]);
      }
    } catch {
    } finally {
      setLoading(false);
    }
  }, [typeParam]);

  useEffect(() => {
    loadPrices();
  }, [loadPrices]);

  const isFeed = mainName.includes("علف") || mainName.includes("عليقة");

  return (
    <div className="px-4 py-4">
      <div className="mb-4 flex items-center gap-3">
        <button
          onClick={() => router.push("/")}
          className="flex h-9 w-9 items-center justify-center rounded-lg text-foreground/60 hover:bg-foreground/[0.04]"
        >
          <ArrowRight className="h-5 w-5" />
        </button>
        <h1 className="text-headline-sm text-primary">{mainName}</h1>
      </div>

      {loading ? (
        <div className="space-y-2">
          {[1, 2, 3, 4, 5].map((i) => (
            <Skeleton key={i} className="h-14 w-full rounded-xl" />
          ))}
        </div>
      ) : prices.length === 0 ? (
        <div className="flex flex-col items-center py-20 text-center">
          <p className="text-body-lg text-foreground/50">لا توجد أسعار</p>
        </div>
      ) : (
        <>
          <div className="mb-2 flex items-center rounded-t-xl bg-primary px-3 py-2.5">
            <span className="flex-[2] text-label-md font-semibold text-primary-foreground">
              النوع
            </span>
            {!isFeed && (
              <>
                <span className="flex-1 text-center text-label-md font-semibold text-primary-foreground">
                  أقل
                </span>
                <span className="flex-1 text-center text-label-md font-semibold text-primary-foreground">
                  أعلى
                </span>
              </>
            )}
            {isFeed && (
              <span className="flex-1 text-center text-label-md font-semibold text-primary-foreground">
                السعر
              </span>
            )}
            <span className="flex-1 text-center text-label-md font-semibold text-primary-foreground">
              التغير
            </span>
          </div>

          <div className="space-y-1">
            {prices.map((item) => {
              const higher = item.today_higher_price || (item as unknown as Record<string, unknown>).higher as string || "0";
              const lower = item.today_lower_price || (item as unknown as Record<string, unknown>).lower as string || "0";
              const yHigher = item.yesterday_higher_price || "0";
              const yLower = item.yesterday_lower_price || "0";
              const change = calcChange(higher, lower, yHigher, yLower, isFeed);
              const isUp = change > 0;
              const isDown = change < 0;
              const barColor = isUp
                ? "bg-success"
                : isDown
                  ? "bg-destructive"
                  : "bg-border";

              return (
                <div
                  key={item.id || item.type_id}
                  className="flex items-center rounded-xl border border-border/30 bg-card px-1 py-0"
                >
                  <div className={`ms-2 h-7 w-1.5 shrink-0 rounded-full ${barColor}`} />
                  <div className="flex flex-1 items-center px-2 py-3">
                    <span className="flex-[2] text-body-md font-medium text-foreground">
                      {item.type_name}
                    </span>
                    {!isFeed && (
                      <>
                        <span className="flex-1 text-center text-body-md text-foreground/70">
                          {formatPrice(lower)}
                        </span>
                        <span className="flex-1 text-center text-body-md font-semibold text-foreground">
                          {formatPrice(higher)}
                        </span>
                      </>
                    )}
                    {isFeed && (
                      <span className="flex-1 text-center text-body-md font-semibold text-foreground">
                        {formatPrice(higher)}
                      </span>
                    )}
                    <span className="flex-1 text-center">
                      <ChangeCell change={change} />
                    </span>
                  </div>
                </div>
              );
            })}
          </div>
        </>
      )}
    </div>
  );
}

export default function PricesByTypePage() {
  return (
    <Suspense
      fallback={
        <div className="flex min-h-svh items-center justify-center">
          جاري التحميل...
        </div>
      }
    >
      <PricesByTypeContent />
    </Suspense>
  );
}
