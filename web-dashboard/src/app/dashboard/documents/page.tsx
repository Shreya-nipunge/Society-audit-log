"use client";
import { useState, useEffect } from "react";
import { Header } from "@/components/Header";
import { formatDate, cn } from "@/lib/utils";
import { FileText, Upload, Download, Search, FolderOpen, File } from "lucide-react";
import { subscribeToDocuments } from "@/lib/firestore-service";
import { SocietyDocument } from "@/lib/types";

const categoryColors: Record<string, string> = {
  "AGM Minutes": "bg-orange-50 text-orange-600",
  "Audit Reports": "bg-indigo-50 text-indigo-600",
  "Annual Reports": "bg-teal-50 text-teal-600",
  "Circulars": "bg-blue-50 text-blue-600",
  "Receipts": "bg-emerald-50 text-emerald-600",
};

const categoryIcons: Record<string, typeof FileText> = {
  "AGM Minutes": FolderOpen,
  "Audit Reports": FileText,
  "Annual Reports": File,
  "Circulars": FileText,
  "Receipts": File,
};

import { useAuth } from "@/lib/auth";

export default function DocumentsPage() {
  const { user, loading: authLoading } = useAuth();
  const [search, setSearch] = useState("");
  const [catFilter, setCatFilter] = useState("All");
  const [documents, setDocuments] = useState<SocietyDocument[]>([]);

  useEffect(() => {
    if (!user || authLoading) return;
    const unsub = subscribeToDocuments(setDocuments);
    return () => unsub();
  }, [user, authLoading]);

  const categories = ["All", ...Array.from(new Set(documents.map((d) => d.category)))];

  const filtered = documents.filter((d) => {
    const matchSearch = !search || d.fileName.toLowerCase().includes(search.toLowerCase()) || d.category.toLowerCase().includes(search.toLowerCase());
    const matchCat = catFilter === "All" || d.category === catFilter;
    return matchSearch && matchCat;
  });

  return (
    <>
      <Header title="Document Vault" subtitle="Society records, reports, and circulars" />
      <div className="p-8 space-y-6">
        {/* Toolbar */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2 bg-white border border-slate-200 rounded-lg px-3 py-2 w-72">
              <Search size={16} className="text-slate-400" />
              <input type="text" placeholder="Search documents..." value={search} onChange={(e) => setSearch(e.target.value)} className="bg-transparent text-sm outline-none w-full" />
            </div>
            <div className="flex items-center gap-1 bg-white border border-slate-200 rounded-lg px-2 py-1">
              {categories.map((c) => (
                <button key={c} onClick={() => setCatFilter(c)} className={cn("px-3 py-1.5 rounded-md text-xs font-medium transition-all", catFilter === c ? "bg-indigo-100 text-indigo-700" : "text-slate-500 hover:bg-slate-50")}>
                  {c}
                </button>
              ))}
            </div>
          </div>
          <button className="flex items-center gap-2 bg-indigo-600 text-white px-4 py-2.5 rounded-lg text-sm font-medium hover:bg-indigo-700 transition-colors">
            <Upload size={16} /> Upload Document
          </button>
        </div>

        {/* Document Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
          {filtered.map((doc) => {
            const Icon = categoryIcons[doc.category] || FileText;
            return (
              <div key={doc.id} className="bg-white rounded-xl border border-slate-200 p-5 hover:shadow-md transition-shadow group">
                <div className={cn("w-12 h-12 rounded-xl flex items-center justify-center mb-4", categoryColors[doc.category] || "bg-slate-50 text-slate-600")}>
                  <Icon size={22} />
                </div>
                <h3 className="text-sm font-bold text-slate-800 truncate mb-1" title={doc.fileName}>{doc.fileName}</h3>
                <span className={cn("inline-flex px-2 py-0.5 rounded text-[10px] font-semibold mb-3", categoryColors[doc.category] || "bg-slate-100 text-slate-600")}>
                  {doc.category}
                </span>
                <div className="space-y-1 text-xs text-slate-400 mb-4">
                  <p>Uploaded by <span className="font-medium text-slate-600">{doc.uploadedBy}</span></p>
                  <p>{formatDate(doc.uploadedAt)}</p>
                </div>
                <button className="w-full flex items-center justify-center gap-2 py-2 rounded-lg border border-slate-200 text-sm font-medium text-slate-600 hover:bg-slate-50 opacity-0 group-hover:opacity-100 transition-all">
                  <Download size={14} /> Download
                </button>
              </div>
            );
          })}
        </div>

        {filtered.length === 0 && (
          <div className="text-center py-16">
            <FolderOpen size={48} className="text-slate-200 mx-auto mb-4" />
            <p className="text-slate-400">No documents found</p>
          </div>
        )}
      </div>
    </>
  );
}
