"use client";
import { Header } from "@/components/Header";
import { mockTransactions, mockUsers } from "@/lib/mock-data";
import { formatDate, formatCompact, cn } from "@/lib/utils";
import { Search, Download, CreditCard, Wallet, Building2, Banknote } from "lucide-react";
import { useState } from "react";

const modeIcons: Record<string, typeof CreditCard> = {
  UPI: Wallet,
  "Bank Transfer": Building2,
  Cheque: Banknote,
  Cash: CreditCard,
};

export default function TransactionsPage() {
  const [search, setSearch] = useState("");
  const totalAmount = mockTransactions.reduce((s, t) => s + t.amount, 0);

  const filtered = mockTransactions
    .filter((t) => {
      const member = mockUsers.find((u) => u.uid === t.memberId);
      return !search || t.referenceNumber.toLowerCase().includes(search.toLowerCase()) ||
        (member?.name || "").toLowerCase().includes(search.toLowerCase()) ||
        t.paymentMode.toLowerCase().includes(search.toLowerCase());
    })
    .sort((a, b) => new Date(b.paidAt).getTime() - new Date(a.paidAt).getTime());

  return (
    <>
      <Header title="Payment Transactions" subtitle={`${mockTransactions.length} transactions · ${formatCompact(totalAmount)} total`} />
      <div className="p-8 space-y-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2 bg-white rounded-lg px-3 py-2 w-80" style={{ border: "1px solid #E0E2E7" }}>
            <Search size={16} style={{ color: "#636C7A" }} />
            <input type="text" placeholder="Search by member, reference, mode..." value={search} onChange={(e) => setSearch(e.target.value)} className="bg-transparent text-sm outline-none w-full placeholder:text-[#636C7A]" style={{ color: "#2C2F33" }} />
          </div>
          <button className="flex items-center gap-2 bg-white px-4 py-2.5 rounded-lg text-sm font-medium transition-colors" style={{ border: "1px solid #E0E2E7", color: "#2C2F33" }} onMouseOver={(e) => (e.currentTarget.style.backgroundColor = "#F8F9FB")} onMouseOut={(e) => (e.currentTarget.style.backgroundColor = "white")}>
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
                const member = mockUsers.find((u) => u.uid === tx.memberId);
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
                    <td className="px-6 py-3.5 text-sm" style={{ color: "#636C7A" }}>{mockUsers.find(u => u.uid === tx.recordedBy)?.name || tx.recordedBy}</td>
                    <td className="px-6 py-3.5 text-right">
                      <span className="text-sm font-bold" style={{ color: "#2E7D32" }}>+₹{tx.amount.toLocaleString("en-IN")}</span>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
          <div className="px-6 py-3 flex justify-between" style={{ backgroundColor: "#F8F9FB", borderTop: "1px solid #E0E2E7" }}>
            <p className="text-xs" style={{ color: "#636C7A" }}>Showing {filtered.length} transactions</p>
            <p className="text-xs font-bold" style={{ color: "#2E7D32" }}>Total: ₹{filtered.reduce((s, t) => s + t.amount, 0).toLocaleString("en-IN")}</p>
          </div>
        </div>
      </div>
    </>
  );
}
