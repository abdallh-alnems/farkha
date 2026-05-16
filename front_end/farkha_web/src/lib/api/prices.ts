import { apiPost } from "./client";

export interface PriceItem {
  type_id: string | number;
  type_name: string;
  today_higher_price: string;
  today_lower_price: string;
  yesterday_higher_price: string;
  yesterday_lower_price: string;
}

export interface PriceGroup {
  id: number;
  name: string;
  prices: PriceItem[];
}

export interface MainType {
  id: string | number;
  name: string;
}

export async function getAllPrices(): Promise<{
  status: string;
  data?: PriceGroup[];
}> {
  return apiPost("app/prices/all_prices.php", {});
}

export async function getMainTypes(token?: string): Promise<{
  status: string;
  data?: MainType[];
}> {
  const body: Record<string, unknown> = {};
  if (token) body.token = token;
  return apiPost("app/prices/main_types.php", body);
}

export async function getPricesByType(
  mainId: string | number,
  token?: string,
): Promise<{ status: string; data?: PriceItem[] }> {
  const body: Record<string, unknown> = { type: mainId };
  if (token) body.token = token;
  return apiPost("app/prices/by_type.php", body);
}

export interface PriceHistoryEntry {
  date: string;
  higher: string;
  lower: string;
}

export async function getPriceHistory(
  typeId: string | number,
  token?: string,
  page = 1,
): Promise<{ status: string; data?: PriceHistoryEntry[] }> {
  const body: Record<string, unknown> = { type_id: typeId, page };
  if (token) body.token = token;
  return apiPost("app/prices/history.php", body);
}

export interface Article {
  id: string | number;
  title: string;
  content?: string;
  image?: string;
}

export async function getArticlesList(): Promise<{
  status: string;
  data?: Article[];
}> {
  return apiPost("app/articles/list.php", {});
}

export async function getArticleDetail(
  id: string | number,
): Promise<{ status: string; data?: Article }> {
  return apiPost("app/articles/detail.php", { id });
}
