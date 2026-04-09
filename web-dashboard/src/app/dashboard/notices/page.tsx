"use client";
import { useState, useEffect } from "react";
import { Header } from "@/components/Header";
import { formatDate, cn } from "@/lib/utils";
import { Bell, Plus, Eye, Edit2, Send, FileEdit, ClipboardList } from "lucide-react";
import { NoticeModal } from "@/components/NoticeModal";
import { Notice } from "@/lib/types";
import { subscribeToNotices } from "@/lib/firestore-service";

import { useAuth } from "@/lib/auth";

export default function NoticesPage() {
  const { user, loading: authLoading } = useAuth();
  const [tab, setTab] = useState<"Published" | "Draft">("Published");
  const [notices, setNotices] = useState<Notice[]>([]);
  const [isModalOpen, setIsModalOpen] = useState(false);

  useEffect(() => {
    if (!user || authLoading) return;
    const unsub = subscribeToNotices(setNotices);
    return () => unsub();
  }, [user, authLoading]);

  const filtered = notices.filter((n) => n.status === tab);

  const handleAddNotice = (notice: Notice) => {
    setNotices((prev) => [notice, ...prev]);
  };

  return (
    <>
      <Header title="Notice Board" subtitle="Manage society announcements and circulars" />
      <div className="p-8 space-y-6">
        {/* Toolbar */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-1 bg-white border border-slate-200 rounded-lg p-1 shadow-sm">
            {(["Published", "Draft"] as const).map((t) => (
              <button
                key={t}
                onClick={() => setTab(t)}
                className={cn(
                  "px-6 py-2 rounded-md text-xs font-bold uppercase tracking-wider transition-all",
                  tab === t ? "text-white shadow-md shadow-[#0F2040]/20" : "text-slate-400 hover:text-slate-600 hover:bg-slate-50"
                )}
                style={tab === t ? { backgroundColor: "#0F2040" } : undefined}
              >
                {t} ({notices.filter((n) => n.status === t).length})
              </button>
            ))}
          </div>
          <button 
            onClick={() => setIsModalOpen(true)}
            className="flex items-center gap-2 text-white px-6 py-2.5 rounded-xl text-sm font-bold shadow-lg transition-all active:scale-[0.95]"
            style={{ 
              background: "linear-gradient(135deg, #0F2040, #1E3A66)",
              boxShadow: "0 4px 12px rgba(15, 32, 64, 0.25)" 
            }}
          >
            <Plus size={18} /> New Notice
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
          <div className="flex flex-col items-center justify-center py-24 text-center">
            <div className="w-20 h-20 rounded-full bg-slate-50 flex items-center justify-center mb-4 border border-dashed border-slate-200">
              <ClipboardList size={32} className="text-slate-200" />
            </div>
            <h3 className="text-lg font-bold text-slate-400">No {tab.toLowerCase()} notices</h3>
            <p className="text-sm text-slate-400 mt-1 max-w-[280px]">Drafts will appear here until they are published for residents.</p>
          </div>
        )}
      </div>
      <NoticeModal 
        isOpen={isModalOpen} 
        onClose={() => setIsModalOpen(false)} 
        onAdd={handleAddNotice} 
      />
    </>
  );
}
