"use client";
import { useState } from "react";
import { X, Receipt, Loader2, AlertCircle } from "lucide-react";

interface ExpenseModalProps {
  isOpen: boolean;
  onClose: () => void;
  onAdd: (expense: any) => Promise<void>;
}

const CATEGORIES = ["Maintenance", "Repairs", "Utilities", "Salaries", "Security", "Other"];
const PAYMENT_MODES = ["UPI", "Bank Transfer", "Cheque", "Cash"];

export function ExpenseModal({ isOpen, onClose, onAdd }: ExpenseModalProps) {
  const [formData, setFormData] = useState({
    amount: "",
    vendor: "",
    description: "",
    category: CATEGORIES[0],
    expenseDate: new Date().toISOString().split("T")[0],
    paymentMode: PAYMENT_MODES[0],
    receiptUrl: "",
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
        id: `exp-${Date.now()}`,
        amount: Number(formData.amount),
        vendor: formData.vendor,
        description: formData.description,
        category: formData.category,
        expenseDate: new Date(formData.expenseDate).toISOString(),
        paymentMode: formData.paymentMode as any,
        recordedBy: "Admin", // Would be from Auth context in real app
        receiptUrl: formData.receiptUrl || undefined,
        createdAt: new Date().toISOString(),
      });
      onClose();
      // Reset form
      setFormData({
        amount: "",
        vendor: "",
        description: "",
        category: CATEGORIES[0],
        expenseDate: new Date().toISOString().split("T")[0],
        paymentMode: PAYMENT_MODES[0],
        receiptUrl: "",
      });
    } catch (err: any) {
      setError(err.message || "Failed to record expense.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-sm shadow-2xl">
      <div className="bg-white rounded-2xl w-full max-w-md shadow-xl overflow-hidden flex flex-col max-h-[90vh]">
        
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100" style={{ backgroundColor: "#F8F9FB" }}>
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg flex items-center justify-center" style={{ backgroundColor: "rgba(15,32,64,0.1)" }}>
              <Receipt size={18} style={{ color: "#0F2040" }} />
            </div>
            <h2 className="text-lg font-bold" style={{ color: "#0F2040" }}>Record Expense</h2>
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

          <form id="record-expense-form" onSubmit={handleSubmit} className="space-y-4">
            
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <label className="text-sm font-semibold" style={{ color: "#2C2F33" }}>Amount (₹)</label>
                <input required type="number" min="0" step="any" placeholder="0.00" value={formData.amount} onChange={e => setFormData({ ...formData, amount: e.target.value })} className="w-full px-3 py-2 rounded-lg text-sm border outline-none font-semibold transition-all placeholder:text-[#636C7A]" style={{ borderColor: "#E0E2E7", color: "#0F2040", backgroundColor: "#F8F9FB" }} onFocus={(e) => e.target.style.borderColor = "#0F2040"} onBlur={(e) => e.target.style.borderColor = "#E0E2E7"} />
              </div>

              <div className="space-y-1.5">
                <label className="text-sm font-semibold" style={{ color: "#2C2F33" }}>Date</label>
                <input required type="date" value={formData.expenseDate} onChange={e => setFormData({ ...formData, expenseDate: e.target.value })} className="w-full px-3 py-2 rounded-lg text-sm border outline-none transition-all" style={{ borderColor: "#E0E2E7", color: "#0F2040", backgroundColor: "#F8F9FB" }} onFocus={(e) => e.target.style.borderColor = "#0F2040"} onBlur={(e) => e.target.style.borderColor = "#E0E2E7"} />
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-sm font-semibold" style={{ color: "#2C2F33" }}>Vendor / Payee Name</label>
              <input required type="text" placeholder="e.g. Best Services Ltd" value={formData.vendor} onChange={e => setFormData({ ...formData, vendor: e.target.value })} className="w-full px-3 py-2 rounded-lg text-sm border outline-none transition-all placeholder:text-[#636C7A]" style={{ borderColor: "#E0E2E7", color: "#0F2040", backgroundColor: "#F8F9FB" }} onFocus={(e) => e.target.style.borderColor = "#0F2040"} onBlur={(e) => e.target.style.borderColor = "#E0E2E7"} />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <label className="text-sm font-semibold" style={{ color: "#2C2F33" }}>Category</label>
                <select required value={formData.category} onChange={e => setFormData({ ...formData, category: e.target.value })} className="w-full px-3 py-2 rounded-lg text-sm border outline-none transition-all" style={{ borderColor: "#E0E2E7", color: "#0F2040", backgroundColor: "#F8F9FB" }} onFocus={(e) => e.target.style.borderColor = "#0F2040"} onBlur={(e) => e.target.style.borderColor = "#E0E2E7"}>
                  {CATEGORIES.map(cat => <option key={cat} value={cat}>{cat}</option>)}
                </select>
              </div>

              <div className="space-y-1.5">
                <label className="text-sm font-semibold" style={{ color: "#2C2F33" }}>Payment Mode</label>
                <select required value={formData.paymentMode} onChange={e => setFormData({ ...formData, paymentMode: e.target.value })} className="w-full px-3 py-2 rounded-lg text-sm border outline-none transition-all" style={{ borderColor: "#E0E2E7", color: "#0F2040", backgroundColor: "#F8F9FB" }} onFocus={(e) => e.target.style.borderColor = "#0F2040"} onBlur={(e) => e.target.style.borderColor = "#E0E2E7"}>
                  {PAYMENT_MODES.map(mode => <option key={mode} value={mode}>{mode}</option>)}
                </select>
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-sm font-semibold" style={{ color: "#2C2F33" }}>Description</label>
              <textarea placeholder="Reason for expense..." value={formData.description} onChange={e => setFormData({ ...formData, description: e.target.value })} className="w-full px-3 py-2 rounded-lg text-sm border outline-none transition-all placeholder:text-[#636C7A] resize-none h-20" style={{ borderColor: "#E0E2E7", color: "#0F2040", backgroundColor: "#F8F9FB" }} onFocus={(e) => e.target.style.borderColor = "#0F2040"} onBlur={(e) => e.target.style.borderColor = "#E0E2E7"}></textarea>
            </div>
          </form>
        </div>

        {/* Footer */}
        <div className="p-6 border-t border-slate-100 flex items-center justify-end gap-3" style={{ backgroundColor: "#F8F9FB" }}>
          <button type="button" onClick={onClose} disabled={loading} className="px-4 py-2 rounded-lg text-sm font-semibold transition-colors disabled:opacity-50" style={{ color: "#636C7A" }}>
            Cancel
          </button>
          <button type="submit" form="record-expense-form" disabled={loading} className="flex items-center gap-2 px-5 py-2 rounded-lg text-sm font-semibold text-white transition-all disabled:opacity-70 disabled:cursor-not-allowed" style={{ backgroundColor: "#0F2040" }}>
            {loading && <Loader2 size={16} className="animate-spin" />}
            Save & Record
          </button>
        </div>

      </div>
    </div>
  );
}
