import axios, { type AxiosInstance, type AxiosRequestConfig } from "axios";

const API_HOST =
  process.env.NEXT_PUBLIC_API_HOST ??
  "https://api.nims-farkha.com/backend_farkha";

const SECURITY_USER = process.env.SECURITY_USER ?? "";
const SECURITY_KEY = process.env.SECURITY_KEY ?? "";

const serverClient: AxiosInstance = axios.create({
  baseURL: API_HOST,
  headers: {
    Authorization: `Basic ${btoa(`${SECURITY_USER}:${SECURITY_KEY}`)}`,
    "Content-Type": "application/json",
  },
});

const browserClient: AxiosInstance = axios.create({
  baseURL: "/api",
  headers: {
    "Content-Type": "application/json",
  },
});

browserClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response) {
      return error.response;
    }
    return Promise.reject(error);
  },
);

serverClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response) {
      return error.response;
    }
    return Promise.reject(error);
  },
);

export const apiClient: AxiosInstance =
  typeof window !== "undefined" ? browserClient : serverClient;

export async function apiGet<T>(
  endpoint: string,
  params?: Record<string, unknown>,
) {
  const res = await apiClient.get<T>(endpoint, { params });
  return res.data;
}

export async function apiPost<T>(
  endpoint: string,
  data?: Record<string, unknown>,
  config?: AxiosRequestConfig,
) {
  const res = await apiClient.post<T>(endpoint, data, config);
  return res.data;
}

export { API_HOST };
