import { Bell, Search, LogOut, User } from "lucide-react";
import { useAuth } from "@/lib/auth";

interface HeaderProps {
  title: string;
  subtitle?: string;
}

export function Header({ title, subtitle }: HeaderProps) {
  const { profile } = useAuth();
  
  return (
    <header className="sticky top-0 z-30 bg-white/80 backdrop-blur-md border-b border-slate-200/60 print:static print:bg-transparent print:border-none">
      <div className="flex items-center justify-between px-8 py-4 print:px-0">
        <div>
          <h1 className="text-xl font-bold tracking-tight" style={{ color: "#0F2040" }}>{title}</h1>
          {subtitle && <p className="text-sm mt-0.5" style={{ color: "#636C7A" }}>{subtitle}</p>}
        </div>
        <div className="flex items-center gap-3 print:hidden">
          {/* Search */}
          <div className="hidden md:flex items-center gap-2 rounded-lg px-3 py-2 w-64" style={{ backgroundColor: "#F8F9FB" }}>
            <Search size={16} style={{ color: "#636C7A" }} />
            <input
              type="text"
              placeholder="Search..."
              className="bg-transparent text-sm outline-none w-full placeholder:text-[#636C7A]"
              style={{ color: "#2C2F33" }}
            />
          </div>

          {/* Notifications */}
          <button className="relative p-2 rounded-lg hover:bg-slate-100 transition-colors">
            <Bell size={20} style={{ color: "#636C7A" }} />
            <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full" style={{ backgroundColor: "#D32F2F" }} />
          </button>

          {/* Profile */}
          <div className="flex items-center gap-2 pl-3 border-l" style={{ borderColor: "#E0E2E7" }}>
            <div className="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold" style={{ background: "linear-gradient(135deg, #0F2040, #1E3A66)" }}>
              {profile ? profile.name.split(" ").map((n: string) => n[0]).join("").slice(0, 2) : <User size={16} />}
            </div>
            <div className="hidden lg:block">
              <p className="text-sm font-medium" style={{ color: "#0F2040" }}>{profile?.name || "Admin"}</p>
              <p className="text-[10px] capitalize" style={{ color: "#C5A065" }}>{profile?.role || "Secretary"}</p>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
}
