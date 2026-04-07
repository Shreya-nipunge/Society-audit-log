import { cn } from "@/lib/utils";
import { LucideIcon } from "lucide-react";

interface StatsCardProps {
  title: string;
  value: string;
  subtitle?: string;
  icon: LucideIcon;
  trend?: { value: string; positive: boolean };
  color: "indigo" | "emerald" | "amber" | "rose" | "blue" | "purple";
}

const colorMap = {
  indigo: { bg: "bg-indigo-50", icon: "text-indigo-600", border: "border-indigo-100" },
  emerald: { bg: "bg-emerald-50", icon: "text-emerald-600", border: "border-emerald-100" },
  amber: { bg: "bg-amber-50", icon: "text-amber-600", border: "border-amber-100" },
  rose: { bg: "bg-rose-50", icon: "text-rose-600", border: "border-rose-100" },
  blue: { bg: "bg-blue-50", icon: "text-blue-600", border: "border-blue-100" },
  purple: { bg: "bg-purple-50", icon: "text-purple-600", border: "border-purple-100" },
};

export function StatsCard({ title, value, subtitle, icon: Icon, trend, color }: StatsCardProps) {
  const colors = colorMap[color];
  return (
    <div className={cn("bg-white rounded-xl border p-5 hover:shadow-md transition-shadow", colors.border)}>
      <div className="flex items-start justify-between">
        <div>
          <p className="text-sm font-medium text-slate-500">{title}</p>
          <p className="text-2xl font-bold text-slate-900 mt-1">{value}</p>
          {subtitle && <p className="text-xs text-slate-400 mt-1">{subtitle}</p>}
          {trend && (
            <p className={cn("text-xs font-medium mt-2", trend.positive ? "text-emerald-600" : "text-rose-600")}>
              {trend.positive ? "↑" : "↓"} {trend.value}
            </p>
          )}
        </div>
        <div className={cn("p-3 rounded-xl", colors.bg)}>
          <Icon size={22} className={colors.icon} />
        </div>
      </div>
    </div>
  );
}
