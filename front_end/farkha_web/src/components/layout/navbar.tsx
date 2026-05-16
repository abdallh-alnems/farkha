"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import Image from "next/image";
import { useEffect, useState } from "react";
import {
  BarChart3,
  LogOut,
  Moon,
  Sun,
} from "lucide-react";
import { useTheme } from "next-themes";
import { useAuth } from "@/lib/hooks/use-auth";

const navItems = [
  { href: "/", label: "الأسعار", icon: BarChart3 },
];

export function Navbar() {
  const pathname = usePathname();
  const router = useRouter();
  const { user, isLoggedIn, logout } = useAuth();
  const { theme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  useEffect(() => setMounted(true), []);

  return (
    <header className="sticky top-0 z-50 flex h-14 items-center border-b border-border/50 bg-background/95 px-4 backdrop-blur-sm">
      <Link href="/" className="flex items-center gap-2">
        <Image
          src="/images/logo.png"
          alt="فرخة"
          width={32}
          height={32}
          className="rounded-lg"
        />
        <span className="text-headline-sm text-primary hidden sm:inline">
          فرخة
        </span>
      </Link>

      <nav className="mx-auto hidden lg:flex items-center gap-1">
        {navItems.map((item) => {
          const isActive =
            item.href === "/"
              ? pathname === "/" || pathname.startsWith("/prices")
              : pathname.startsWith(item.href);
          const Icon = item.icon;

          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center gap-2 rounded-xl px-4 py-2 text-label-md transition-colors ${
                isActive
                  ? "bg-primary/10 text-primary"
                  : "text-foreground/50 hover:bg-foreground/[0.04] hover:text-foreground/70"
              }`}
            >
              <Icon className="h-4 w-4" />
              {item.label}
            </Link>
          );
        })}
      </nav>

      <div className="flex items-center gap-2">
        <button
          onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
          className="relative flex h-9 w-9 items-center justify-center rounded-xl text-foreground/50 hover:bg-foreground/[0.04] overflow-hidden"
          aria-label={mounted ? (theme === "dark" ? "تفعيل الوضع النهاري" : "تفعيل الوضع الليلي") : "تبديل المظهر"}
        >
          <span className="relative h-5 w-5">
            <Sun className="absolute inset-0 h-5 w-5 text-amber-500 transition-all duration-500 ease-[cubic-bezier(0.25,1,0.5,1)] dark:rotate-[360deg] dark:scale-0 dark:opacity-0 rotate-0 scale-100 opacity-100" />
            <Moon className="absolute inset-0 h-5 w-5 text-blue-300 transition-all duration-500 ease-[cubic-bezier(0.25,1,0.5,1)] -rotate-90 scale-0 opacity-0 dark:rotate-0 dark:scale-100 dark:opacity-100" />
          </span>
        </button>

        {isLoggedIn && (
          <div className="flex items-center gap-2">
            <span className="text-label-sm text-foreground/60 hidden sm:inline">
              {user?.name}
            </span>
            <button
              onClick={logout}
              className="flex h-9 items-center gap-1.5 rounded-xl px-3 text-label-sm text-foreground/50 hover:bg-destructive/10 hover:text-destructive"
            >
              <LogOut className="h-4 w-4" />
              <span className="hidden sm:inline">خروج</span>
            </button>
          </div>
        )}
      </div>
    </header>
  );
}
