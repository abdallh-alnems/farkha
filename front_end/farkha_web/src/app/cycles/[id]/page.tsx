"use client";

import { useState, useEffect, useCallback } from "react";
import { useParams, useRouter } from "next/navigation";
import { useAuthStore } from "@/lib/stores/auth-store";
import { getAuthToken } from "@/lib/hooks/use-auth-token";
import { getCycleDetails, addCycleData, deleteCycleItem, addExpense as addExpenseApi, addSale as addSaleApi, addNote as addNoteApi, deleteNote as deleteNoteApi, deleteCycle, updateCycle, endCycle, isOk } from "@/lib/api/cycles";
import type { CycleDetails, CycleDataEntry } from "@/lib/types/cycle";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Textarea } from "@/components/ui/textarea";
import {
  ArrowRight,
  Plus,
  Scale,
  Skull,
  Wheat,
  Syringe,
  Pill,
  Trash2,
  Loader2,
  Settings,
  Power,
} from "lucide-react";
import { toast } from "sonner";

function ageOf(isoDate: string): number {
  const start = new Date(isoDate);
  const now = new Date();
  return Math.floor((now.getTime() - start.getTime()) / 86400000) + 1;
}

function formatNum(n: string | number): string {
  const num = typeof n === "string" ? parseFloat(n) : n;
  if (isNaN(num)) return "0";
  return num.toLocaleString("ar-EG", { maximumFractionDigits: 2 });
}

function formatDate(dateStr: string): string {
  const d = new Date(dateStr);
  return d.toLocaleDateString("ar-EG", {
    month: "short",
    day: "numeric",
  });
}

type Tab = "overview" | "data" | "expenses" | "sales" | "notes";

const METRIC_CONFIG: Record<
  string,
  { label: string; icon: typeof Scale; unit: string; color: string }
> = {
  weight: {
    label: "الوزن",
    icon: Scale,
    unit: "كجم",
    color: "text-primary",
  },
  mortality: {
    label: "النفوق",
    icon: Skull,
    unit: "طائر",
    color: "text-destructive",
  },
  feed: {
    label: "العلف",
    icon: Wheat,
    unit: "كجم",
    color: "text-wheat",
  },
  vaccination: {
    label: "تحصين",
    icon: Syringe,
    unit: "",
    color: "text-info",
  },
  medicine: {
    label: "دواء",
    icon: Pill,
    unit: "",
    color: "text-terracotta",
  },
};

export default function CycleDetailPage() {
  const params = useParams();
  const router = useRouter();
  const { user } = useAuthStore();
  const cycleId = Number(params.id);

  const [detail, setDetail] = useState<CycleDetails | null>(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<Tab>("overview");
  const [addDialogOpen, setAddDialogOpen] = useState(false);
  const [addMetricType, setAddMetricType] = useState("weight");
  const [addNumericValue, setAddNumericValue] = useState("");
  const [addTextValue, setAddTextValue] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [editOpen, setEditOpen] = useState(false);
  const [deleteOpen, setDeleteOpen] = useState(false);
  const [endOpen, setEndOpen] = useState(false);
  const [editName, setEditName] = useState("");
  const [editChickCount, setEditChickCount] = useState("");
  const [editSpace, setEditSpace] = useState("");
  const [editDate, setEditDate] = useState("");
  const [editSubmitting, setEditSubmitting] = useState(false);

  const fetchDetail = useCallback(async () => {
    const token = await getAuthToken();
    if (!token) return;
    setLoading(true);
    const res = await getCycleDetails(token, cycleId);
    if (isOk(res) && res.data) {
      setDetail(res.data);
    } else {
      toast.error("فشل تحميل بيانات الدورة");
    }
    setLoading(false);
  }, [cycleId]);

  const openEdit = () => {
    if (!detail) return;
    const c = detail.cycle;
    setEditName(c.name);
    setEditChickCount(c.chick_count);
    setEditSpace(c.space);
    setEditDate(c.start_date_raw);
    setEditOpen(true);
  };

  const handleEdit = async () => {
    const token = await getAuthToken();
    if (!token) return;
    setEditSubmitting(true);
    const res = await updateCycle(token, {
      cycle_id: cycleId,
      name: editName.trim(),
      chick_count: editChickCount,
      space: editSpace,
      start_date_raw: editDate,
      breed: detail?.cycle.breed || "تسمين",
      system_type: detail?.cycle.system_type || "أرضي",
    });
    if (isOk(res)) {
      toast.success("تم تعديل الدورة");
      setEditOpen(false);
      fetchDetail();
    } else {
      toast.error(res.message || "حدث خطأ");
    }
    setEditSubmitting(false);
  };

  const handleDelete = async () => {
    const token = await getAuthToken();
    if (!token) return;
    const res = await deleteCycle(token, cycleId);
    if (isOk(res)) {
      toast.success("تم حذف الدورة");
      router.push("/cycles");
    } else {
      toast.error(res.message || "حدث خطأ");
    }
  };

  const handleEnd = async () => {
    const token = await getAuthToken();
    if (!token) return;
    const res = await endCycle(token, cycleId);
    if (isOk(res)) {
      toast.success("تم إنهاء الدورة");
      setEndOpen(false);
      fetchDetail();
    } else {
      toast.error(res.message || "حدث خطأ");
    }
  };

  useEffect(() => {
    fetchDetail();
  }, [fetchDetail]);

  const handleAddData = async () => {
    const token = await getAuthToken();
    if (!token) return;
    setSubmitting(true);
    const numericVal = addNumericValue ? parseFloat(addNumericValue) : undefined;
    const textVal = addTextValue || undefined;
    const res = await addCycleData(
      token,
      cycleId,
      addMetricType,
      numericVal,
      textVal,
    );
    if (isOk(res)) {
      toast.success("تمت الإضافة");
      setAddDialogOpen(false);
      setAddNumericValue("");
      setAddTextValue("");
      fetchDetail();
    } else {
      toast.error(res.message || "حدث خطأ");
    }
    setSubmitting(false);
  };

  const handleDeleteEntry = async (entry: CycleDataEntry) => {
    const token = await getAuthToken();
    if (!token) return;
    const res = await deleteCycleItem(
      token,
      cycleId,
      "data",
      "single",
      entry.id,
    );
    if (isOk(res)) {
      toast.success("تم الحذف");
      fetchDetail();
    } else {
      toast.error(res.message || "حدث خطأ");
    }
  };

  if (loading) {
    return (
      <div className="px-4 py-4">
        <Skeleton className="mb-4 h-8 w-48" />
        <Skeleton className="mb-2 h-24 w-full rounded-2xl" />
        <Skeleton className="h-64 w-full rounded-2xl" />
      </div>
    );
  }

  if (!detail) {
    return (
      <div className="flex items-center justify-center py-20">
        <p className="text-body-lg text-foreground/50">
          لم يتم العثور على الدورة
        </p>
      </div>
    );
  }

  const cycle = detail.cycle;
  const days = ageOf(cycle.start_date_raw);
  const chickCount = parseInt(cycle.chick_count) || 0;
  const mortalityNum = parseFloat(cycle.mortality) || 0;
  const mortalityRate =
    chickCount > 0 ? ((mortalityNum / chickCount) * 100).toFixed(1) : "0";
  const expenses = parseFloat(cycle.total_expenses) || 0;
  const sales = parseFloat(cycle.total_sales) || 0;
  const profit = sales - expenses;
  const liveCount = chickCount - mortalityNum;
  const isViewer = cycle.role === "viewer";

  const groupedData: Record<string, CycleDataEntry[]> = {};
  for (const entry of detail.data) {
    if (!groupedData[entry.metric_type]) groupedData[entry.metric_type] = [];
    groupedData[entry.metric_type].push(entry);
  }

  const tabs: { key: Tab; label: string }[] = [
    { key: "overview", label: "نظرة عامة" },
    { key: "data", label: "البيانات" },
    { key: "expenses", label: "المصروفات" },
    { key: "sales", label: "المبيعات" },
    { key: "notes", label: "ملاحظات" },
  ];

  return (
    <div className="px-4 py-4">
      <div className="mb-3 flex items-center gap-3">
        <button
          onClick={() => router.push("/cycles")}
          className="flex h-9 w-9 items-center justify-center rounded-lg text-foreground/60 hover:bg-foreground/[0.04]"
        >
          <ArrowRight className="h-5 w-5" />
        </button>
        <div className="flex-1">
          <h1 className="text-headline-sm text-primary">{cycle.name}</h1>
          <p className="text-label-md text-foreground/50">
            يوم {days} &middot; {cycle.chick_count} طائر &middot; {cycle.space} م²
          </p>
        </div>
        <div className="flex items-center gap-1">
          <button
            onClick={openEdit}
            className="flex h-8 w-8 items-center justify-center rounded-lg text-foreground/50 hover:bg-foreground/[0.04]"
          >
            <Settings className="h-4 w-4" />
          </button>
          <button
            onClick={() => setEndOpen(true)}
            className="flex h-8 w-8 items-center justify-center rounded-lg text-foreground/50 hover:bg-foreground/[0.04]"
          >
            <Power className="h-4 w-4" />
          </button>
          <button
            onClick={() => setDeleteOpen(true)}
            className="flex h-8 w-8 items-center justify-center rounded-lg text-destructive/50 hover:bg-destructive/[0.04]"
          >
            <Trash2 className="h-4 w-4" />
          </button>
        </div>
      </div>

      <div className="mb-4 flex gap-1 overflow-x-auto rounded-xl bg-muted p-1 no-scrollbar">
        {tabs.map((t) => (
          <button
            key={t.key}
            onClick={() => setActiveTab(t.key)}
            className={`shrink-0 rounded-lg px-3 py-2 text-label-md transition-colors ${
              activeTab === t.key
                ? "bg-card text-primary shadow-elev-sm"
                : "text-foreground/50 hover:text-foreground/70"
            }`}
          >
            {t.label}
          </button>
        ))}
      </div>

      {activeTab === "overview" && (
        <div className="space-y-3">
          <div className="card-elevated">
            <h3 className="mb-3 text-title-lg text-foreground">ملخص الدورة</h3>
            <div className="grid grid-cols-2 gap-3">
              <div className="rounded-xl bg-muted/50 p-3 text-center">
                <p className="text-label-sm text-foreground/50">الطيور الحية</p>
                <p className="text-title-lg font-bold text-foreground">
                  {formatNum(liveCount)}
                </p>
              </div>
              <div className="rounded-xl bg-muted/50 p-3 text-center">
                <p className="text-label-sm text-foreground/50">النفوق</p>
                <p className="text-title-lg font-bold text-destructive">
                  {mortalityRate}%
                </p>
              </div>
              <div className="rounded-xl bg-muted/50 p-3 text-center">
                <p className="text-label-sm text-foreground/50">المصروفات</p>
                <p className="text-title-lg font-bold text-foreground">
                  {formatNum(expenses)}
                </p>
              </div>
              <div className="rounded-xl bg-muted/50 p-3 text-center">
                <p className="text-label-sm text-foreground/50">تكلفة الفرخ</p>
                <p className="text-title-lg font-bold text-foreground">
                  {liveCount > 0 && expenses > 0
                    ? formatNum(expenses / liveCount)
                    : "0"}{" "}
                  ج
                </p>
              </div>
            </div>
          </div>

        </div>
      )}

      {activeTab === "data" && (
        <div className="space-y-4">
          {!isViewer && (
            <Dialog open={addDialogOpen} onOpenChange={setAddDialogOpen}>
              <DialogTrigger render={<Button className="w-full gap-1.5 rounded-xl" />}>
                  <Plus className="h-4 w-4" />
                  إضافة بيانات
              </DialogTrigger>
              <DialogContent dir="rtl">
                <DialogHeader>
                  <DialogTitle>إضافة بيانات يومية</DialogTitle>
                </DialogHeader>
                <div className="space-y-3">
                  <div className="flex flex-wrap gap-1.5">
                    {Object.entries(METRIC_CONFIG).map(([key, cfg]) => (
                      <button
                        key={key}
                        onClick={() => setAddMetricType(key)}
                        className={`flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-label-md transition-colors ${
                          addMetricType === key
                            ? "bg-primary/10 text-primary"
                            : "bg-muted text-foreground/50 hover:text-foreground/70"
                        }`}
                      >
                        <cfg.icon className="h-3.5 w-3.5" />
                        {cfg.label}
                      </button>
                    ))}
                  </div>
                  {(addMetricType === "weight" ||
                    addMetricType === "mortality" ||
                    addMetricType === "feed") && (
                    <div>
                      <Input
                        type="number"
                        placeholder={`القيمة (${METRIC_CONFIG[addMetricType].unit})`}
                        value={addNumericValue}
                        onChange={(e) => setAddNumericValue(e.target.value)}
                        className="h-11 rounded-xl"
                        dir="ltr"
                      />
                    </div>
                  )}
                  {(addMetricType === "vaccination" ||
                    addMetricType === "medicine") && (
                    <div>
                      <Textarea
                        placeholder={`وصف ${METRIC_CONFIG[addMetricType].label}`}
                        value={addTextValue}
                        onChange={(e) => setAddTextValue(e.target.value)}
                        className="rounded-xl"
                        rows={2}
                      />
                    </div>
                  )}
                  <Button
                    onClick={handleAddData}
                    className="w-full rounded-xl"
                    disabled={
                      submitting ||
                      (!addNumericValue && !addTextValue)
                    }
                  >
                    {submitting ? (
                      <Loader2 className="h-4 w-4 animate-spin" />
                    ) : (
                      "إضافة"
                    )}
                  </Button>
                </div>
              </DialogContent>
            </Dialog>
          )}

          {Object.entries(METRIC_CONFIG).map(([key, cfg]) => {
            const entries = groupedData[key];
            if (!entries || entries.length === 0) return null;
            return (
              <div key={key}>
                <h3 className={`mb-2 flex items-center gap-2 text-title-lg ${cfg.color}`}>
                  <cfg.icon className="h-4 w-4" />
                  {cfg.label}
                </h3>
                <div className="space-y-1.5">
                  {entries.map((entry) => (
                    <div
                      key={entry.id}
                      className="flex items-center justify-between rounded-xl bg-card px-3 py-2 shadow-elev-sm"
                    >
                      <div className="flex items-center gap-2">
                        <span className="text-label-md text-foreground/50">
                          {formatDate(entry.entry_date)}
                        </span>
                        <span className="text-body-md font-medium">
                          {entry.numeric_value
                            ? `${entry.numeric_value} ${cfg.unit}`
                            : entry.text_value}
                        </span>
                      </div>
                      {!isViewer && (
                        <button
                          onClick={() => handleDeleteEntry(entry)}
                          className="text-foreground/30 hover:text-destructive"
                        >
                          <Trash2 className="h-3.5 w-3.5" />
                        </button>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            );
          })}

          {detail.data.length === 0 && (
            <p className="py-8 text-center text-body-md text-foreground/40">
              لا توجد بيانات مسجلة بعد
            </p>
          )}
        </div>
      )}

      {activeTab === "expenses" && (
        <ExpensesTab
          cycleId={cycleId}
          expenses={detail.expenses}
          isViewer={isViewer}
          onRefresh={fetchDetail}
        />
      )}

      {activeTab === "sales" && (
        <SalesTab
          cycleId={cycleId}
          sales={detail.sales}
          isViewer={isViewer}
          onRefresh={fetchDetail}
        />
      )}

      {activeTab === "notes" && (
        <NotesTab
          cycleId={cycleId}
          notes={detail.notes}
          isViewer={isViewer}
          onRefresh={fetchDetail}
        />
      )}

      <Dialog open={editOpen} onOpenChange={setEditOpen}>
        <DialogContent dir="rtl">
          <DialogHeader>
            <DialogTitle>تعديل الدورة</DialogTitle>
          </DialogHeader>
          <div className="space-y-3">
            <Input
              placeholder="اسم الدورة"
              value={editName}
              onChange={(e) => setEditName(e.target.value)}
              className="h-11 rounded-xl"
            />
            <div className="grid grid-cols-2 gap-3">
              <Input
                type="text"
                inputMode="numeric"
                placeholder="عدد الكتاكيت"
                value={editChickCount}
                onChange={(e) => setEditChickCount(e.target.value.replace(/[^0-9]/g, ""))}
                className="h-11 rounded-xl"
                dir="ltr"
              />
              <Input
                type="number"
                placeholder="المساحة (م²)"
                value={editSpace}
                onChange={(e) => setEditSpace(e.target.value)}
                className="h-11 rounded-xl"
                dir="ltr"
              />
            </div>
            <Input
              type="date"
              value={editDate}
              onChange={(e) => setEditDate(e.target.value)}
              className="h-11 rounded-xl"
              dir="ltr"
            />
            <Button
              onClick={handleEdit}
              className="w-full rounded-xl"
              disabled={editSubmitting || !editName || !editChickCount || !editSpace}
            >
              {editSubmitting ? <Loader2 className="h-4 w-4 animate-spin" /> : "حفظ التعديلات"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      <Dialog open={deleteOpen} onOpenChange={setDeleteOpen}>
        <DialogContent dir="rtl">
          <DialogHeader>
            <DialogTitle>حذف الدورة</DialogTitle>
          </DialogHeader>
          <p className="text-body-md text-foreground/70">
            هل أنت متأكد من حذف "{cycle.name}"؟ لا يمكن التراجع عن هذا الإجراء.
          </p>
          <div className="flex gap-2">
            <Button
              variant="destructive"
              onClick={handleDelete}
              className="flex-1 rounded-xl"
            >
              حذف
            </Button>
            <Button
              variant="outline"
              onClick={() => setDeleteOpen(false)}
              className="flex-1 rounded-xl"
            >
              إلغاء
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      <Dialog open={endOpen} onOpenChange={setEndOpen}>
        <DialogContent dir="rtl">
          <DialogHeader>
            <DialogTitle>إنهاء الدورة</DialogTitle>
          </DialogHeader>
          <p className="text-body-md text-foreground/70">
            هل تريد إنهاء دورة "{cycle.name}"؟ سيتم نقلها للسابقة.
          </p>
          <div className="flex gap-2">
            <Button
              onClick={handleEnd}
              className="flex-1 rounded-xl"
            >
              إنهاء الدورة
            </Button>
            <Button
              variant="outline"
              onClick={() => setEndOpen(false)}
              className="flex-1 rounded-xl"
            >
              إلغاء
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}

function ExpensesTab({
  cycleId,
  expenses,
  isViewer,
  onRefresh,
}: {
  cycleId: number;
  expenses: CycleDetails["expenses"];
  isViewer: boolean;
  onRefresh: () => void;
}) {
  const { user } = useAuthStore();
  const [dialogOpen, setDialogOpen] = useState(false);
  const [label, setLabel] = useState("");
  const [value, setValue] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const grouped: Record<string, typeof expenses> = {};
  for (const exp of expenses) {
    if (!grouped[exp.label]) grouped[exp.label] = [];
    grouped[exp.label].push(exp);
  }
  const totalByLabel: Record<string, number> = {};
  for (const [lbl, items] of Object.entries(grouped)) {
    totalByLabel[lbl] = items.reduce((s, i) => s + (parseFloat(i.value) || 0), 0);
  }
  const total = expenses.reduce(
    (s, e) => s + (parseFloat(e.value) || 0),
    0,
  );

  const handleAdd = async () => {
    const token = await getAuthToken();
    if (!token || !label || !value) return;
    setSubmitting(true);
    const res = await addExpenseApi(token, cycleId, label, parseFloat(value));
    if (isOk(res)) {
      toast.success("تمت الإضافة");
      setDialogOpen(false);
      setLabel("");
      setValue("");
      onRefresh();
    } else {
      toast.error(res.message || "حدث خطأ");
    }
    setSubmitting(false);
  };

  const handleDelete = async (exp: (typeof expenses)[0]) => {
    const token = await getAuthToken();
    if (!token) return;
    const res = await deleteCycleItem(token, cycleId, "expense", "single", exp.id);
    if (isOk(res)) {
      toast.success("تم الحذف");
      onRefresh();
    }
  };

  return (
    <div className="space-y-3">
      {!isViewer && (
        <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
          <DialogTrigger render={<Button className="w-full gap-1.5 rounded-xl" />}>
              <Plus className="h-4 w-4" />
              إضافة مصروف
          </DialogTrigger>
          <DialogContent dir="rtl">
            <DialogHeader>
              <DialogTitle>إضافة مصروف</DialogTitle>
            </DialogHeader>
            <div className="space-y-3">
              <div className="flex flex-wrap gap-1.5">
                {[
                  "الكتاكيت",
                  "العلف",
                  "الأدوية والتحصينات",
                  "الكهرباء",
                  "المياه",
                  "النقل",
                  "العمالة",
                ].map((cat) => (
                  <button
                    key={cat}
                    onClick={() => setLabel(cat)}
                    className={`rounded-lg px-2.5 py-1 text-label-sm transition-colors ${
                      label === cat
                        ? "bg-primary/10 text-primary"
                        : "bg-muted text-foreground/50"
                    }`}
                  >
                    {cat}
                  </button>
                ))}
              </div>
              {!["الكتاكيت","العلف","الأدوية والتحصينات","الكهرباء","المياه","النقل","العمالة"].includes(label) && (
                <Input
                  placeholder="اسم المصروف"
                  value={label}
                  onChange={(e) => setLabel(e.target.value)}
                  className="h-11 rounded-xl"
                />
              )}
              <Input
                type="number"
                placeholder="المبلغ (ج.م)"
                value={value}
                onChange={(e) => setValue(e.target.value)}
                className="h-11 rounded-xl"
                dir="ltr"
              />
              <Button
                onClick={handleAdd}
                className="w-full rounded-xl"
                disabled={submitting || !label || !value}
              >
                {submitting ? <Loader2 className="h-4 w-4 animate-spin" /> : "إضافة"}
              </Button>
            </div>
          </DialogContent>
        </Dialog>
      )}

      <div className="card-elevated">
        <div className="flex items-center justify-between">
          <h3 className="text-title-lg">إجمالي المصروفات</h3>
          <p className="text-headline-sm font-bold text-foreground">
            {formatNum(total)} ج.م
          </p>
        </div>
      </div>

      {Object.entries(grouped).map(([lbl, items]) => (
        <div key={lbl} className="card-elevated">
          <div className="mb-2 flex items-center justify-between">
            <h4 className="text-title-md">{lbl}</h4>
            <span className="text-title-md font-bold">
              {formatNum(totalByLabel[lbl])} ج.م
            </span>
          </div>
          <div className="space-y-1">
            {items.map((exp) => (
              <div
                key={exp.id}
                className="flex items-center justify-between rounded-lg px-2 py-1.5 hover:bg-muted/50"
              >
                <span className="text-label-md text-foreground/50">
                  {formatDate(exp.entry_date)}
                </span>
                <div className="flex items-center gap-2">
                  <span className="text-body-md">{formatNum(exp.value)}</span>
                  {!isViewer && (
                    <button
                      onClick={() => handleDelete(exp)}
                      className="text-foreground/30 hover:text-destructive"
                    >
                      <Trash2 className="h-3 w-3" />
                    </button>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      ))}

      {expenses.length === 0 && (
        <p className="py-8 text-center text-body-md text-foreground/40">
          لا توجد مصروفات مسجلة
        </p>
      )}
    </div>
  );
}

function SalesTab({
  cycleId,
  sales,
  isViewer,
  onRefresh,
}: {
  cycleId: number;
  sales: CycleDetails["sales"];
  isViewer: boolean;
  onRefresh: () => void;
}) {
  const { user } = useAuthStore();
  const [dialogOpen, setDialogOpen] = useState(false);
  const [quantity, setQuantity] = useState("");
  const [totalWeight, setTotalWeight] = useState("");
  const [pricePerKg, setPricePerKg] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const totalPrice =
    parseFloat(totalWeight || "0") * parseFloat(pricePerKg || "0");
  const totalSales = sales.reduce(
    (s, sale) => s + (parseFloat(sale.total_price) || 0),
    0,
  );
  const totalQty = sales.reduce(
    (s, sale) => s + (parseInt(sale.quantity) || 0),
    0,
  );

  const handleAdd = async () => {
    const token = await getAuthToken();
    if (!token || !quantity || !totalWeight || !pricePerKg) return;
    setSubmitting(true);
    const res = await addSaleApi(token, cycleId, {
      quantity: parseInt(quantity),
      total_weight: parseFloat(totalWeight),
      price_per_kg: parseFloat(pricePerKg),
      total_price: totalPrice,
    });
    if (isOk(res)) {
      toast.success("تمت الإضافة");
      setDialogOpen(false);
      setQuantity("");
      setTotalWeight("");
      setPricePerKg("");
      onRefresh();
    } else {
      toast.error(res.message || "حدث خطأ");
    }
    setSubmitting(false);
  };

  const handleDelete = async (sale: (typeof sales)[0]) => {
    const token = await getAuthToken();
    if (!token) return;
    const res = await deleteCycleItem(token, cycleId, "sale", "single", sale.id);
    if (isOk(res)) {
      toast.success("تم الحذف");
      onRefresh();
    }
  };

  return (
    <div className="space-y-3">
      {!isViewer && (
        <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
          <DialogTrigger render={<Button className="w-full gap-1.5 rounded-xl" />}>
              <Plus className="h-4 w-4" />
              إضافة عملية بيع
          </DialogTrigger>
          <DialogContent dir="rtl">
            <DialogHeader>
              <DialogTitle>إضافة عملية بيع</DialogTitle>
            </DialogHeader>
            <div className="space-y-3">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <Input
                    type="number"
                    placeholder="عدد الطيور"
                    value={quantity}
                    onChange={(e) => setQuantity(e.target.value)}
                    className="h-11 rounded-xl"
                    dir="ltr"
                  />
                </div>
                <div>
                  <Input
                    type="number"
                    placeholder="الوزن الكلي (كجم)"
                    value={totalWeight}
                    onChange={(e) => setTotalWeight(e.target.value)}
                    className="h-11 rounded-xl"
                    dir="ltr"
                  />
                </div>
              </div>
              <Input
                type="number"
                placeholder="سعر الكيلو (ج.م)"
                value={pricePerKg}
                onChange={(e) => setPricePerKg(e.target.value)}
                className="h-11 rounded-xl"
                dir="ltr"
              />
              {totalPrice > 0 && (
                <p className="text-center text-title-md">
                  الإجمالي:{" "}
                  <span className="font-bold text-primary">
                    {formatNum(totalPrice)} ج.م
                  </span>
                </p>
              )}
              <Button
                onClick={handleAdd}
                className="w-full rounded-xl"
                disabled={submitting || !quantity || !totalWeight || !pricePerKg}
              >
                {submitting ? <Loader2 className="h-4 w-4 animate-spin" /> : "إضافة"}
              </Button>
            </div>
          </DialogContent>
        </Dialog>
      )}

      <div className="card-elevated">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-label-sm text-foreground/50">إجمالي المبيعات</p>
            <p className="text-headline-sm font-bold text-success">
              {formatNum(totalSales)} ج.م
            </p>
          </div>
          <Badge variant="outline">{totalQty} طائر مباع</Badge>
        </div>
      </div>

      {sales.map((sale) => (
        <div key={sale.id} className="card-elevated">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-body-md font-medium">
                {sale.quantity} طائر &middot; {sale.total_weight} كجم
              </p>
              <p className="text-label-sm text-foreground/50">
                {formatDate(sale.sale_date)} &middot; سعر الكيلو:{" "}
                {sale.price_per_kg} ج.م
              </p>
            </div>
            <div className="flex items-center gap-2">
              <span className="text-title-md font-bold text-success">
                {formatNum(sale.total_price)}
              </span>
              {!isViewer && (
                <button
                  onClick={() => handleDelete(sale)}
                  className="text-foreground/30 hover:text-destructive"
                >
                  <Trash2 className="h-3.5 w-3.5" />
                </button>
              )}
            </div>
          </div>
        </div>
      ))}

      {sales.length === 0 && (
        <p className="py-8 text-center text-body-md text-foreground/40">
          لا توجد عمليات بيع
        </p>
      )}
    </div>
  );
}

function NotesTab({
  cycleId,
  notes,
  isViewer,
  onRefresh,
}: {
  cycleId: number;
  notes: CycleDetails["notes"];
  isViewer: boolean;
  onRefresh: () => void;
}) {
  const { user } = useAuthStore();
  const [newNote, setNewNote] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const handleAdd = async () => {
    const token = await getAuthToken();
    if (!token || !newNote.trim()) return;
    setSubmitting(true);
    const res = await addNoteApi(token, cycleId, newNote.trim());
    if (isOk(res)) {
      toast.success("تمت الإضافة");
      setNewNote("");
      onRefresh();
    } else {
      toast.error(res.message || "حدث خطأ");
    }
    setSubmitting(false);
  };

  const handleDelete = async (noteId: string) => {
    const token = await getAuthToken();
    if (!token) return;
    const res = await deleteNoteApi(token, cycleId, noteId);
    if (isOk(res)) {
      toast.success("تم الحذف");
      onRefresh();
    }
  };

  return (
    <div className="space-y-3">
      {!isViewer && (
        <div className="flex gap-2">
          <Textarea
            placeholder="اكتب ملاحظة..."
            value={newNote}
            onChange={(e) => setNewNote(e.target.value)}
            className="flex-1 rounded-xl"
            rows={2}
          />
          <Button
            onClick={handleAdd}
            className="h-auto shrink-0 rounded-xl px-4"
            disabled={submitting || !newNote.trim()}
          >
            {submitting ? <Loader2 className="h-4 w-4 animate-spin" /> : "إضافة"}
          </Button>
        </div>
      )}

      {notes.map((note) => (
        <div
          key={note.id}
          className="flex items-start justify-between gap-2 rounded-xl bg-card px-3 py-2.5 shadow-elev-sm"
        >
          <div className="flex-1">
            <p className="text-body-md">{note.content}</p>
            <p className="mt-1 text-label-sm text-foreground/40">
              {formatDate(note.entry_date)}
            </p>
          </div>
          {!isViewer && (
            <button
              onClick={() => handleDelete(note.id)}
              className="shrink-0 text-foreground/30 hover:text-destructive"
            >
              <Trash2 className="h-3.5 w-3.5" />
            </button>
          )}
        </div>
      ))}

      {notes.length === 0 && (
        <p className="py-8 text-center text-body-md text-foreground/40">
          لا توجد ملاحظات
        </p>
      )}
    </div>
  );
}
