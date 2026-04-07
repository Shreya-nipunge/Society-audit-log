"use client";
import { Header } from "@/components/Header";
import { StatsCard } from "@/components/StatsCard";
import { mockBills, mockUsers } from "@/lib/mock-data";
import { formatCompact, formatDate, cn } from "@/lib/utils";
import { Receipt, CheckCircle, Clock, AlertTriangle, Search, Filter } from "lucide-react";
import { useState } from "react";

const statusColors: Record<string, string> = {
  Paid: "bg-emerald-50 text-emerald-700",
  Pending: "bg-amber-50 text-amber-700",
  Overdue: "bg-rose-50 text-rose-700",
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
          <div className="flex items-center gap-2 bg-white border border-slate-200 rounded-lg px-3 py-2 w-72">
            <Search size={16} className="text-slate-400" />
            <input type="text" placeholder="Search flat or member..." value={search} onChange={(e) => setSearch(e.target.value)} className="bg-transparent text-sm outline-none w-full" />
          </div>
          <div className="flex items-center gap-1 bg-white border border-slate-200 rounded-lg px-2 py-1">
            {["all", "Paid", "Pending", "Overdue"].map((s) => (
              <button key={s} onClick={() => setStatusFilter(s)} className={cn("px-3 py-1.5 rounded-md text-xs font-medium transition-all", statusFilter === s ? "bg-indigo-100 text-indigo-700" : "text-slate-500 hover:bg-slate-50")}>
                {s === "all" ? "All" : s}
              </button>
            ))}
          </div>
        </div>

        {/* Table */}
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <table className="w-full">
            <thead>
              <tr className="bg-slate-50 border-b border-slate-200">
                <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Member</th>
                <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Flat</th>
                <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Period</th>
                <th className="text-right text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Maintenance</th>
                <th className="text-right text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Other</th>
                <th className="text-right text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Total</th>
                <th className="text-right text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Paid</th>
                <th className="text-center text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Status</th>
                <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Due Date</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.map((bill) => {
                const member = mockUsers.find((u) => u.uid === bill.memberId);
                return (
                  <tr key={bill.id} className="hover:bg-slate-50/50 transition-colors">
                    <td className="px-6 py-3.5 text-sm font-medium text-slate-700">{member?.name || "—"}</td>
                    <td className="px-6 py-3.5 text-sm text-slate-600">{bill.flatNumber}</td>
                    <td className="px-6 py-3.5 text-sm text-slate-600">{months[bill.month]} {bill.year}</td>
                    <td className="px-6 py-3.5 text-sm text-slate-600 text-right">₹{bill.maintenanceAmount.toLocaleString("en-IN")}</td>
                    <td className="px-6 py-3.5 text-sm text-slate-600 text-right">₹{bill.otherCharges.toLocaleString("en-IN")}</td>
                    <td className="px-6 py-3.5 text-sm font-semibold text-slate-800 text-right">₹{bill.totalAmount.toLocaleString("en-IN")}</td>
                    <td className="px-6 py-3.5 text-sm font-medium text-right">
                      <span className={bill.paidAmount > 0 ? "text-emerald-600" : "text-slate-400"}>₹{bill.paidAmount.toLocaleString("en-IN")}</span>
                    </td>
                    <td className="px-6 py-3.5 text-center">
                      <span className={cn("inline-flex px-2.5 py-1 rounded-full text-xs font-semibold", statusColors[bill.status] || "bg-slate-100 text-slate-600")}>{bill.status}</span>
                    </td>
                    <td className="px-6 py-3.5 text-sm text-slate-500">{formatDate(bill.dueDate)}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
          <div className="px-6 py-3 bg-slate-50 border-t border-slate-200 flex justify-between">
            <p className="text-xs text-slate-500">Showing {filtered.length} bills</p>
            <p className="text-xs font-medium text-slate-600">Total: ₹{filtered.reduce((s, b) => s + b.totalAmount, 0).toLocaleString("en-IN")}</p>
          </div>
        </div>
      </div>
    </>
  );
}
