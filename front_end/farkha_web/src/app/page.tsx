"use client";

import { useEffect, useState } from "react";
import { getAllPrices } from "@/lib/api/prices";
import type { PriceGroup, PriceItem } from "@/lib/api/prices";
import { Skeleton } from "@/components/ui/skeleton";
import { AdSlot } from "@/components/shared/ad-slot";
import { TrendingUp, TrendingDown, Minus } from "lucide-react";

function formatPrice(val: string | number | undefined): string {
  if (!val) return "-";
  const n = parseFloat(String(val));
  if (isNaN(n)) return String(val);
  return n % 1 === 0 ? n.toFixed(0) : n.toFixed(2);
}

function calcChange(item: PriceItem, isFeed: boolean): number {
  const th = parseFloat(item.today_higher_price) || 0;
  const tl = parseFloat(item.today_lower_price) || 0;
  const yh = parseFloat(item.yesterday_higher_price) || 0;
  const yl = parseFloat(item.yesterday_lower_price) || 0;
  if (isFeed) return th - yh;
  return ((th + tl) / 2) - ((yh + yl) / 2);
}

function PriceCard({ item, isFeed }: { item: PriceItem; isFeed: boolean }) {
  const higher = item.today_higher_price || "0";
  const lower = item.today_lower_price || "0";
  const change = calcChange(item, isFeed);
  const isUp = change > 0;
  const isDown = change < 0;
  const changeFormatted = isNaN(change) || change === 0
    ? null
    : `${isUp ? "+" : "-"}${(Math.abs(change) % 1 === 0 ? Math.abs(change).toFixed(0) : Math.abs(change).toFixed(2))}`;

  return (
    <div className="rounded-2xl border border-border/30 bg-card p-3.5 shadow-elev-sm">
      <div className="flex items-center justify-between">
        <span className="text-title-lg font-medium text-foreground">
          {item.type_name}
        </span>
        {changeFormatted && (
          <div
            className={`flex items-center gap-1 rounded-lg px-2 py-1 text-label-md font-bold ${
              isUp
                ? "bg-success/10 text-success"
                : "bg-destructive/10 text-destructive"
            }`}
          >
            {isUp ? (
              <TrendingUp className="h-3.5 w-3.5" />
            ) : (
              <TrendingDown className="h-3.5 w-3.5" />
            )}
            {changeFormatted}
          </div>
        )}
        {!changeFormatted && (
          <div className="flex items-center gap-1 rounded-lg bg-muted px-2 py-1 text-label-md text-foreground/40">
            <Minus className="h-3.5 w-3.5" />
            -
          </div>
        )}
      </div>

      <div className="mt-2.5 flex items-center gap-3">
        {!isFeed && (
          <>
            <div className="flex-1 rounded-xl bg-muted/50 p-2 text-center">
              <p className="text-label-sm text-foreground/50">أقل</p>
              <p className="text-title-md font-bold text-foreground">
                {formatPrice(lower)}
              </p>
            </div>
            <div className="flex-1 rounded-xl bg-muted/50 p-2 text-center">
              <p className="text-label-sm text-foreground/50">أعلى</p>
              <p className="text-title-md font-bold text-foreground">
                {formatPrice(higher)}
              </p>
            </div>
          </>
        )}
        {isFeed && (
          <div className="flex-1 rounded-xl bg-muted/50 p-2 text-center">
            <p className="text-label-sm text-foreground/50">السعر</p>
            <p className="text-title-md font-bold text-foreground">
              {formatPrice(higher)}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

function PriceGroupSection({ group }: { group: PriceGroup }) {
  const isFeed = group.name.includes("علف") || group.name.includes("اعلاف");

  return (
    <div>
      <h3 className="mb-3 text-headline-sm text-primary">{group.name}</h3>
      <div className="grid grid-cols-2 gap-2 sm:grid-cols-3 md:grid-cols-4">
        {group.prices.map((item) => (
          <PriceCard key={item.type_id} item={item} isFeed={isFeed} />
        ))}
      </div>
    </div>
  );
}

export default function HomePage() {
  const [groups, setGroups] = useState<PriceGroup[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    load();
  }, []);

  const load = async () => {
    try {
      const res = await getAllPrices();
      if (res.data) {
        setGroups(res.data);
      }
    } catch {
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="px-4 py-4">
      <h2 className="mb-4 text-headline-sm text-primary">أسعار اليوم</h2>

      {loading ? (
        <div className="space-y-6">
          {[1, 2, 3].map((i) => (
            <div key={i} className="space-y-2">
              <Skeleton className="h-6 w-32" />
              <div className="grid grid-cols-2 gap-2">
                <Skeleton className="h-28 rounded-2xl" />
                <Skeleton className="h-28 rounded-2xl" />
                <Skeleton className="h-28 rounded-2xl" />
                <Skeleton className="h-28 rounded-2xl" />
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="space-y-6">
          {groups.map((group, idx) => (
            <div key={group.id}>
              <PriceGroupSection group={group} />
              {idx === 0 && <AdSlot />}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
