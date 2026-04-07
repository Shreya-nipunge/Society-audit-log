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
          <div className="flex items-center gap-2 bg-white border border-slate-200 rounded-lg px-3 py-2 w-80">
            <Search size={16} className="text-slate-400" />
            <input type="text" placeholder="Search by member, reference, mode..." value={search} onChange={(e) => setSearch(e.target.value)} className="bg-transparent text-sm outline-none w-full" />
          </div>
          <button className="flex items-center gap-2 bg-white border border-slate-200 text-slate-600 px-4 py-2.5 rounded-lg text-sm font-medium hover:bg-slate-50 transition-colors">
            <Download size={16} />
            Export
          </button>
        </div>

        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <table className="w-full">
            <thead>
              <tr className="bg-slate-50 border-b border-slate-200">
                <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Date</th>
                <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Member</th>
                <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Mode</th>
                <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Reference</th>
                <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Recorded By</th>
                <th className="text-right text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Amount</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.map((tx) => {
                const member = mockUsers.find((u) => u.uid === tx.memberId);
                const ModeIcon = modeIcons[tx.paymentMode] || CreditCard;
                return (
                  <tr key={tx.id} className="hover:bg-slate-50/50 transition-colors">
                    <td className="px-6 py-3.5 text-sm text-slate-600">{formatDate(tx.paidAt)}</td>
                    <td className="px-6 py-3.5">
                      <div>
                        <p className="text-sm font-medium text-slate-700">{member?.name || tx.memberId}</p>
                        <p className="text-xs text-slate-400">{member?.flatNumber || ""}</p>
                      </div>
                    </td>
                    <td className="px-6 py-3.5">
                      <div className="flex items-center gap-2">
                        <ModeIcon size={14} className="text-indigo-500" />
                        <span className="text-sm text-slate-600">{tx.paymentMode}</span>
                      </div>
                    </td>
                    <td className="px-6 py-3.5">
                      <span className="text-xs font-mono bg-slate-100 text-slate-600 px-2 py-1 rounded">{tx.referenceNumber}</span>
                    </td>
                    <td className="px-6 py-3.5 text-sm text-slate-500">{mockUsers.find(u => u.uid === tx.recordedBy)?.name || tx.recordedBy}</td>
                    <td className="px-6 py-3.5 text-right">
                      <span className="text-sm font-bold text-emerald-600">+₹{tx.amount.toLocaleString("en-IN")}</span>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
          <div className="px-6 py-3 bg-slate-50 border-t border-slate-200 flex justify-between">
            <p className="text-xs text-slate-500">Showing {filtered.length} transactions</p>
            <p className="text-xs font-bold text-emerald-600">Total: ₹{filtered.reduce((s, t) => s + t.amount, 0).toLocaleString("en-IN")}</p>
          </div>
        </div>
      </div>
    </>
  );
}
