import type { MetadataRoute } from "next";

const BASE_URL = "https://nims-farkha.com";

const tools = [
  "roi",
  "feed-cost-per-bird",
  "feed-cost-per-kilo",
  "adg",
  "fcr",
  "total-farm-weight",
  "feasibility-study",
  "chicken-density",
  "mortality-rate",
  "darkness-levels",
  "fan-operation",
  "bird-production-cost",
  "bird-net-profit",
  "water-consumption",
  "diseases",
  "total-revenue",
  "broiler-requirements",
  "weight-by-age",
  "weather",
  "total-feed-consumption",
  "daily-feed-consumption",
];

export default function sitemap(): MetadataRoute.Sitemap {
  const now = new Date();

  return [
    {
      url: `${BASE_URL}/`,
      lastModified: now,
      changeFrequency: "daily",
      priority: 1.0,
    },
    {
      url: `${BASE_URL}/prices`,
      lastModified: now,
      changeFrequency: "daily",
      priority: 0.95,
    },
    {
      url: `${BASE_URL}/prices/history`,
      lastModified: now,
      changeFrequency: "daily",
      priority: 0.8,
    },
    {
      url: `${BASE_URL}/articles`,
      lastModified: now,
      changeFrequency: "weekly",
      priority: 0.85,
    },
    {
      url: `${BASE_URL}/tools`,
      lastModified: now,
      changeFrequency: "weekly",
      priority: 0.9,
    },
    ...tools.map((slug) => ({
      url: `${BASE_URL}/tools/${slug}`,
      lastModified: now,
      changeFrequency: "monthly" as const,
      priority: 0.7,
    })),
    {
      url: `${BASE_URL}/privacy-policy`,
      lastModified: now,
      changeFrequency: "yearly",
      priority: 0.4,
    },
    {
      url: `${BASE_URL}/delete_account_request`,
      lastModified: now,
      changeFrequency: "yearly",
      priority: 0.4,
    },
  ];
}
