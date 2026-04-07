"use client";
import { Header } from "@/components/Header";
import { mockBills, mockTransactions, mockExpenses, mockUsers } from "@/lib/mock-data";
import { formatCompact, cn } from "@/lib/utils";
import { Download, FileText, TrendingUp, TrendingDown, Scale, Printer } from "lucide-react";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from "recharts";

export default function ReportsPage() {
  const totalCollected = mockTransactions.reduce((s, t) => s + t.amount, 0);
  const totalBilled = mockBills.reduce((s, b) => s + b.totalAmount, 0);
  const totalPending = totalBilled - totalCollected;
  const totalExpenses = mockExpenses.reduce((s, e) => s + e.amount, 0);
  const netBalance = totalCollected - totalExpenses;

  // Fund balances (simplified)
  const fundBalances = [
    { fund: "Maintenance Fund", balance: totalCollected * 0.70 },
    { fund: "Sinking Fund", balance: totalCollected * 0.20 },
    { fund: "Repairs Fund", balance: totalCollected * 0.10 },
  ];

  // Member-wise summary
  const memberSummary = mockUsers
    .filter((u) => u.role === "member")
    .map((u) => {
      const billed = mockBills.filter((b) => b.memberId === u.uid).reduce((s, b) => s + b.totalAmount, 0);
      const paid = mockTransactions.filter((t) => t.memberId === u.uid).reduce((s, t) => s + t.amount, 0);
      return { name: u.name, flat: u.flatNumber, billed, paid, pending: billed - paid };
    });

  const incomeVsExpense = [
    { label: "Income (Collected)", amount: totalCollected, color: "#10b981" },
    { label: "Expenses", amount: totalExpenses, color: "#8b5cf6" },
    { label: "Net Balance", amount: netBalance, color: netBalance >= 0 ? "#10b981" : "#ef4444" },
  ];

  return (
    <>
      <Header title="Financial Reports" subtitle="Balance sheet, income vs expenditure, and member summaries" />
      <div className="p-8 space-y-8 print:p-4">
        {/* Action Buttons */}
        <div className="flex gap-3 print:hidden">
          <button onClick={() => window.print()} className="flex items-center gap-2 bg-white border border-slate-200 text-slate-600 px-4 py-2.5 rounded-lg text-sm font-medium hover:bg-slate-50">
            <Printer size={16} /> Print Report
          </button>
          <button className="flex items-center gap-2 bg-indigo-600 text-white px-4 py-2.5 rounded-lg text-sm font-medium hover:bg-indigo-700">
            <Download size={16} /> Export PDF
          </button>
        </div>

        {/* Balance Sheet */}
        <div className="bg-white rounded-xl border border-slate-200 p-6">
          <div className="flex items-center gap-2 mb-6">
            <Scale size={20} className="text-indigo-600" />
            <h2 className="text-lg font-bold text-slate-800">Balance Sheet</h2>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {incomeVsExpense.map((item) => (
              <div key={item.label} className="p-5 rounded-xl border border-slate-100 bg-slate-50/50">
                <p className="text-sm text-slate-500 mb-1">{item.label}</p>
                <p className="text-2xl font-bold" style={{ color: item.color }}>{formatCompact(item.amount)}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Fund Balances */}
        <div className="bg-white rounded-xl border border-slate-200 p-6">
          <h2 className="text-lg font-bold text-slate-800 mb-4">Fund Balances</h2>
          <div className="space-y-4">
            {fundBalances.map((f) => {
              const pct = totalCollected > 0 ? (f.balance / totalCollected) * 100 : 0;
              return (
                <div key={f.fund} className="flex items-center gap-4">
                  <div className="w-40 text-sm font-medium text-slate-700">{f.fund}</div>
                  <div className="flex-1 h-3 bg-slate-100 rounded-full overflow-hidden">
                    <div className="h-full bg-indigo-500 rounded-full transition-all" style={{ width: `${pct}%` }} />
                  </div>
                  <div className="w-24 text-right text-sm font-bold text-slate-800">{formatCompact(f.balance)}</div>
                  <div className="w-12 text-right text-xs text-slate-400">{pct.toFixed(0)}%</div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Revenue vs Expenses Chart */}
        <div className="bg-white rounded-xl border border-slate-200 p-6">
          <h2 className="text-lg font-bold text-slate-800 mb-4">Income vs Expenditure</h2>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={[{ name: "Overview", income: totalCollected, expenses: totalExpenses }]} barGap={20}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
              <XAxis dataKey="name" tick={{ fontSize: 12 }} stroke="#94a3b8" />
              <YAxis tick={{ fontSize: 12 }} stroke="#94a3b8" tickFormatter={(v) => `₹${(v / 1000).toFixed(0)}K`} />
              <Tooltip formatter={(v: any) => [`₹${Number(v).toLocaleString("en-IN")}`, ""]} />
              <Legend />
              <Bar dataKey="income" name="Total Income" fill="#10b981" radius={[6, 6, 0, 0]} barSize={80} />
              <Bar dataKey="expenses" name="Total Expenses" fill="#8b5cf6" radius={[6, 6, 0, 0]} barSize={80} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Member-wise Summary */}
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <div className="px-6 py-4 border-b border-slate-200">
            <h2 className="text-lg font-bold text-slate-800">Member-wise Payment Summary</h2>
          </div>
          <table className="w-full">
            <thead>
              <tr className="bg-slate-50 border-b border-slate-200">
                <th className="text-left text-xs font-semibold text-slate-500 uppercase px-6 py-3">Member</th>
                <th className="text-left text-xs font-semibold text-slate-500 uppercase px-6 py-3">Flat</th>
                <th className="text-right text-xs font-semibold text-slate-500 uppercase px-6 py-3">Billed</th>
                <th className="text-right text-xs font-semibold text-slate-500 uppercase px-6 py-3">Paid</th>
                <th className="text-right text-xs font-semibold text-slate-500 uppercase px-6 py-3">Pending</th>
                <th className="text-center text-xs font-semibold text-slate-500 uppercase px-6 py-3">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {memberSummary.map((m) => (
                <tr key={m.flat} className="hover:bg-slate-50/50">
                  <td className="px-6 py-3 text-sm font-medium text-slate-700">{m.name}</td>
                  <td className="px-6 py-3 text-sm text-slate-600">{m.flat}</td>
                  <td className="px-6 py-3 text-sm text-slate-600 text-right">₹{m.billed.toLocaleString("en-IN")}</td>
                  <td className="px-6 py-3 text-sm text-emerald-600 font-medium text-right">₹{m.paid.toLocaleString("en-IN")}</td>
                  <td className="px-6 py-3 text-sm font-medium text-right">
                    <span className={m.pending > 0 ? "text-rose-600" : "text-emerald-600"}>₹{m.pending.toLocaleString("en-IN")}</span>
                  </td>
                  <td className="px-6 py-3 text-center">
                    <span className={cn("px-2.5 py-1 rounded-full text-xs font-semibold", m.pending > 0 ? "bg-amber-50 text-amber-700" : "bg-emerald-50 text-emerald-700")}>
                      {m.pending > 0 ? "Pending" : "Clear"}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
}
