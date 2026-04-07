"use client";
import { Header } from "@/components/Header";
import { StatsCard } from "@/components/StatsCard";
import { mockExpenses } from "@/lib/mock-data";
import { formatCompact, formatDate, cn } from "@/lib/utils";
import { Wallet, TrendingDown, PieChart as PieIcon, Search, Plus } from "lucide-react";
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip, BarChart, Bar, XAxis, YAxis, CartesianGrid } from "recharts";
import { useState } from "react";

const COLORS = ["#6366f1", "#8b5cf6", "#a855f7", "#ec4899", "#f43f5e", "#f97316", "#eab308"];

export default function ExpensesPage() {
  const [search, setSearch] = useState("");
  const totalExpenses = mockExpenses.reduce((s, e) => s + e.amount, 0);

  const byCategory: Record<string, number> = {};
  mockExpenses.forEach((e) => { byCategory[e.category] = (byCategory[e.category] || 0) + e.amount; });
  const pieData = Object.entries(byCategory).map(([name, value]) => ({ name, value })).sort((a, b) => b.value - a.value);

  const filtered = mockExpenses
    .filter((e) => !search || e.description.toLowerCase().includes(search.toLowerCase()) || e.vendor.toLowerCase().includes(search.toLowerCase()) || e.category.toLowerCase().includes(search.toLowerCase()))
    .sort((a, b) => new Date(b.expenseDate).getTime() - new Date(a.expenseDate).getTime());

  return (
    <>
      <Header title="Expense Ledger" subtitle="Track and analyze society expenditures" />
      <div className="p-8 space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
          <StatsCard title="Total Expenses" value={formatCompact(totalExpenses)} icon={Wallet} color="purple" subtitle={`${mockExpenses.length} entries`} />
          <StatsCard title="Categories" value={`${Object.keys(byCategory).length}`} icon={PieIcon} color="blue" subtitle="Expense types" />
          <StatsCard title="Avg. per Entry" value={formatCompact(totalExpenses / mockExpenses.length)} icon={TrendingDown} color="amber" subtitle="Average expense" />
        </div>

        {/* Charts */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-white rounded-xl border border-slate-200 p-6">
            <h3 className="text-sm font-semibold text-slate-700 mb-4">Category Breakdown</h3>
            <ResponsiveContainer width="100%" height={260}>
              <PieChart>
                <Pie data={pieData} cx="50%" cy="50%" innerRadius={55} outerRadius={95} paddingAngle={3} dataKey="value"
                  label={({ name, percent }: any) => `${(name || "").length > 12 ? (name || "").slice(0, 12) + "…" : name || ""} ${((percent || 0) * 100).toFixed(0)}%`}>
                  {pieData.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                </Pie>
                <Tooltip formatter={(v: any) => [`₹${Number(v).toLocaleString("en-IN")}`, "Amount"]} />
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="bg-white rounded-xl border border-slate-200 p-6">
            <h3 className="text-sm font-semibold text-slate-700 mb-4">Top Expenses by Category</h3>
            <ResponsiveContainer width="100%" height={260}>
              <BarChart data={pieData.slice(0, 5)} layout="vertical" margin={{ left: 20 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                <XAxis type="number" tick={{ fontSize: 11 }} stroke="#94a3b8" tickFormatter={(v) => `₹${(v / 1000).toFixed(0)}K`} />
                <YAxis type="category" dataKey="name" tick={{ fontSize: 11 }} stroke="#94a3b8" width={120} />
                <Tooltip formatter={(v: any) => [`₹${Number(v).toLocaleString("en-IN")}`, "Amount"]} />
                <Bar dataKey="value" fill="#8b5cf6" radius={[0, 4, 4, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Table */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2 bg-white border border-slate-200 rounded-lg px-3 py-2 w-80">
            <Search size={16} className="text-slate-400" />
            <input type="text" placeholder="Search expenses..." value={search} onChange={(e) => setSearch(e.target.value)} className="bg-transparent text-sm outline-none w-full" />
          </div>
          <button className="flex items-center gap-2 bg-indigo-600 text-white px-4 py-2.5 rounded-lg text-sm font-medium hover:bg-indigo-700 transition-colors">
            <Plus size={16} /> Record Expense
          </button>
        </div>

        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <table className="w-full">
            <thead>
              <tr className="bg-slate-50 border-b border-slate-200">
                <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Date</th>
                <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Category</th>
                <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Description</th>
                <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Vendor</th>
                <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Mode</th>
                <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Recorded By</th>
                <th className="text-right text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Amount</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.map((exp) => (
                <tr key={exp.id} className="hover:bg-slate-50/50 transition-colors">
                  <td className="px-6 py-3.5 text-sm text-slate-600">{formatDate(exp.expenseDate)}</td>
                  <td className="px-6 py-3.5"><span className="text-xs font-semibold bg-purple-50 text-purple-700 px-2.5 py-1 rounded-full">{exp.category}</span></td>
                  <td className="px-6 py-3.5 text-sm text-slate-700 max-w-xs truncate">{exp.description}</td>
                  <td className="px-6 py-3.5 text-sm text-slate-600">{exp.vendor}</td>
                  <td className="px-6 py-3.5 text-sm text-slate-500">{exp.paymentMode}</td>
                  <td className="px-6 py-3.5 text-sm text-slate-500">{exp.recordedBy}</td>
                  <td className="px-6 py-3.5 text-right"><span className="text-sm font-bold text-rose-600">−₹{exp.amount.toLocaleString("en-IN")}</span></td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="px-6 py-3 bg-slate-50 border-t border-slate-200 flex justify-between">
            <p className="text-xs text-slate-500">{filtered.length} expenses</p>
            <p className="text-xs font-bold text-rose-600">Total: ₹{filtered.reduce((s, e) => s + e.amount, 0).toLocaleString("en-IN")}</p>
          </div>
        </div>
      </div>
    </>
  );
}
