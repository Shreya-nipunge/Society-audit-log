"use client";
import { useState, useEffect } from "react";
import { Header } from "@/components/Header";
import { formatDateTime, cn } from "@/lib/utils";
import { Search, Filter, UserCheck, CreditCard, Wallet, FileText, Bell, Upload, UserMinus, Edit } from "lucide-react";
import { subscribeToAuditLogs, subscribeToMembers } from "@/lib/firestore-service";
import { AuditLog, User } from "@/lib/types";

const actionConfig: Record<string, { color: string; icon: typeof UserCheck; label: string }> = {
  ADD_MEMBER: { color: "bg-blue-50 text-blue-600", icon: UserCheck, label: "Member Added" },
  EDIT_MEMBER: { color: "bg-sky-50 text-sky-600", icon: Edit, label: "Member Edited" },
  DEACTIVATE_MEMBER: { color: "bg-orange-50 text-orange-600", icon: UserMinus, label: "Member Deactivated" },
  RECORD_PAYMENT: { color: "bg-emerald-50 text-emerald-600", icon: CreditCard, label: "Payment Recorded" },
  RECORD_EXPENSE: { color: "bg-purple-50 text-purple-600", icon: Wallet, label: "Expense Recorded" },
  GENERATE_BILLS: { color: "bg-indigo-50 text-indigo-600", icon: FileText, label: "Bills Generated" },
  POST_NOTICE: { color: "bg-amber-50 text-amber-600", icon: Bell, label: "Notice Posted" },
  UPLOAD_DOCUMENT: { color: "bg-teal-50 text-teal-600", icon: Upload, label: "Document Uploaded" },
};

import { useAuth } from "@/lib/auth";

export default function AuditLogsPage() {
  const { user, loading: authLoading } = useAuth();
  const [search, setSearch] = useState("");
  const [actionFilter, setActionFilter] = useState("all");
  const [logs, setLogs] = useState<AuditLog[]>([]);
  const [users, setUsers] = useState<User[]>([]);

  useEffect(() => {
    if (!user || authLoading) return;
    const unsubLogs = subscribeToAuditLogs(setLogs);
    const unsubUsers = subscribeToMembers(setUsers);
    return () => {
      unsubLogs();
      unsubUsers();
    };
  }, [user, authLoading]);

  const actions = Array.from(new Set(logs.map((l) => l.action)));

  const filtered = logs
    .filter((l) => {
      const actor = users.find((u) => u.uid === l.actorId);
      const matchSearch = !search ||
        l.action.toLowerCase().includes(search.toLowerCase()) ||
        (actor?.name || "").toLowerCase().includes(search.toLowerCase()) ||
        l.targetCollection.toLowerCase().includes(search.toLowerCase());
      const matchAction = actionFilter === "all" || l.action === actionFilter;
      return matchSearch && matchAction;
    })
    .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());

  return (
    <>
      <Header title="Audit Trail" subtitle="Complete activity log of all administrative actions" />
      <div className="p-8 space-y-6">
        {/* Filters */}
        <div className="flex flex-wrap items-center gap-3">
          <div className="flex items-center gap-2 bg-white border border-slate-200 rounded-lg px-3 py-2 w-80">
            <Search size={16} className="text-slate-400" />
            <input type="text" placeholder="Search actions, users..." value={search} onChange={(e) => setSearch(e.target.value)} className="bg-transparent text-sm outline-none w-full" />
          </div>
          <select
            value={actionFilter}
            onChange={(e) => setActionFilter(e.target.value)}
            className="bg-white border border-slate-200 rounded-lg px-3 py-2.5 text-sm text-slate-600 outline-none"
          >
            <option value="all">All Actions</option>
            {actions.map((a) => (
              <option key={a} value={a}>{a.replace(/_/g, " ")}</option>
            ))}
          </select>
        </div>

        {/* Timeline */}
        <div className="space-y-3">
          {filtered.map((log) => {
            const actor = users.find((u) => u.uid === log.actorId);
            const config = actionConfig[log.action] || { color: "bg-slate-50 text-slate-600", icon: FileText, label: log.action.replace(/_/g, " ") };
            const Icon = config.icon;
            return (
              <div key={log.id} className="bg-white rounded-xl border border-slate-200 p-5 hover:shadow-sm transition-shadow">
                <div className="flex items-start gap-4">
                  <div className={cn("w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0", config.color)}>
                    <Icon size={18} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-4">
                      <div>
                        <p className="text-sm font-semibold text-slate-800">{config.label}</p>
                        <p className="text-xs text-slate-400 mt-0.5">
                          by <span className="font-medium text-slate-600">{actor?.name || log.actorId}</span>
                          <span className="mx-1">·</span>
                          <span className="capitalize">{log.actorRole}</span>
                        </p>
                      </div>
                      <p className="text-xs text-slate-400 whitespace-nowrap">{formatDateTime(log.timestamp)}</p>
                    </div>
                    <div className="flex items-center gap-2 mt-2">
                      <span className="text-xs font-mono bg-slate-100 text-slate-600 px-2 py-0.5 rounded">{log.targetCollection}</span>
                      <span className="text-xs text-slate-400">→</span>
                      <span className="text-xs font-mono bg-slate-100 text-slate-600 px-2 py-0.5 rounded">{log.targetId}</span>
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        {filtered.length === 0 && (
          <div className="text-center py-16">
            <p className="text-slate-400">No audit logs match your filters</p>
          </div>
        )}
      </div>
    </>
  );
}
