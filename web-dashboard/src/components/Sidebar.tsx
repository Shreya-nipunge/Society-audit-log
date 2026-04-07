"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";
import {
  LayoutDashboard,
  Users,
  Receipt,
  CreditCard,
  Wallet,
  FileText,
  ClipboardList,
  Bell,
  FolderOpen,
  ChevronLeft,
  ChevronRight,
  Building2,
} from "lucide-react";
import { useState } from "react";

const navItems = [
  { label: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
  { label: "Members", href: "/dashboard/members", icon: Users },
  { label: "Bills & Dues", href: "/dashboard/bills", icon: Receipt },
  { label: "Transactions", href: "/dashboard/transactions", icon: CreditCard },
  { label: "Expenses", href: "/dashboard/expenses", icon: Wallet },
  { label: "Reports", href: "/dashboard/reports", icon: FileText },
  { label: "Audit Logs", href: "/dashboard/audit-logs", icon: ClipboardList },
  { label: "Notices", href: "/dashboard/notices", icon: Bell },
  { label: "Documents", href: "/dashboard/documents", icon: FolderOpen },
];

export function Sidebar() {
  const pathname = usePathname();
  const [collapsed, setCollapsed] = useState(false);

  return (
    <aside
      className={cn(
        "fixed left-0 top-0 z-40 h-screen text-white transition-all duration-300 flex flex-col",
        collapsed ? "w-[72px]" : "w-64"
      )}
      style={{ background: "linear-gradient(180deg, #0F2040 0%, #071228 100%)" }}
    >
      {/* Brand */}
      <div className="flex items-center gap-3 px-5 py-6 border-b border-white/10">
        <div className="flex-shrink-0 w-9 h-9 rounded-lg flex items-center justify-center" style={{ background: "linear-gradient(135deg, #C5A065, #E5C48A)" }}>
          <Building2 size={20} className="text-[#0F2040]" />
        </div>
        {!collapsed && (
          <div className="overflow-hidden">
            <h1 className="text-sm font-bold tracking-tight truncate">Society Audit</h1>
            <p className="text-[10px] truncate" style={{ color: "#C5A065" }}>Shivkrupasagar CHS Ltd.</p>
          </div>
        )}
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
        {navItems.map((item) => {
          const isActive = pathname === item.href || (item.href !== "/dashboard" && pathname.startsWith(item.href));
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-200 group",
                isActive
                  ? "text-white border"
                  : "text-slate-400 hover:text-white hover:bg-white/5"
              )}
              style={isActive ? { backgroundColor: "rgba(197, 160, 101, 0.15)", borderColor: "rgba(197, 160, 101, 0.35)" } : undefined}
            >
              <item.icon
                size={20}
                className={cn(
                  "flex-shrink-0 transition-colors",
                  isActive ? "" : "text-slate-500 group-hover:text-slate-300"
                )}
                style={isActive ? { color: "#C5A065" } : undefined}
              />
              {!collapsed && <span className="truncate">{item.label}</span>}
            </Link>
          );
        })}
      </nav>

      {/* Collapse Button */}
      <div className="p-3 border-t border-white/10">
        <button
          onClick={() => setCollapsed(!collapsed)}
          className="w-full flex items-center justify-center gap-2 px-3 py-2 rounded-lg text-xs text-slate-400 hover:text-white hover:bg-white/5 transition-colors"
        >
          {collapsed ? <ChevronRight size={16} /> : <><ChevronLeft size={16} /><span>Collapse</span></>}
        </button>
      </div>
    </aside>
  );
}
