import type { MetadataRoute } from "next";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: "*",
        allow: "/",
        disallow: ["/api/", "/login", "/register", "/forgot-password"],
      },
    ],
    sitemap: "https://nims-farkha.com/sitemap.xml",
    host: "https://nims-farkha.com",
  };
}
