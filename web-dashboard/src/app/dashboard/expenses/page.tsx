"use client";
import { Header } from "@/components/Header";
import { StatsCard } from "@/components/StatsCard";
import { mockExpenses } from "@/lib/mock-data";
import { formatCompact, formatDate, cn } from "@/lib/utils";
import { Wallet, TrendingDown, PieChart as PieIcon, Search, Plus } from "lucide-react";
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip, BarChart, Bar, XAxis, YAxis, CartesianGrid } from "recharts";
import { useState } from "react";
import { ExpenseModal } from "@/components/ExpenseModal";

const COLORS = ["#0F2040", "#1E3A66", "#C5A065", "#E5C48A", "#967635", "#0288D1", "#2E7D32"];

export default function ExpensesPage() {
  const [search, setSearch] = useState("");
  const [expenses, setExpenses] = useState(mockExpenses);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const totalExpenses = expenses.reduce((s, e) => s + e.amount, 0);

  const byCategory: Record<string, number> = {};
  expenses.forEach((e) => { byCategory[e.category] = (byCategory[e.category] || 0) + e.amount; });
  const pieData = Object.entries(byCategory).map(([name, value]) => ({ name, value })).sort((a, b) => b.value - a.value);

  const filtered = expenses
    .filter((e) => !search || e.description.toLowerCase().includes(search.toLowerCase()) || e.vendor.toLowerCase().includes(search.toLowerCase()) || e.category.toLowerCase().includes(search.toLowerCase()))
    .sort((a, b) => new Date(b.expenseDate).getTime() - new Date(a.expenseDate).getTime());

  const handleAddExpense = async (expense: any) => {
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 500));
    setExpenses(prev => [expense, ...prev]);
  };

  return (
    <>
      <Header title="Expense Ledger" subtitle="Track and analyze society expenditures" />
      <div className="p-8 space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
          <StatsCard title="Total Expenses" value={formatCompact(totalExpenses)} icon={Wallet} color="purple" subtitle={`${expenses.length} entries`} />
          <StatsCard title="Categories" value={`${Object.keys(byCategory).length}`} icon={PieIcon} color="blue" subtitle="Expense types" />
          <StatsCard title="Avg. per Entry" value={formatCompact(totalExpenses / (expenses.length || 1))} icon={TrendingDown} color="amber" subtitle="Average expense" />
        </div>

        {/* Charts */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-white rounded-xl border p-6" style={{ borderColor: "#E0E2E7" }}>
            <h3 className="text-sm font-semibold mb-4" style={{ color: "#0F2040" }}>Category Breakdown</h3>
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
          <div className="bg-white rounded-xl border p-6" style={{ borderColor: "#E0E2E7" }}>
            <h3 className="text-sm font-semibold mb-4" style={{ color: "#0F2040" }}>Top Expenses by Category</h3>
            <ResponsiveContainer width="100%" height={260}>
              <BarChart data={pieData.slice(0, 5)} layout="vertical" margin={{ left: 20 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E0E2E7" />
                <XAxis type="number" tick={{ fontSize: 11 }} stroke="#636C7A" tickFormatter={(v) => `₹${(v / 1000).toFixed(0)}K`} />
                <YAxis type="category" dataKey="name" tick={{ fontSize: 11 }} stroke="#636C7A" width={120} />
                <Tooltip formatter={(v: any) => [`₹${Number(v).toLocaleString("en-IN")}`, "Amount"]} />
                <Bar dataKey="value" fill="#C5A065" radius={[0, 4, 4, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Table */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2 bg-white rounded-lg px-3 py-2 w-80" style={{ border: "1px solid #E0E2E7" }}>
            <Search size={16} style={{ color: "#636C7A" }} />
            <input type="text" placeholder="Search expenses..." value={search} onChange={(e) => setSearch(e.target.value)} className="bg-transparent text-sm outline-none w-full placeholder:text-[#636C7A]" style={{ color: "#2C2F33" }} />
          </div>
          <button onClick={() => setIsModalOpen(true)} className="flex items-center gap-2 text-white px-4 py-2.5 rounded-lg text-sm font-medium transition-colors" style={{ backgroundColor: "#0F2040" }} onMouseOver={(e) => (e.currentTarget.style.backgroundColor = "#1E3A66")} onMouseOut={(e) => (e.currentTarget.style.backgroundColor = "#0F2040")}>
            <Plus size={16} /> Record Expense
          </button>
        </div>

        <div className="bg-white rounded-xl overflow-hidden" style={{ border: "1px solid #E0E2E7" }}>
          <table className="w-full">
            <thead>
              <tr style={{ backgroundColor: "#F8F9FB", borderBottom: "1px solid #E0E2E7" }}>
                <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Date</th>
                <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Category</th>
                <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Description</th>
                <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Vendor</th>
                <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Mode</th>
                <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Recorded By</th>
                <th className="text-right text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Amount</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.map((exp) => (
                <tr key={exp.id} className="hover:bg-slate-50/50 transition-colors">
                  <td className="px-6 py-3.5 text-sm" style={{ color: "#636C7A" }}>{formatDate(exp.expenseDate)}</td>
                  <td className="px-6 py-3.5"><span className="text-xs font-semibold px-2.5 py-1 rounded-full" style={{ backgroundColor: "rgba(197,160,101,0.1)", color: "#967635" }}>{exp.category}</span></td>
                  <td className="px-6 py-3.5 text-sm max-w-xs truncate" style={{ color: "#2C2F33" }}>{exp.description}</td>
                  <td className="px-6 py-3.5 text-sm" style={{ color: "#636C7A" }}>{exp.vendor}</td>
                  <td className="px-6 py-3.5 text-sm" style={{ color: "#636C7A" }}>{exp.paymentMode}</td>
                  <td className="px-6 py-3.5 text-sm" style={{ color: "#636C7A" }}>{exp.recordedBy}</td>
                  <td className="px-6 py-3.5 text-right"><span className="text-sm font-bold" style={{ color: "#D32F2F" }}>−₹{exp.amount.toLocaleString("en-IN")}</span></td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="px-6 py-3 flex justify-between" style={{ backgroundColor: "#F8F9FB", borderTop: "1px solid #E0E2E7" }}>
            <p className="text-xs" style={{ color: "#636C7A" }}>{filtered.length} expenses</p>
            <p className="text-xs font-bold" style={{ color: "#D32F2F" }}>Total: ₹{filtered.reduce((s, e) => s + e.amount, 0).toLocaleString("en-IN")}</p>
          </div>
        </div>
      </div>
      <ExpenseModal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} onAdd={handleAddExpense} />
    </>
  );
}
