"use client";

import { useState, useEffect, useCallback } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useAuthStore } from "@/lib/stores/auth-store";
import { getAuthToken } from "@/lib/hooks/use-auth-token";
import { getCycles, getHistory, isOk } from "@/lib/api/cycles";
import type { CycleSummary, CycleHistoryPage } from "@/lib/types/cycle";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { Plus, Search, Clock, TrendingUp, TrendingDown } from "lucide-react";
import { toast } from "sonner";

function ageOf(isoDate: string): number {
  const start = new Date(isoDate);
  const now = new Date();
  return Math.floor((now.getTime() - start.getTime()) / 86400000) + 1;
}

function formatNum(n: string | number): string {
  const num = typeof n === "string" ? parseFloat(n) : n;
  if (isNaN(num)) return "0";
  return num.toLocaleString("ar-EG", { maximumFractionDigits: 1 });
}

function CycleCard({ cycle }: { cycle: CycleSummary }) {
  const days = ageOf(cycle.start_date_raw);
  const mortalityNum = parseFloat(cycle.mortality) || 0;
  const chickNum = parseInt(cycle.chick_count) || 0;
  const mortalityRate =
    chickNum > 0 ? ((mortalityNum / chickNum) * 100).toFixed(1) : "0";
  const expenses = parseFloat(cycle.total_expenses) || 0;
  const liveCount = chickNum - mortalityNum;

  return (
    <Link href={`/cycles/${cycle.id}`}>
      <div className="card-elevated flex flex-col gap-3 transition-colors hover:border-primary/30">
        <div className="flex items-start justify-between">
          <div>
            <h3 className="text-title-lg text-foreground">{cycle.name}</h3>
            <p className="text-label-md text-foreground/50">
              يوم {days} &middot; {cycle.chick_count} طائر
            </p>
          </div>
          <Badge variant="secondary" className="text-label-sm">
            يوم {days}
          </Badge>
        </div>

        <div className="grid grid-cols-3 gap-2">
          <div className="rounded-xl bg-muted/50 p-2 text-center">
            <p className="text-label-sm text-foreground/50">النفوق</p>
            <p className="text-title-sm font-bold text-terracotta">
              {mortalityRate}%
            </p>
          </div>
          <div className="rounded-xl bg-muted/50 p-2 text-center">
            <p className="text-label-sm text-foreground/50">المصروفات</p>
            <p className="text-title-sm font-bold text-foreground">
              {formatNum(expenses)}
            </p>
          </div>
          <div className="rounded-xl bg-muted/50 p-2 text-center">
            <p className="text-label-sm text-foreground/50">تكلفة الفرخ</p>
            <p className="text-title-sm font-bold text-foreground">
              {liveCount > 0 && expenses > 0
                ? formatNum(expenses / liveCount)
                : "0"}{" "}
              ج
            </p>
          </div>
        </div>
      </div>
    </Link>
  );
}

function HistoryCard({ cycle }: { cycle: CycleSummary }) {
  const chickNum = parseInt(cycle.chick_count) || 0;
  const mortalityNum = parseFloat(cycle.mortality) || 0;
  const expenses = parseFloat(cycle.total_expenses) || 0;
  const sales = parseFloat(cycle.total_sales) || 0;
  const profit = sales - expenses;
  const avgWeight = parseFloat(cycle.average_weight || "0") || 0;
  const totalFeed = parseFloat(cycle.total_feed || "0") || 0;
  const liveCount = chickNum - mortalityNum;
  const fcr =
    liveCount > 0 && avgWeight > 0 && totalFeed > 0
      ? (totalFeed / (liveCount * avgWeight)).toFixed(2)
      : "-";

  return (
    <Link href={`/cycles/${cycle.id}`}>
      <div className="card-elevated flex flex-col gap-2 transition-colors hover:border-primary/30">
        <div className="flex items-start justify-between">
          <h3 className="text-title-lg text-foreground">{cycle.name}</h3>
          <Badge variant="outline" className="text-label-sm">
            منتهية
          </Badge>
        </div>
        <p className="text-label-md text-foreground/50">
          {cycle.chick_count} طائر &middot; {cycle.space} م²
          {avgWeight > 0 && ` · وزن ${avgWeight.toFixed(2)} كجم`}
        </p>
        <div className="grid grid-cols-4 gap-2">
          <div className="rounded-xl bg-muted/50 p-1.5 text-center">
            <p className="text-[10px] text-foreground/50">معامل</p>
            <p className="text-label-md font-bold">{fcr}</p>
          </div>
          <div className="rounded-xl bg-muted/50 p-1.5 text-center">
            <p className="text-[10px] text-foreground/50">النفوق</p>
            <p className="text-label-md font-bold text-terracotta">
              {chickNum > 0 ? ((mortalityNum / chickNum) * 100).toFixed(1) : 0}%
            </p>
          </div>
          <div className="rounded-xl bg-muted/50 p-1.5 text-center">
            <p className="text-[10px] text-foreground/50">المبيعات</p>
            <p className="text-label-md font-bold">{formatNum(sales)}</p>
          </div>
          <div className="rounded-xl bg-muted/50 p-1.5 text-center">
            <p className="text-[10px] text-foreground/50">الربح</p>
            <p
              className={`text-label-md font-bold ${profit >= 0 ? "text-success" : "text-destructive"}`}
            >
              {formatNum(profit)}
            </p>
          </div>
        </div>
      </div>
    </Link>
  );
}

export default function CyclesPage() {
  const router = useRouter();
  const { user, isLoggedIn } = useAuthStore();
  const [activeTab, setActiveTab] = useState<"active" | "history">("active");
  const [cycles, setCycles] = useState<CycleSummary[]>([]);
  const [historyData, setHistoryData] = useState<CycleHistoryPage | null>(null);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [historyPage, setHistoryPage] = useState(1);

  const fetchCycles = useCallback(async () => {
    const token = await getAuthToken();
    if (!token) return;
    setLoading(true);
    const res = await getCycles(token);
    if (isOk(res) && res.data) {
      setCycles(res.data.cycles ?? []);
    }
    setLoading(false);
  }, []);

  const fetchHistory = useCallback(
    async (page: number) => {
      const token = await getAuthToken();
      if (!token) return;
      setLoading(true);
      const res = await getHistory(token, page, 10, searchQuery || undefined);
      if (isOk(res) && res.data) {
        setHistoryData(res.data);
      }
      setLoading(false);
    },
    [searchQuery],
  );

  useEffect(() => {
    if (!isLoggedIn) return;
    if (activeTab === "active") {
      fetchCycles();
    } else {
      fetchHistory(historyPage);
    }
  }, [activeTab, isLoggedIn, fetchCycles, fetchHistory, historyPage]);

  if (!isLoggedIn) {
    return (
      <div className="flex flex-col items-center justify-center gap-4 py-20">
        <p className="text-headline-sm text-primary">الدورات</p>
        <p className="text-body-md text-foreground/50">
          سجل دخولك للوصول إلى دوراتك
        </p>
        <Button onClick={() => router.push("/login")}>تسجيل الدخول</Button>
      </div>
    );
  }

  return (
    <div className="px-4 py-4">
      <div className="mb-4 flex items-center justify-between">
        <h1 className="text-headline-md text-primary">الدورات</h1>
        <Link href="/cycles/new">
          <Button size="sm" className="gap-1.5 rounded-xl">
            <Plus className="h-4 w-4" />
            دورة جديدة
          </Button>
        </Link>
      </div>

      <div className="mb-4 flex gap-1 rounded-xl bg-muted p-1">
        <button
          onClick={() => setActiveTab("active")}
          className={`flex-1 rounded-lg py-2 text-label-md transition-colors ${
            activeTab === "active"
              ? "bg-card text-primary shadow-elev-sm"
              : "text-foreground/50 hover:text-foreground/70"
          }`}
        >
          النشطة
        </button>
        <button
          onClick={() => setActiveTab("history")}
          className={`flex-1 rounded-lg py-2 text-label-md transition-colors ${
            activeTab === "history"
              ? "bg-card text-primary shadow-elev-sm"
              : "text-foreground/50 hover:text-foreground/70"
          }`}
        >
          السابقة
        </button>
      </div>

      {activeTab === "history" && (
        <div className="relative mb-3">
          <Search className="absolute start-3 top-1/2 h-4 w-4 -translate-y-1/2 text-foreground/40" />
          <Input
            placeholder="بحث في الدورات..."
            value={searchQuery}
            onChange={(e) => {
              setSearchQuery(e.target.value);
              setHistoryPage(1);
            }}
            className="h-10 rounded-xl ps-9"
          />
        </div>
      )}

      {loading ? (
        <div className="space-y-3">
          {[1, 2, 3].map((i) => (
            <Skeleton key={i} className="h-36 w-full rounded-2xl" />
          ))}
        </div>
      ) : activeTab === "active" ? (
        cycles.length > 0 ? (
          <div className="space-y-3">
            {cycles.map((c) => (
              <CycleCard key={c.id} cycle={c} />
            ))}
          </div>
        ) : (
          <div className="flex flex-col items-center gap-3 py-16 text-center">
            <TrendingUp className="h-12 w-12 text-foreground/20" />
            <p className="text-body-lg text-foreground/50">
              لا توجد دورات نشطة
            </p>
            <Link href="/cycles/new">
              <Button variant="outline" className="gap-1.5">
                <Plus className="h-4 w-4" />
                ابدأ دورة جديدة
              </Button>
            </Link>
          </div>
        )
      ) : historyData && historyData.cycles.length > 0 ? (
        <>
          <div className="space-y-3">
            {historyData.cycles.map((c) => (
              <HistoryCard key={c.id} cycle={c} />
            ))}
          </div>
          {historyData.pages > 1 && (
            <div className="mt-4 flex items-center justify-center gap-2">
              <Button
                variant="outline"
                size="sm"
                disabled={historyPage <= 1}
                onClick={() => setHistoryPage((p) => p - 1)}
              >
                السابق
              </Button>
              <span className="text-label-md text-foreground/50">
                {historyPage} / {historyData.pages}
              </span>
              <Button
                variant="outline"
                size="sm"
                disabled={historyPage >= historyData.pages}
                onClick={() => setHistoryPage((p) => p + 1)}
              >
                التالي
              </Button>
            </div>
          )}
        </>
      ) : (
        <div className="flex flex-col items-center gap-3 py-16 text-center">
          <Clock className="h-12 w-12 text-foreground/20" />
          <p className="text-body-lg text-foreground/50">
            لا توجد دورات سابقة
          </p>
        </div>
      )}
    </div>
  );
}
