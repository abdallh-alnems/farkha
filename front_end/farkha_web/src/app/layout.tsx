import type { Metadata, Viewport } from "next";
import { Cairo } from "next/font/google";
import { Toaster } from "@/components/ui/sonner";
import { ThemeProvider } from "@/lib/providers/theme-provider";
import { QueryProvider } from "@/lib/providers/query-provider";
import { PwaProvider } from "@/lib/providers/pwa-provider";
import { AppShell } from "@/components/layout/app-shell";
import "./globals.css";

const cairo = Cairo({
  subsets: ["arabic", "latin"],
  weight: ["200", "300", "400", "600", "700", "900"],
  variable: "--font-cairo",
  display: "swap",
});

export const viewport: Viewport = {
  themeColor: [
    { media: "(prefers-color-scheme: light)", color: "#4E7A3E" },
    { media: "(prefers-color-scheme: dark)", color: "#8FBC8F" },
  ],
  width: "device-width",
  initialScale: 1,
  maximumScale: 5,
};

export const metadata: Metadata = {
  title: {
    default: "فرخة — أسعار الدواجن والكتاكيت والأعلاف في مصر",
    template: "%s | فرخة",
  },
  description:
    "تابع أسعار الدواجن والكتاكيت والبيض والأعلاف لحظياً في مصر. أدوات حاسبات مزارع الدواجن، إدارة دورات التسمين، ومتابعة التكاليف والأرباح.",
  keywords: [
    "أسعار الدواجن",
    "أسعار الكتاكيت",
    "أسعار البيض",
    "أسعار الأعلاف",
    "أسعار البط",
    "إدارة مزارع الدواجن",
    "دورات التسمين",
    "حاسبة تكلفة التسمين",
    "حاسبة أعلاف",
    "أسعار الفراخ اليوم",
    "بادي نامي ناهي",
    "كتاكيت أبيض",
    "كتاكيت ساسو",
    "كتاكيت بلدي",
    "مزارع دواجن مصر",
    "بورصة الدواجن",
    "اسعار الفراخ البيضا",
    "اسعار الفراخ البيضاء",
    "اسعار الكتكوت الابيض",
  ],
  robots: {
    index: true,
    follow: true,
  },
  manifest: "/manifest.json",
  appleWebApp: {
    capable: true,
    statusBarStyle: "default",
    title: "فرخة",
  },
  twitter: {
    card: "summary",
    title: "فرخة — أسعار الدواجن والكتاكيت والأعلاف في مصر",
    description:
      "تابع أسعار الدواجن والكتاكيت والبيض والأعلاف لحظياً. أدوات حاسبات مزارع الدواجن وإدارة دورات التسمين.",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="ar"
      dir="rtl"
      className={`${cairo.variable} h-full antialiased`}
      suppressHydrationWarning
    >
      <body className="min-h-full flex flex-col font-cairo" suppressHydrationWarning>
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          <QueryProvider>
            <PwaProvider>
              <AppShell>{children}</AppShell>
            </PwaProvider>
            <Toaster
              position="bottom-center"
              dir="rtl"
              richColors
              closeButton
            />
          </QueryProvider>
        </ThemeProvider>
        {process.env.NEXT_PUBLIC_ADSENSE_CLIENT && (
          <script
            async
            src={`https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${process.env.NEXT_PUBLIC_ADSENSE_CLIENT}`}
            crossOrigin="anonymous"
          />
        )}
      </body>
    </html>
  );
}
