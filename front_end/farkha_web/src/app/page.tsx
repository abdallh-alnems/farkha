export default function HomePage() {
  return (
    <div className="flex min-h-svh flex-col items-center justify-center gap-6 p-6">
      <div className="flex flex-col items-center gap-2 text-center">
        <h1 className="text-display-md text-primary">فرخة</h1>
        <p className="text-body-lg text-muted-foreground">
          إدارة مزارع الدواجن
        </p>
        <p className="text-body-sm text-muted-foreground">
          نسخة الويب — قيد التطوير
        </p>
      </div>
    </div>
  );
}
