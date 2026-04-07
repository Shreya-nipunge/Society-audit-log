"use client";
import { Header } from "@/components/Header";
import { mockNotices } from "@/lib/mock-data";
import { formatDate, cn } from "@/lib/utils";
import { Bell, Plus, Eye, Edit2, Send, FileEdit } from "lucide-react";
import { useState } from "react";

export default function NoticesPage() {
  const [tab, setTab] = useState<"Published" | "Draft">("Published");

  const filtered = mockNotices.filter((n) => n.status === tab);

  return (
    <>
      <Header title="Notice Board" subtitle="Manage society announcements and circulars" />
      <div className="p-8 space-y-6">
        {/* Toolbar */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-1 bg-white border border-slate-200 rounded-lg p-1">
            {(["Published", "Draft"] as const).map((t) => (
              <button
                key={t}
                onClick={() => setTab(t)}
                className={cn(
                  "px-5 py-2 rounded-md text-sm font-medium transition-all",
                  tab === t ? "bg-indigo-600 text-white shadow-sm" : "text-slate-500 hover:bg-slate-50"
                )}
              >
                {t} ({mockNotices.filter((n) => n.status === t).length})
              </button>
            ))}
          </div>
          <button className="flex items-center gap-2 bg-indigo-600 text-white px-4 py-2.5 rounded-lg text-sm font-medium hover:bg-indigo-700 transition-colors">
            <Plus size={16} /> New Notice
          </button>
        </div>

        {/* Notice Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {filtered.map((notice) => (
            <div key={notice.id} className="bg-white rounded-xl border border-slate-200 p-5 hover:shadow-md transition-shadow group">
              <div className="flex items-start justify-between mb-3">
                <div className={cn(
                  "p-2.5 rounded-xl",
                  notice.status === "Published" ? "bg-emerald-50" : "bg-amber-50"
                )}>
                  {notice.status === "Published" ? (
                    <Bell size={18} className="text-emerald-600" />
                  ) : (
                    <FileEdit size={18} className="text-amber-600" />
                  )}
                </div>
                <span className={cn(
                  "px-2.5 py-1 rounded-full text-xs font-semibold",
                  notice.status === "Published" ? "bg-emerald-50 text-emerald-700" : "bg-amber-50 text-amber-700"
                )}>
                  {notice.status}
                </span>
              </div>
              <h3 className="text-base font-bold text-slate-800 mb-2 line-clamp-2">{notice.title}</h3>
              <p className="text-sm text-slate-500 line-clamp-3 mb-4">{notice.body}</p>
              <div className="flex items-center justify-between pt-3 border-t border-slate-100">
                <div>
                  <p className="text-xs text-slate-400">Posted by <span className="font-medium text-slate-600">{notice.postedBy}</span></p>
                  <p className="text-xs text-slate-400 mt-0.5">{formatDate(notice.createdAt)}</p>
                </div>
                <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                  <button className="p-1.5 rounded-lg hover:bg-slate-100" title="View"><Eye size={14} className="text-slate-500" /></button>
                  <button className="p-1.5 rounded-lg hover:bg-slate-100" title="Edit"><Edit2 size={14} className="text-slate-500" /></button>
                  {notice.status === "Draft" && (
                    <button className="p-1.5 rounded-lg hover:bg-emerald-50" title="Publish"><Send size={14} className="text-emerald-500" /></button>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>

        {filtered.length === 0 && (
          <div className="text-center py-16">
            <Bell size={48} className="text-slate-200 mx-auto mb-4" />
            <p className="text-slate-400">No {tab.toLowerCase()} notices</p>
          </div>
        )}
      </div>
    </>
  );
}
