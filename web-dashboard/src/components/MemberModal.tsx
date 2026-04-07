"use client";
import { useState } from "react";
import { X, UserPlus, Loader2, AlertCircle } from "lucide-react";

interface MemberModalProps {
  isOpen: boolean;
  onClose: () => void;
  onAdd: (member: any) => Promise<void>;
}

export function MemberModal({ isOpen, onClose, onAdd }: MemberModalProps) {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    flatNumber: "",
    phone: "",
    role: "member",
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    try {
      await onAdd({
        uid: `new-${Date.now()}`, // Temporary ID for UI
        ...formData,
        status: "Active",
        joinedDate: new Date().toISOString(),
      });
      onClose();
      // Reset form
      setFormData({ name: "", email: "", flatNumber: "", phone: "", role: "member" });
    } catch (err: any) {
      setError(err.message || "Failed to add member.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-sm">
      <div className="bg-white rounded-2xl w-full max-w-md shadow-xl overflow-hidden flex flex-col max-h-[90vh]">
        
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100" style={{ backgroundColor: "#F8F9FB" }}>
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg flex items-center justify-center" style={{ backgroundColor: "rgba(15,32,64,0.1)" }}>
              <UserPlus size={18} style={{ color: "#0F2040" }} />
            </div>
            <h2 className="text-lg font-bold" style={{ color: "#0F2040" }}>Add New Member</h2>
          </div>
          <button onClick={onClose} className="p-2 rounded-lg hover:bg-slate-200/50 transition-colors">
            <X size={20} style={{ color: "#636C7A" }} />
          </button>
        </div>

        {/* Form Body */}
        <div className="p-6 overflow-y-auto">
          {error && (
            <div className="mb-4 p-3 rounded-lg flex items-start gap-2" style={{ backgroundColor: "#FDE8E8", border: "1px solid #FBBABA" }}>
              <AlertCircle size={16} style={{ color: "#D32F2F" }} className="flex-shrink-0 mt-0.5" />
              <p className="text-sm font-medium" style={{ color: "#D32F2F" }}>{error}</p>
            </div>
          )}

          <form id="add-member-form" onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-1.5">
              <label className="text-sm font-semibold" style={{ color: "#2C2F33" }}>Full Name</label>
              <input required type="text" placeholder="e.g. Ramesh Patel" value={formData.name} onChange={e => setFormData({ ...formData, name: e.target.value })} className="w-full px-3 py-2 rounded-lg text-sm border outline-none transition-all placeholder:text-[#636C7A]" style={{ borderColor: "#E0E2E7", color: "#0F2040", backgroundColor: "#F8F9FB" }} onFocus={(e) => e.target.style.borderColor = "#0F2040"} onBlur={(e) => e.target.style.borderColor = "#E0E2E7"} />
            </div>

            <div className="space-y-1.5">
              <label className="text-sm font-semibold" style={{ color: "#2C2F33" }}>Email Address</label>
              <input required type="email" placeholder="ramesh@example.com" value={formData.email} onChange={e => setFormData({ ...formData, email: e.target.value })} className="w-full px-3 py-2 rounded-lg text-sm border outline-none transition-all placeholder:text-[#636C7A]" style={{ borderColor: "#E0E2E7", color: "#0F2040", backgroundColor: "#F8F9FB" }} onFocus={(e) => e.target.style.borderColor = "#0F2040"} onBlur={(e) => e.target.style.borderColor = "#E0E2E7"} />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <label className="text-sm font-semibold" style={{ color: "#2C2F33" }}>Flat Number</label>
                <input required type="text" placeholder="e.g. A-402" value={formData.flatNumber} onChange={e => setFormData({ ...formData, flatNumber: e.target.value })} className="w-full px-3 py-2 rounded-lg text-sm border outline-none transition-all placeholder:text-[#636C7A]" style={{ borderColor: "#E0E2E7", color: "#0F2040", backgroundColor: "#F8F9FB" }} onFocus={(e) => e.target.style.borderColor = "#0F2040"} onBlur={(e) => e.target.style.borderColor = "#E0E2E7"} />
              </div>

              <div className="space-y-1.5">
                <label className="text-sm font-semibold" style={{ color: "#2C2F33" }}>Phone Number</label>
                <input required type="tel" placeholder="e.g. +91 9876543210" value={formData.phone} onChange={e => setFormData({ ...formData, phone: e.target.value })} className="w-full px-3 py-2 rounded-lg text-sm border outline-none transition-all placeholder:text-[#636C7A]" style={{ borderColor: "#E0E2E7", color: "#0F2040", backgroundColor: "#F8F9FB" }} onFocus={(e) => e.target.style.borderColor = "#0F2040"} onBlur={(e) => e.target.style.borderColor = "#E0E2E7"} />
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-sm font-semibold" style={{ color: "#2C2F33" }}>Society Role</label>
              <select required value={formData.role} onChange={e => setFormData({ ...formData, role: e.target.value })} className="w-full px-3 py-2 rounded-lg text-sm border outline-none transition-all" style={{ borderColor: "#E0E2E7", color: "#0F2040", backgroundColor: "#F8F9FB" }} onFocus={(e) => e.target.style.borderColor = "#0F2040"} onBlur={(e) => e.target.style.borderColor = "#E0E2E7"}>
                <option value="member">Standard Member</option>
                <option value="chairman">Chairman</option>
                <option value="secretary">Secretary</option>
                <option value="treasurer">Treasurer</option>
              </select>
            </div>
          </form>
        </div>

        {/* Footer */}
        <div className="p-6 border-t border-slate-100 flex items-center justify-end gap-3" style={{ backgroundColor: "#F8F9FB" }}>
          <button type="button" onClick={onClose} disabled={loading} className="px-4 py-2 rounded-lg text-sm font-semibold transition-colors disabled:opacity-50" style={{ color: "#636C7A" }}>
            Cancel
          </button>
          <button type="submit" form="add-member-form" disabled={loading} className="flex items-center gap-2 px-5 py-2 rounded-lg text-sm font-semibold text-white transition-all disabled:opacity-70 disabled:cursor-not-allowed" style={{ backgroundColor: "#0F2040" }}>
            {loading && <Loader2 size={16} className="animate-spin" />}
            Save Member
          </button>
        </div>

      </div>
    </div>
  );
}
