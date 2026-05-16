"use client";

import { useState } from "react";
import { ToolPageScaffold } from "@/components/tools/tool-page-scaffold";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { CloudSun, Thermometer, Wind, Droplets } from "lucide-react";

interface WeatherData {
  location: string;
  temp: number;
  feelsLike: number;
  humidity: number;
  wind: number;
  condition: string;
  forecast: { date: string; maxTemp: number; minTemp: number; condition: string }[];
}

export default function WeatherPage() {
  const [location, setLocation] = useState("");
  const [weather, setWeather] = useState<WeatherData | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const fetchWeather = async () => {
    if (!location.trim()) return;
    setLoading(true);
    setError("");
    try {
      const apiKey = process.env.NEXT_PUBLIC_WEATHER_API;
      const res = await fetch(
        `https://api.weatherapi.com/v1/forecast.json?key=${apiKey}&q=${encodeURIComponent(location)}&days=7&aqi=no`,
      );
      const data = await res.json();
      if (data.error) {
        setError(data.error.message ?? "فشل تحميل الطقس");
        setWeather(null);
        return;
      }
      setWeather({
        location: `${data.location.name}, ${data.location.country}`,
        temp: data.current.temp_c,
        feelsLike: data.current.feelslike_c,
        humidity: data.current.humidity,
        wind: data.current.wind_kph,
        condition: data.current.condition.text,
        forecast: data.forecast.forecastday.map((d: Record<string, unknown>) => ({
          date: d.date as string,
          maxTemp: (d.day as Record<string, number>).maxtemp_c,
          minTemp: (d.day as Record<string, number>).mintemp_c,
          condition: ((d.day as Record<string, Record<string, string>>).condition).text,
        })),
      });
    } catch {
      setError("فشل الاتصال");
    } finally {
      setLoading(false);
    }
  };

  return (
    <ToolPageScaffold title="الطقس">
      <div className="flex gap-2">
        <Input
          value={location}
          onChange={(e) => setLocation(e.target.value)}
          placeholder="ابحث عن مدينة..."
          className="h-11 rounded-xl"
          onKeyDown={(e) => e.key === "Enter" && fetchWeather()}
        />
        <Button onClick={fetchWeather} className="h-11 rounded-xl px-6" disabled={loading}>
          بحث
        </Button>
      </div>

      {error && <p className="mt-3 text-body-sm text-destructive">{error}</p>}

      {loading && <Skeleton className="mt-4 h-40 w-full rounded-2xl" />}

      {weather && (
        <div className="mt-4 space-y-4">
          <Card className="rounded-2xl border border-primary/20 bg-gradient-to-bl from-primary/10 to-terracotta/5 p-5">
            <div className="flex items-center gap-3 mb-4">
              <CloudSun className="h-8 w-8 text-primary" />
              <div>
                <p className="text-headline-sm text-primary">{weather.temp}°C</p>
                <p className="text-body-sm text-foreground/60">{weather.location}</p>
              </div>
            </div>
            <p className="text-body-md text-foreground/70 mb-3">{weather.condition}</p>
            <div className="flex gap-4">
              <div className="flex items-center gap-1.5 text-body-sm text-foreground/60">
                <Thermometer className="h-4 w-4" /> {weather.feelsLike}°C
              </div>
              <div className="flex items-center gap-1.5 text-body-sm text-foreground/60">
                <Droplets className="h-4 w-4" /> {weather.humidity}%
              </div>
              <div className="flex items-center gap-1.5 text-body-sm text-foreground/60">
                <Wind className="h-4 w-4" /> {weather.wind} km/h
              </div>
            </div>
          </Card>

          <div>
            <h3 className="mb-2 text-title-md text-foreground">توقعات 7 أيام</h3>
            <div className="space-y-2">
              {weather.forecast.map((day, i) => (
                <div key={i} className="flex items-center justify-between rounded-xl border border-border/40 bg-card px-4 py-2.5">
                  <span className="text-body-md text-foreground">{day.date}</span>
                  <span className="text-body-sm text-foreground/60">{day.condition}</span>
                  <span className="text-body-md">
                    <span className="font-semibold text-primary">{day.maxTemp}°</span>
                    <span className="text-foreground/40"> / {day.minTemp}°</span>
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}
    </ToolPageScaffold>
  );
}
