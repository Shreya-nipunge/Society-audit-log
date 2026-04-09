"use client";
import { useState, useEffect } from "react";
import { Header } from "@/components/Header";
import { formatDate, formatCompact } from "@/lib/utils";
import { Search, Download, CreditCard, Wallet, Building2, Banknote } from "lucide-react";
import { subscribeToTransactions, subscribeToMembers } from "@/lib/firestore-service";
import type { User, Transaction } from "@/lib/types";

const modeIcons: Record<string, any> = {
  UPI: Wallet,
  "Bank Transfer": Building2,
  Cheque: Banknote,
  Cash: CreditCard,
};

import { useAuth } from "@/lib/auth";

export default function TransactionsPage() {
  const { user, loading: authLoading } = useAuth();
  const [search, setSearch] = useState("");
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [users, setUsers] = useState<User[]>([]);

  useEffect(() => {
    if (!user || authLoading) return;
    const unsubTx = subscribeToTransactions(setTransactions);
    const unsubUsers = subscribeToMembers(setUsers);
    return () => {
      unsubTx();
      unsubUsers();
    };
  }, [user, authLoading]);

  const totalAmount = transactions.reduce((s, t) => s + (t.amount || 0), 0);

  const filtered = transactions
    .filter((t) => {
      const member = users.find((u) => u.uid === t.memberId);
      return !search || t.referenceNumber.toLowerCase().includes(search.toLowerCase()) ||
        (member?.name || "").toLowerCase().includes(search.toLowerCase()) ||
        t.paymentMode.toLowerCase().includes(search.toLowerCase());
    })
    .sort((a, b) => new Date(b.paidAt).getTime() - new Date(a.paidAt).getTime());

  const handleExport = () => {
    const headers = ["Date", "Member Name", "Flat Number", "Mode", "Reference", "Recorded By", "Amount"];
    const rows = filtered.map(tx => {
      const member = users.find((u) => u.uid === tx.memberId);
      return [
        `"${formatDate(tx.paidAt)}"`,
        `"${member?.name || tx.memberName || tx.memberId}"`,
        `"${member?.flatNumber || ""}"`,
        `"${tx.paymentMode}"`,
        `"${tx.referenceNumber}"`,
        `"${tx.recordedBy}"`,
        tx.amount
      ];
    });
    
    const csvContent = [headers.join(","), ...rows.map(e => e.join(","))].join("\n");
    const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `transactions_export_${new Date().getTime()}.csv`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <>
      <Header title="Payment Transactions" subtitle={`${transactions.length} transactions · ${formatCompact(totalAmount)} total`} />
      <div className="p-8 space-y-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2 bg-white rounded-lg px-3 py-2 w-80" style={{ border: "1px solid #E0E2E7" }}>
            <Search size={16} style={{ color: "#636C7A" }} />
            <input type="text" placeholder="Search by member, reference, mode..." value={search} onChange={(e) => setSearch(e.target.value)} className="bg-transparent text-sm outline-none w-full placeholder:text-[#636C7A]" style={{ color: "#2C2F33" }} />
          </div>
          <button 
            onClick={handleExport} 
            className="flex items-center gap-2 text-white px-4 py-2.5 rounded-lg text-sm font-medium transition-colors shadow-sm" 
            style={{ backgroundColor: "#0F2040" }}
            onMouseOver={(e) => (e.currentTarget.style.backgroundColor = "#1E3B6E")} 
            onMouseOut={(e) => (e.currentTarget.style.backgroundColor = "#0F2040")}
          >
            <Download size={16} />
            Export
          </button>
        </div>

        <div className="bg-white rounded-xl overflow-hidden" style={{ border: "1px solid #E0E2E7" }}>
          <table className="w-full">
            <thead>
              <tr style={{ backgroundColor: "#F8F9FB", borderBottom: "1px solid #E0E2E7" }}>
                <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Date</th>
                <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Member</th>
                <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Mode</th>
                <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Reference</th>
                <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Recorded By</th>
                <th className="text-right text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Amount</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.map((tx) => {
                const member = users.find((u) => u.uid === tx.memberId);
                const ModeIcon = modeIcons[tx.paymentMode] || CreditCard;
                return (
                  <tr key={tx.id} className="hover:bg-slate-50/50 transition-colors">
                    <td className="px-6 py-3.5 text-sm" style={{ color: "#636C7A" }}>{formatDate(tx.paidAt)}</td>
                    <td className="px-6 py-3.5">
                      <div>
                        <p className="text-sm font-medium" style={{ color: "#2C2F33" }}>{member?.name || tx.memberId}</p>
                        <p className="text-xs" style={{ color: "#636C7A" }}>{member?.flatNumber || ""}</p>
                      </div>
                    </td>
                    <td className="px-6 py-3.5">
                      <div className="flex items-center gap-2">
                        <ModeIcon size={14} style={{ color: "#C5A065" }} />
                        <span className="text-sm" style={{ color: "#636C7A" }}>{tx.paymentMode}</span>
                      </div>
                    </td>
                    <td className="px-6 py-3.5">
                      <span className="text-xs font-mono px-2 py-1 rounded" style={{ backgroundColor: "#F8F9FB", color: "#636C7A", border: "1px solid #E0E2E7" }}>{tx.referenceNumber}</span>
                    </td>
                    <td className="px-6 py-3.5 text-sm" style={{ color: "#636C7A" }}>{tx.recordedBy}</td>
                    <td className="px-6 py-3.5 text-right">
                      <span className="text-sm font-bold" style={{ color: "#2E7D32" }}>+₹{(tx.amount || 0).toLocaleString("en-IN")}</span>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
          <div className="px-6 py-3 flex justify-between" style={{ backgroundColor: "#F8F9FB", borderTop: "1px solid #E0E2E7" }}>
            <p className="text-xs" style={{ color: "#636C7A" }}>Showing {filtered.length} transactions</p>
            <p className="text-xs font-bold" style={{ color: "#2E7D32" }}>Total: ₹{(filtered.reduce((s, t) => s + (t.amount || 0), 0)).toLocaleString("en-IN")}</p>
          </div>
        </div>
      </div>
    </>
  );
}
