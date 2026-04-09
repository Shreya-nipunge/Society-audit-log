"use client";
import { useState } from "react";
import { X, Bell, Send, FileEdit, AlertCircle } from "lucide-react";
import { cn } from "@/lib/utils";
import { Notice } from "@/lib/types";

interface NoticeModalProps {
  isOpen: boolean;
  onClose: () => void;
  onAdd: (notice: Notice) => void;
}

export function NoticeModal({ isOpen, onClose, onAdd }: NoticeModalProps) {
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [status, setStatus] = useState<"Published" | "Draft">("Published");
  const [error, setError] = useState("");

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (!title.trim() || !body.trim()) {
      setError("Please fill in both title and announcement details.");
      return;
    }

    const newNotice: Notice = {
      id: `notice-${Date.now()}`,
      title,
      body,
      status,
      attachmentDocIds: [],
      postedBy: "Society Admin",
      createdAt: new Date().toISOString(),
      publishedAt: status === "Published" ? new Date().toISOString() : "",
    };

    onAdd(newNotice);
    setTitle("");
    setBody("");
    setStatus("Published");
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-[#0F2040]/40 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="bg-white rounded-2xl w-full max-w-lg shadow-2xl overflow-hidden animate-in zoom-in-95 duration-200">
        {/* Header */}
        <div className="px-6 py-5 border-b border-slate-100 flex items-center justify-between" style={{ background: "linear-gradient(to right, #F8F9FB, #FFFFFF)" }}>
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: "rgba(197, 160, 101, 0.1)" }}>
              <Bell size={20} style={{ color: "#C5A065" }} />
            </div>
            <div>
              <h2 className="text-lg font-bold" style={{ color: "#0F2040" }}>New Announcement</h2>
              <p className="text-xs text-slate-500">Post a notice for society residents</p>
            </div>
          </div>
          <button onClick={onClose} className="p-2 rounded-lg hover:bg-slate-100 text-slate-400 transition-colors">
            <X size={20} />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-5">
          {error && (
            <div className="p-3 rounded-lg bg-red-50 border border-red-100 flex items-center gap-2 text-red-600 text-xs font-medium">
              <AlertCircle size={14} />
              {error}
            </div>
          )}

          <div className="space-y-1.5">
            <label className="text-xs font-bold uppercase tracking-wider text-slate-500 ml-1">Title</label>
            <input
              type="text"
              autoFocus
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="e.g. Water Tank Cleaning Schedule"
              className="w-full px-4 py-3 rounded-xl border border-slate-200 outline-none focus:ring-2 focus:ring-[#0F2040]/5 focus:border-[#0F2040] transition-all text-sm placeholder:text-slate-400"
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-bold uppercase tracking-wider text-slate-500 ml-1">Announcement Details</label>
            <textarea
              rows={5}
              value={body}
              onChange={(e) => setBody(e.target.value)}
              placeholder="Write the detailed notice content here..."
              className="w-full px-4 py-3 rounded-xl border border-slate-200 outline-none focus:ring-2 focus:ring-[#0F2040]/5 focus:border-[#0F2040] transition-all text-sm placeholder:text-slate-400 resize-none"
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-bold uppercase tracking-wider text-slate-500 ml-1">Post As</label>
            <div className="grid grid-cols-2 gap-3">
              <button
                type="button"
                onClick={() => setStatus("Published")}
                className={cn(
                  "flex items-center justify-center gap-2 py-3 rounded-xl text-sm font-semibold transition-all border",
                  status === "Published" 
                    ? "bg-[#0F2040] text-white border-[#0F2040] shadow-md shadow-[#0F2040]/20" 
                    : "bg-white text-slate-500 border-slate-200 hover:border-slate-300"
                )}
              >
                <Send size={16} />
                Publish Directly
              </button>
              <button
                type="button"
                onClick={() => setStatus("Draft")}
                className={cn(
                  "flex items-center justify-center gap-2 py-3 rounded-xl text-sm font-semibold transition-all border",
                  status === "Draft" 
                    ? "bg-[#0F2040] text-white border-[#0F2040] shadow-md shadow-[#0F2040]/20" 
                    : "bg-white text-slate-500 border-slate-200 hover:border-slate-300"
                )}
              >
                <FileEdit size={16} />
                Save as Draft
              </button>
            </div>
          </div>

          <div className="pt-4 flex gap-3">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 py-3.5 rounded-xl text-sm font-bold text-slate-500 hover:bg-slate-50 transition-colors border border-slate-200"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="flex-1 py-3.5 rounded-xl text-sm font-bold text-white shadow-lg transition-all active:scale-[0.98]"
              style={{ 
                background: "linear-gradient(135deg, #0F2040, #1E3A66)",
                boxShadow: "0 4px 12px rgba(15, 32, 64, 0.25)" 
              }}
            >
              Finalize Post
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
