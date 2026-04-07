"use client";
import { Header } from "@/components/Header";
import { StatsCard } from "@/components/StatsCard";
import { mockUsers, mockBills, mockTransactions, mockExpenses, mockAuditLogs } from "@/lib/mock-data";
import { formatCompact, formatDate } from "@/lib/utils";
import { IndianRupee, Users, AlertTriangle, TrendingUp, Activity, ArrowDownRight, ArrowUpRight, Clock } from "lucide-react";
import { PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from "recharts";

const CHART_COLORS = ["#6366f1", "#8b5cf6", "#a855f7", "#ec4899", "#f43f5e", "#f97316", "#eab308"];

export default function DashboardPage() {
  const totalMembers = mockUsers.filter((u) => u.role === "member").length;
  const totalCollected = mockTransactions.reduce((sum, t) => sum + t.amount, 0);
  const totalBilled = mockBills.reduce((sum, b) => sum + b.totalAmount, 0);
  const totalPending = totalBilled - totalCollected;
  const totalExpenses = mockExpenses.reduce((sum, e) => sum + e.amount, 0);
  const collectionRate = totalBilled > 0 ? ((totalCollected / totalBilled) * 100).toFixed(1) : "0";

  // Expense by category for pie chart
  const expenseByCategory: Record<string, number> = {};
  mockExpenses.forEach((e) => {
    expenseByCategory[e.category] = (expenseByCategory[e.category] || 0) + e.amount;
  });
  const pieData = Object.entries(expenseByCategory).map(([name, value]) => ({ name, value }));

  // Monthly revenue for bar chart
  const monthlyData = [
    { month: "Jan", collected: 18000, expenses: 35500 },
    { month: "Feb", collected: 13500, expenses: 39000 },
    { month: "Mar", collected: 0, expenses: 0 },
  ];

  // Recent audit logs
  const recentLogs = [...mockAuditLogs].sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()).slice(0, 6);

  // Bills status
  const paidBills = mockBills.filter((b) => b.status === "Paid").length;
  const pendingBills = mockBills.filter((b) => b.status === "Pending").length;
  const overdueBills = mockBills.filter((b) => b.status === "Overdue").length;

  return (
    <>
      <Header title="Dashboard" subtitle="Real-time overview of society operations" />
      <div className="p-8 space-y-8">
        {/* KPI Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
          <StatsCard
            title="Total Collected"
            value={formatCompact(totalCollected)}
            icon={ArrowDownRight}
            color="emerald"
            subtitle={`${paidBills} bills paid`}
            trend={{ value: "vs last month", positive: true }}
          />
          <StatsCard
            title="Total Pending"
            value={formatCompact(totalPending)}
            icon={AlertTriangle}
            color="rose"
            subtitle={`${pendingBills} pending, ${overdueBills} overdue`}
          />
          <StatsCard
            title="Total Expenses"
            value={formatCompact(totalExpenses)}
            icon={ArrowUpRight}
            color="purple"
            subtitle={`${mockExpenses.length} expenses recorded`}
          />
          <StatsCard
            title="Collection Rate"
            value={`${collectionRate}%`}
            icon={TrendingUp}
            color={Number(collectionRate) >= 70 ? "emerald" : "amber"}
            subtitle={`${totalMembers} active members`}
          />
        </div>

        {/* Charts Row */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Revenue vs Expenses Bar Chart */}
          <div className="bg-white rounded-xl border border-slate-200 p-6">
            <h3 className="text-sm font-semibold text-slate-700 mb-1">Revenue vs Expenses</h3>
            <p className="text-xs text-slate-400 mb-4">Monthly comparison for 2025</p>
            <ResponsiveContainer width="100%" height={280}>
              <BarChart data={monthlyData} barGap={4}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                <XAxis dataKey="month" tick={{ fontSize: 12 }} stroke="#94a3b8" />
                <YAxis tick={{ fontSize: 12 }} stroke="#94a3b8" tickFormatter={(v) => `₹${(v/1000).toFixed(0)}K`} />
                <Tooltip
                  formatter={(value: any) => [`₹${Number(value).toLocaleString("en-IN")}`, ""]}
                  contentStyle={{ borderRadius: 8, border: "1px solid #e2e8f0", fontSize: 12 }}
                />
                <Legend wrapperStyle={{ fontSize: 12 }} />
                <Bar dataKey="collected" name="Collected" fill="#10b981" radius={[4, 4, 0, 0]} />
                <Bar dataKey="expenses" name="Expenses" fill="#8b5cf6" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>

          {/* Expense Breakdown Pie Chart */}
          <div className="bg-white rounded-xl border border-slate-200 p-6">
            <h3 className="text-sm font-semibold text-slate-700 mb-1">Expense Breakdown</h3>
            <p className="text-xs text-slate-400 mb-4">By category</p>
            <ResponsiveContainer width="100%" height={280}>
              <PieChart>
                <Pie
                  data={pieData}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={100}
                  paddingAngle={4}
                  dataKey="value"
                  label={({ name, percent }: any) => `${name} ${((percent || 0) * 100).toFixed(0)}%`}
                >
                  {pieData.map((_, index) => (
                    <Cell key={`cell-${index}`} fill={CHART_COLORS[index % CHART_COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip formatter={(value: any) => [`₹${Number(value).toLocaleString("en-IN")}`, "Amount"]} />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Bottom Row: Audit Logs + Bills Summary */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Recent Activity */}
          <div className="lg:col-span-2 bg-white rounded-xl border border-slate-200 p-6">
            <div className="flex items-center gap-2 mb-4">
              <Activity size={18} className="text-indigo-500" />
              <h3 className="text-sm font-semibold text-slate-700">Recent Activity</h3>
            </div>
            <div className="space-y-3">
              {recentLogs.map((log) => (
                <div key={log.id} className="flex items-center gap-4 p-3 rounded-lg hover:bg-slate-50 transition-colors">
                  <div className={`w-9 h-9 rounded-lg flex items-center justify-center text-xs font-bold
                    ${log.action.includes("PAYMENT") ? "bg-emerald-50 text-emerald-600"
                    : log.action.includes("EXPENSE") ? "bg-purple-50 text-purple-600"
                    : log.action.includes("MEMBER") ? "bg-blue-50 text-blue-600"
                    : log.action.includes("NOTICE") ? "bg-amber-50 text-amber-600"
                    : "bg-slate-50 text-slate-600"}`}
                  >
                    {log.action.slice(0, 2)}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-slate-700 truncate">
                      {log.action.replace(/_/g, " ")}
                    </p>
                    <p className="text-xs text-slate-400">
                      by <span className="font-medium">{log.actorRole}</span> · {log.targetCollection}/{log.targetId}
                    </p>
                  </div>
                  <div className="flex items-center gap-1 text-xs text-slate-400">
                    <Clock size={12} />
                    {formatDate(log.timestamp)}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Bills Summary */}
          <div className="bg-white rounded-xl border border-slate-200 p-6">
            <h3 className="text-sm font-semibold text-slate-700 mb-4">Bills Summary</h3>
            <div className="space-y-4">
              <div className="flex items-center justify-between p-3 bg-emerald-50 rounded-lg">
                <span className="text-sm font-medium text-emerald-700">Paid</span>
                <span className="text-lg font-bold text-emerald-700">{paidBills}</span>
              </div>
              <div className="flex items-center justify-between p-3 bg-amber-50 rounded-lg">
                <span className="text-sm font-medium text-amber-700">Pending</span>
                <span className="text-lg font-bold text-amber-700">{pendingBills}</span>
              </div>
              <div className="flex items-center justify-between p-3 bg-rose-50 rounded-lg">
                <span className="text-sm font-medium text-rose-700">Overdue</span>
                <span className="text-lg font-bold text-rose-700">{overdueBills}</span>
              </div>
              <div className="pt-3 border-t border-slate-100">
                <div className="flex justify-between text-sm">
                  <span className="text-slate-500">Total Billed</span>
                  <span className="font-bold text-slate-900">{formatCompact(totalBilled)}</span>
                </div>
                <div className="flex justify-between text-sm mt-1">
                  <span className="text-slate-500">Net Collected</span>
                  <span className="font-bold text-emerald-600">{formatCompact(totalCollected)}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
