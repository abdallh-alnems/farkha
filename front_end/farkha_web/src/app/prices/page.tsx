"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { ChevronLeft } from "lucide-react";
import { getMainTypes } from "@/lib/api/prices";
import { getFirebaseToken } from "@/lib/firebase/auth";
import { Skeleton } from "@/components/ui/skeleton";

interface MainType {
  id: string | number;
  name: string;
}

export default function PricesPage() {
  const router = useRouter();
  const [types, setTypes] = useState<MainType[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadTypes();
  }, []);

  const loadTypes = async () => {
    try {
      const token = await getFirebaseToken();
      const res = await getMainTypes(token ?? undefined);
      if (res.data) {
        setTypes(res.data as MainType[]);
      }
    } catch {
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="px-4 py-4">
      <h1 className="mb-4 text-headline-md text-primary">الأنواع</h1>

      {loading ? (
        <div className="space-y-2">
          {[1, 2, 3, 4].map((i) => (
            <Skeleton key={i} className="h-16 w-full rounded-2xl" />
          ))}
        </div>
      ) : (
        <div className="space-y-2">
          {types.map((type) => (
            <button
              key={type.id}
              onClick={() =>
                router.push(
                  `/prices/${type.id}?name=${encodeURIComponent(type.name)}`,
                )
              }
              className="flex w-full items-center rounded-2xl border border-border/40 bg-card p-4 text-start shadow-elev-sm transition-colors hover:bg-surface"
            >
              <span className="flex-1 text-title-lg text-foreground">
                {type.name}
              </span>
              <ChevronLeft className="h-4.5 w-4.5 text-foreground/35" />
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
