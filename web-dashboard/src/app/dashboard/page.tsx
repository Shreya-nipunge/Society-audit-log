"use client";
import { useState, useEffect } from "react";
import { Header } from "@/components/Header";
import { StatsCard } from "@/components/StatsCard";
import { formatCompact, formatDate } from "@/lib/utils";
import { AlertTriangle, TrendingUp, Activity, ArrowDownRight, ArrowUpRight, Clock } from "lucide-react";
import { PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from "recharts";
import { subscribeToMembers, subscribeToTransactions, subscribeToBills, subscribeToExpenses } from "@/lib/firestore-service";
import type { User, Transaction, Expense } from "@/lib/types";

const CHART_COLORS = ["#0F2040", "#1E3A66", "#C5A065", "#E5C48A", "#967635", "#0288D1", "#2E7D32"];

import { useAuth } from "@/lib/auth";

export default function DashboardPage() {
  const { user, loading: authLoading } = useAuth();
  const [users, setUsers] = useState<User[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [bills, setBills] = useState<any[]>([]);
  const [expenses, setExpenses] = useState<Expense[]>([]);

  useEffect(() => {
    if (!user || authLoading) return;

    const unsubMembers = subscribeToMembers(setUsers);
    const unsubTx = subscribeToTransactions(setTransactions);
    const unsubBills = subscribeToBills(setBills);
    const unsubExp = subscribeToExpenses(setExpenses);

    return () => {
      unsubMembers();
      unsubTx();
      unsubBills();
      unsubExp();
    };
  }, [user, authLoading]);

  const totalMembers = users.filter((u) => u.role === "member").length;
  const totalCollected = transactions.reduce((sum, t) => sum + t.amount, 0);
  const totalBilled = bills.reduce((sum, b) => sum + b.totalAmount, 0);
  const totalPending = totalBilled - totalCollected;
  const totalExpenses = expenses.reduce((sum, e) => sum + e.amount, 0);
  const collectionRate = totalBilled > 0 ? ((totalCollected / totalBilled) * 100).toFixed(1) : "0";

  // Expense by category for pie chart
  const expenseByCategory: Record<string, number> = {};
  expenses.forEach((e) => {
    expenseByCategory[e.category] = (expenseByCategory[e.category] || 0) + e.amount;
  });
  const pieData = Object.entries(expenseByCategory).map(([name, value]) => ({ name, value }));

  // Recent activity from transactions
  const recentActivity = transactions.slice(0, 6);

  // Bills status
  const paidBills = bills.filter((b) => b.status === "Paid").length;
  const pendingBills = bills.filter((b) => b.status === "Pending").length;
  const overdueBills = bills.filter((b) => b.status === "Overdue").length;

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
            subtitle={`${expenses.length} expenses recorded`}
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
          <div className="bg-white rounded-xl border p-6" style={{ borderColor: "#E0E2E7" }}>
            <h3 className="text-sm font-semibold mb-1" style={{ color: "#0F2040" }}>Revenue vs Expenses</h3>
            <p className="text-xs mb-4" style={{ color: "#636C7A" }}>Monthly comparison for 2025</p>
            <ResponsiveContainer width="100%" height={280}>
              <BarChart data={[
                { month: "Jan", collected: 12500, expenses: 8400 },
                { month: "Feb", collected: 15200, expenses: 9800 },
                { month: "Mar", collected: totalCollected, expenses: totalExpenses },
              ]} barGap={4}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E0E2E7" />
                <XAxis dataKey="month" tick={{ fontSize: 12 }} stroke="#636C7A" />
                <YAxis tick={{ fontSize: 12 }} stroke="#636C7A" tickFormatter={(v) => `₹${(v/1000).toFixed(0)}K`} />
                <Tooltip
                  formatter={(value: any) => [`₹${Number(value).toLocaleString("en-IN")}`, ""]}
                  contentStyle={{ borderRadius: 8, border: "1px solid #e2e8f0", fontSize: 12 }}
                />
                <Legend wrapperStyle={{ fontSize: 12 }} />
                <Bar dataKey="collected" name="Collected" fill="#2E7D32" radius={[4, 4, 0, 0]} />
                <Bar dataKey="expenses" name="Expenses" fill="#C5A065" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>

          {/* Expense Breakdown Pie Chart */}
          <div className="bg-white rounded-xl border p-6" style={{ borderColor: "#E0E2E7" }}>
            <h3 className="text-sm font-semibold mb-1" style={{ color: "#0F2040" }}>Expense Breakdown</h3>
            <p className="text-xs mb-4" style={{ color: "#636C7A" }}>By category</p>
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
          <div className="lg:col-span-2 bg-white rounded-xl border p-6" style={{ borderColor: "#E0E2E7" }}>
            <div className="flex items-center gap-2 mb-4">
              <Activity size={18} style={{ color: "#C5A065" }} />
              <h3 className="text-sm font-semibold" style={{ color: "#0F2040" }}>Recent Activity</h3>
            </div>
            <div className="space-y-3">
              {recentActivity.map((tx) => (
                <div key={tx.id} className="flex items-center gap-4 p-3 rounded-lg hover:bg-slate-50 transition-colors">
                  <div className={`w-9 h-9 rounded-lg flex items-center justify-center text-xs font-bold bg-[#2E7D32]/10 text-[#2E7D32]`}>
                    TX
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium truncate" style={{ color: "#0F2040" }}>
                      Payment from {tx.memberName}
                    </p>
                    <p className="text-xs text-slate-400">
                      by <span className="font-medium">{tx.recordedBy}</span> · {tx.paymentMode}
                    </p>
                  </div>
                  <div className="flex items-center gap-1 text-xs text-slate-400">
                    <Clock size={12} />
                    {formatDate(tx.paidAt)}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Bills Summary */}
          <div className="bg-white rounded-xl border p-6" style={{ borderColor: "#E0E2E7" }}>
            <h3 className="text-sm font-semibold mb-4" style={{ color: "#0F2040" }}>Bills Summary</h3>
            <div className="space-y-4">
              <div className="flex items-center justify-between p-3 rounded-lg" style={{ backgroundColor: "rgba(46,125,50,0.06)" }}>
                <span className="text-sm font-medium" style={{ color: "#2E7D32" }}>Paid</span>
                <span className="text-lg font-bold" style={{ color: "#2E7D32" }}>{paidBills}</span>
              </div>
              <div className="flex items-center justify-between p-3 rounded-lg" style={{ backgroundColor: "rgba(197,160,101,0.08)" }}>
                <span className="text-sm font-medium" style={{ color: "#967635" }}>Pending</span>
                <span className="text-lg font-bold" style={{ color: "#967635" }}>{pendingBills}</span>
              </div>
              <div className="flex items-center justify-between p-3 rounded-lg" style={{ backgroundColor: "rgba(211,47,47,0.06)" }}>
                <span className="text-sm font-medium" style={{ color: "#D32F2F" }}>Overdue</span>
                <span className="text-lg font-bold" style={{ color: "#D32F2F" }}>{overdueBills}</span>
              </div>
              <div className="pt-3 border-t" style={{ borderColor: "#E0E2E7" }}>
                <div className="flex justify-between text-sm">
                  <span style={{ color: "#636C7A" }}>Total Billed</span>
                  <span className="font-bold" style={{ color: "#0F2040" }}>{formatCompact(totalBilled)}</span>
                </div>
                <div className="flex justify-between text-sm mt-1">
                  <span style={{ color: "#636C7A" }}>Net Collected</span>
                  <span className="font-bold" style={{ color: "#2E7D32" }}>{formatCompact(totalCollected)}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
