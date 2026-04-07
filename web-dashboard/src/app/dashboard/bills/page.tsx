"use client";
import { Header } from "@/components/Header";
import { StatsCard } from "@/components/StatsCard";
import { mockBills, mockUsers } from "@/lib/mock-data";
import { formatCompact, formatDate, cn } from "@/lib/utils";
import { Receipt, CheckCircle, Clock, AlertTriangle, Search, Filter } from "lucide-react";
import { useState } from "react";

const statusColors: Record<string, string> = {
  Paid: "bg-[#2E7D32]/10 text-[#2E7D32]",
  Pending: "bg-[#C5A065]/10 text-[#967635]",
  Overdue: "bg-[#D32F2F]/10 text-[#D32F2F]",
};

const months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

export default function BillsPage() {
  const [statusFilter, setStatusFilter] = useState("all");
  const [search, setSearch] = useState("");

  const paidCount = mockBills.filter((b) => b.status === "Paid").length;
  const pendingCount = mockBills.filter((b) => b.status === "Pending").length;
  const overdueCount = mockBills.filter((b) => b.status === "Overdue").length;
  const totalBilled = mockBills.reduce((s, b) => s + b.totalAmount, 0);
  const totalCollected = mockBills.reduce((s, b) => s + b.paidAmount, 0);

  const filtered = mockBills.filter((b) => {
    const member = mockUsers.find((u) => u.uid === b.memberId);
    const matchSearch = !search || b.flatNumber.toLowerCase().includes(search.toLowerCase()) ||
      (member?.name || "").toLowerCase().includes(search.toLowerCase());
    const matchStatus = statusFilter === "all" || b.status === statusFilter;
    return matchSearch && matchStatus;
  });

  return (
    <>
      <Header title="Bills & Dues" subtitle="Maintenance billing and payment tracking" />
      <div className="p-8 space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-5">
          <StatsCard title="Total Billed" value={formatCompact(totalBilled)} icon={Receipt} color="indigo" subtitle={`${mockBills.length} bills generated`} />
          <StatsCard title="Collected" value={formatCompact(totalCollected)} icon={CheckCircle} color="emerald" subtitle={`${paidCount} paid`} />
          <StatsCard title="Pending" value={formatCompact(totalBilled - totalCollected)} icon={Clock} color="amber" subtitle={`${pendingCount} pending`} />
          <StatsCard title="Overdue" value={`${overdueCount}`} icon={AlertTriangle} color="rose" subtitle="Needs follow-up" />
        </div>

        {/* Toolbar */}
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-2 bg-white rounded-lg px-3 py-2 w-72" style={{ border: "1px solid #E0E2E7" }}>
            <Search size={16} style={{ color: "#636C7A" }} />
            <input type="text" placeholder="Search flat or member..." value={search} onChange={(e) => setSearch(e.target.value)} className="bg-transparent text-sm outline-none w-full placeholder:text-[#636C7A]" style={{ color: "#2C2F33" }} />
          </div>
          <div className="flex items-center gap-1 bg-white rounded-lg px-2 py-1" style={{ border: "1px solid #E0E2E7" }}>
            {["all", "Paid", "Pending", "Overdue"].map((s) => (
              <button key={s} onClick={() => setStatusFilter(s)} className="px-3 py-1.5 rounded-md text-xs font-medium transition-all" style={statusFilter === s ? { backgroundColor: "#0F2040", color: "#FFFFFF" } : { color: "#636C7A" }}>
                {s === "all" ? "All" : s}
              </button>
            ))}
          </div>
        </div>

        {/* Table */}
        <div className="bg-white rounded-xl overflow-hidden" style={{ border: "1px solid #E0E2E7" }}>
          <table className="w-full">
            <thead>
              <tr style={{ backgroundColor: "#F8F9FB", borderBottom: "1px solid #E0E2E7" }}>
                <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Member</th>
                <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Flat</th>
                <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Period</th>
                <th className="text-right text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Maintenance</th>
                <th className="text-right text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Other</th>
                <th className="text-right text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Total</th>
                <th className="text-right text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Paid</th>
                <th className="text-center text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Status</th>
                <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Due Date</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.map((bill) => {
                const member = mockUsers.find((u) => u.uid === bill.memberId);
                return (
                  <tr key={bill.id} className="hover:bg-slate-50/50 transition-colors">
                    <td className="px-6 py-3.5 text-sm font-medium" style={{ color: "#2C2F33" }}>{member?.name || "—"}</td>
                    <td className="px-6 py-3.5 text-sm" style={{ color: "#636C7A" }}>{bill.flatNumber}</td>
                    <td className="px-6 py-3.5 text-sm" style={{ color: "#636C7A" }}>{months[bill.month]} {bill.year}</td>
                    <td className="px-6 py-3.5 text-sm text-right" style={{ color: "#636C7A" }}>₹{bill.maintenanceAmount.toLocaleString("en-IN")}</td>
                    <td className="px-6 py-3.5 text-sm text-right" style={{ color: "#636C7A" }}>₹{bill.otherCharges.toLocaleString("en-IN")}</td>
                    <td className="px-6 py-3.5 text-sm font-semibold text-right" style={{ color: "#0F2040" }}>₹{bill.totalAmount.toLocaleString("en-IN")}</td>
                    <td className="px-6 py-3.5 text-sm font-medium text-right">
                      <span style={{ color: bill.paidAmount > 0 ? "#2E7D32" : "#636C7A" }}>₹{bill.paidAmount.toLocaleString("en-IN")}</span>
                    </td>
                    <td className="px-6 py-3.5 text-center">
                      <span className={cn("inline-flex px-2.5 py-1 rounded-full text-xs font-semibold", statusColors[bill.status] || "")} style={!statusColors[bill.status] ? { backgroundColor: "#F8F9FB", color: "#636C7A" } : undefined}>{bill.status}</span>
                    </td>
                    <td className="px-6 py-3.5 text-sm" style={{ color: "#636C7A" }}>{formatDate(bill.dueDate)}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
          <div className="px-6 py-3 flex justify-between" style={{ backgroundColor: "#F8F9FB", borderTop: "1px solid #E0E2E7" }}>
            <p className="text-xs" style={{ color: "#636C7A" }}>Showing {filtered.length} bills</p>
            <p className="text-xs font-medium" style={{ color: "#2C2F33" }}>Total: ₹{filtered.reduce((s, b) => s + b.totalAmount, 0).toLocaleString("en-IN")}</p>
          </div>
        </div>
      </div>
    </>
  );
}
