export interface CycleSummary {
  id: number;
  name: string;
  chick_count: string;
  space: string;
  start_date_raw: string;
  mortality: string;
  total_expenses: string;
  total_sales: string;
  breed?: string;
  system_type?: string;
  role?: string;
  status?: string;
  end_date?: string;
  average_weight?: string;
  total_feed?: string;
}

export interface CycleDataEntry {
  id: string;
  metric_type: "weight" | "mortality" | "feed" | "vaccination" | "medicine" | "other";
  numeric_value: string | null;
  text_value: string | null;
  entry_date: string;
}

export interface CycleExpense {
  id: string;
  label: string;
  value: string;
  entry_date: string;
  notes?: string;
}

export interface CycleSale {
  id: string;
  quantity: string;
  total_weight: string;
  price_per_kg: string;
  total_price: string;
  sale_date: string;
}

export interface CycleNote {
  id: string;
  content: string;
  entry_date: string;
}

export interface CycleMember {
  id: string;
  user_id: string;
  role: "owner" | "admin" | "member" | "viewer";
  name?: string;
  phone?: string;
  photo_url?: string;
}

export interface CycleDetails {
  cycle: CycleSummary;
  data: CycleDataEntry[];
  expenses: CycleExpense[];
  sales: CycleSale[];
  notes: CycleNote[];
  members: CycleMember[];
}

export interface CycleHistoryPage {
  cycles: CycleSummary[];
  total: number;
  page: number;
  pages: number;
}

export const DEFAULT_EXPENSE_CATEGORIES = [
  "الكتاكيت",
  "العلف",
  "الأدوية والتحصينات",
  "الكهرباء",
  "المياه",
  "النقل",
  "العمالة",
] as const;

export type MetricType = CycleDataEntry["metric_type"];
