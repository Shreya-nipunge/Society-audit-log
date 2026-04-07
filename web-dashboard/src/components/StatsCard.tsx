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

/* Corporate FinTech palette mapped to Tailwind utility classes */
const colorMap = {
  indigo: { bg: "bg-[#0F2040]/5",  icon: "text-[#0F2040]", border: "border-[#0F2040]/10" },
  emerald: { bg: "bg-[#2E7D32]/5", icon: "text-[#2E7D32]", border: "border-[#2E7D32]/10" },
  amber:   { bg: "bg-[#C5A065]/10", icon: "text-[#967635]", border: "border-[#C5A065]/20" },
  rose:    { bg: "bg-[#D32F2F]/5",  icon: "text-[#D32F2F]", border: "border-[#D32F2F]/10" },
  blue:    { bg: "bg-[#0288D1]/5",  icon: "text-[#0288D1]", border: "border-[#0288D1]/10" },
  purple:  { bg: "bg-[#1E3A66]/5",  icon: "text-[#1E3A66]", border: "border-[#1E3A66]/10" },
};

export function StatsCard({ title, value, subtitle, icon: Icon, trend, color }: StatsCardProps) {
  const colors = colorMap[color];
  return (
    <div className={cn("bg-white rounded-xl border p-5 hover:shadow-md transition-shadow", colors.border)}>
      <div className="flex items-start justify-between">
        <div>
          <p className="text-sm font-medium" style={{ color: "#636C7A" }}>{title}</p>
          <p className="text-2xl font-bold mt-1" style={{ color: "#0F2040" }}>{value}</p>
          {subtitle && <p className="text-xs mt-1" style={{ color: "#636C7A" }}>{subtitle}</p>}
          {trend && (
            <p className={cn("text-xs font-medium mt-2", trend.positive ? "text-[#2E7D32]" : "text-[#D32F2F]")}>
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
