import { apiPost } from "./client";
import type {
  CycleSummary,
  CycleDetails,
  CycleHistoryPage,
  CycleNote,
} from "@/lib/types/cycle";

interface ApiResponse<T = unknown> {
  status: "success" | "fail" | "error";
  message?: string;
  data?: T;
}

function isOk(res: ApiResponse): boolean {
  return res.status === "success";
}

export async function getCycles(
  token: string,
): Promise<ApiResponse<{ cycles: CycleSummary[]; count: number }>> {
  return apiPost("app/cycles/get_cycles.php", { token });
}

export async function getCycleDetails(
  token: string,
  cycleId: number,
): Promise<ApiResponse<CycleDetails>> {
  return apiPost("app/cycles/get_cycle_details.php", {
    token,
    cycle_id: cycleId,
  });
}

export async function createCycle(
  token: string,
  data: {
    name: string;
    chick_count: string;
    space: string;
    start_date_raw: string;
    breed?: string;
    system_type?: string;
  },
): Promise<ApiResponse<{ cycle_id?: number }>> {
  return apiPost("app/cycles/create.php", { token, ...data });
}

export async function updateCycle(
  token: string,
  data: {
    cycle_id: number;
    name: string;
    chick_count: string;
    space: string;
    start_date_raw: string;
    breed?: string;
    system_type?: string;
  },
): Promise<ApiResponse> {
  return apiPost("app/cycles/update_cycle.php", { token, ...data });
}

export async function deleteCycle(
  token: string,
  cycleId: number,
): Promise<ApiResponse> {
  return apiPost("app/cycles/delete.php", { token, cycle_id: cycleId });
}

export async function getHistory(
  token: string,
  page: number,
  limit: number,
  search?: string,
  dateFrom?: string,
  dateTo?: string,
): Promise<ApiResponse<CycleHistoryPage>> {
  return apiPost("app/cycles/get_history.php", {
    token,
    page,
    limit,
    search: search || undefined,
    date_from: dateFrom || undefined,
    date_to: dateTo || undefined,
  });
}

export async function endCycle(
  token: string,
  cycleId: number,
  endDate?: string,
): Promise<ApiResponse> {
  return apiPost("app/cycles/update_status.php", {
    token,
    cycle_id: cycleId,
    status: "finished",
    end_date: endDate || undefined,
  });
}

export async function addCycleData(
  token: string,
  cycleId: number,
  metricType: string,
  numericValue?: number,
  textValue?: string,
): Promise<ApiResponse> {
  return apiPost("app/cycles/add_data.php", {
    token,
    cycle_id: cycleId,
    metric_type: metricType,
    numeric_value: numericValue,
    text_value: textValue,
  });
}

export async function addExpense(
  token: string,
  cycleId: number,
  label: string,
  value: number,
): Promise<ApiResponse> {
  return apiPost("app/cycles/add_expense.php", {
    token,
    cycle_id: cycleId,
    label,
    value,
  });
}

export async function addSale(
  token: string,
  cycleId: number,
  data: {
    quantity: number;
    total_weight: number;
    price_per_kg: number;
    total_price: number;
    sale_date?: string;
  },
): Promise<ApiResponse> {
  return apiPost("app/cycles/add_sale.php", {
    token,
    cycle_id: cycleId,
    ...data,
  });
}

export async function deleteCycleItem(
  token: string,
  cycleId: number,
  type: "data" | "expense" | "sale",
  deleteType: "single" | "by_metric_type" | "by_label",
  itemId?: string,
  metricType?: string,
  label?: string,
): Promise<ApiResponse> {
  return apiPost("app/cycles/delete_cycle_item.php", {
    token,
    cycle_id: cycleId,
    type,
    delete_type: deleteType,
    item_id: itemId,
    metric_type: metricType,
    label,
  });
}

export async function getNotes(
  token: string,
  cycleId: number,
): Promise<ApiResponse<{ notes: CycleNote[] }>> {
  return apiPost("app/cycles/notes/get_notes.php", {
    token,
    cycle_id: cycleId,
  });
}

export async function addNote(
  token: string,
  cycleId: number,
  content: string,
): Promise<ApiResponse> {
  return apiPost("app/cycles/notes/add_note.php", {
    token,
    cycle_id: cycleId,
    content,
  });
}

export async function updateNote(
  token: string,
  cycleId: number,
  noteId: string,
  content: string,
): Promise<ApiResponse> {
  return apiPost("app/cycles/notes/update_note.php", {
    token,
    cycle_id: cycleId,
    note_id: noteId,
    content,
  });
}

export async function deleteNote(
  token: string,
  cycleId: number,
  noteId: string,
): Promise<ApiResponse> {
  return apiPost("app/cycles/notes/delete_note.php", {
    token,
    cycle_id: cycleId,
    note_id: noteId,
  });
}

export { isOk };
