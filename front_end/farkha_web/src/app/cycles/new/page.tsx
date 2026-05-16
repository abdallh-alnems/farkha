"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useAuthStore } from "@/lib/stores/auth-store";
import { getAuthToken } from "@/lib/hooks/use-auth-token";
import { createCycle, isOk } from "@/lib/api/cycles";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { ArrowRight, Loader2 } from "lucide-react";
import { toast } from "sonner";

export default function NewCyclePage() {
  const router = useRouter();
  const { user } = useAuthStore();
  const [name, setName] = useState("");
  const [chickCount, setChickCount] = useState("");
  const [space, setSpace] = useState("");
  const [startDate, setStartDate] = useState(
    new Date().toISOString().split("T")[0],
  );
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name || !chickCount || !space || !startDate) return;

    setSubmitting(true);
    try {
      const token = await getAuthToken();
      if (!token) { setSubmitting(false); return; }
      const res = await createCycle(token, {
        name: name.trim(),
        chick_count: chickCount,
        space,
        start_date_raw: startDate,
        breed: "تسمين",
        system_type: "أرضي",
      });
      if (isOk(res)) {
        toast.success("تم إنشاء الدورة بنجاح");
        router.push("/cycles");
      } else {
        toast.error(res.message || "حدث خطأ");
      }
    } catch {
      toast.error("حدث خطأ في الاتصال");
    } finally {
      setSubmitting(false);
    }
  };

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
          <h1 className="text-headline-sm text-primary">دورة جديدة</h1>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <Label htmlFor="name">اسم الدورة</Label>
            <Input
              id="name"
              placeholder="مثال: الدورة الأولى"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="mt-1.5 h-11 rounded-xl"
              required
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <Label htmlFor="chickCount">عدد الكتاكيت</Label>
              <Input
                id="chickCount"
                type="text"
                inputMode="numeric"
                placeholder="عدد الكتاكيت"
                value={chickCount}
                onChange={(e) => setChickCount(e.target.value.replace(/[^0-9]/g, ""))}
                className="mt-1.5 h-11 rounded-xl"
                dir="ltr"
                required
              />
            </div>
            <div>
              <Label htmlFor="space">المساحة (م²)</Label>
              <Input
                id="space"
                type="number"
                placeholder="المساحة بالمتر المربع"
                value={space}
                onChange={(e) => setSpace(e.target.value)}
                className="mt-1.5 h-11 rounded-xl"
                dir="ltr"
                required
              />
            </div>
          </div>

          <div>
            <Label htmlFor="startDate">تاريخ البداية</Label>
            <Input
              id="startDate"
              type="date"
              value={startDate}
              onChange={(e) => setStartDate(e.target.value)}
              className="mt-1.5 h-11 rounded-xl"
              dir="ltr"
              required
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <Label>النوع</Label>
              <div className="mt-1.5 flex h-11 items-center rounded-xl border border-border bg-muted/50 px-3 text-body-md text-foreground/60">
                تسمين
              </div>
            </div>
            <div>
              <Label>نظام التربية</Label>
              <div className="mt-1.5 flex h-11 items-center rounded-xl border border-border bg-muted/50 px-3 text-body-md text-foreground/60">
                أرضي
              </div>
            </div>
          </div>

          <Button
            type="submit"
            className="mt-2 h-12 w-full rounded-2xl text-label-lg"
            size="lg"
            disabled={submitting || !name || !chickCount || !space}
          >
            {submitting ? (
              <Loader2 className="h-5 w-5 animate-spin" />
            ) : (
              "إنشاء الدورة"
            )}
          </Button>
        </form>
      </div>
    </div>
  );
}
