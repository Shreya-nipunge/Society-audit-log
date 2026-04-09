"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { Building2, Mail, Lock, Loader2, AlertCircle } from "lucide-react";
import { useAuth } from "@/lib/auth";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const router = useRouter();
  const { signIn } = useAuth();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      await signIn(email, password);
      router.push("/dashboard");
    } catch (err: any) {
      console.error(err);
      setError(err.message || "Failed to sign in. Please check your credentials.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-4" style={{ backgroundColor: "#F8F9FB" }}>
      <div className="w-full max-w-md">
        {/* Brand */}
        <div className="flex flex-col items-center mb-8">
          <div className="w-14 h-14 rounded-xl flex items-center justify-center shadow-lg mb-4"
            style={{ background: "linear-gradient(135deg, #C5A065, #E5C48A)", boxShadow: "0 8px 24px rgba(197, 160, 101, 0.3)" }}>
            <Building2 size={28} style={{ color: "#0F2040" }} />
          </div>
          <h1 className="text-2xl font-bold" style={{ color: "#0F2040" }}>Society Audit Log</h1>
          <p className="text-sm mt-1" style={{ color: "#C5A065" }}>Admin & Auditor Portal</p>
        </div>

        {/* Login Card */}
        <div className="bg-white rounded-2xl shadow-xl overflow-hidden" style={{ borderColor: "#E0E2E7", borderWidth: 1 }}>
          <div className="p-8">
            <h2 className="text-xl font-bold mb-6" style={{ color: "#0F2040" }}>Sign In</h2>

            {error && (
              <div className="mb-6 p-4 rounded-xl flex items-start gap-3" style={{ backgroundColor: "#FDE8E8", border: "1px solid #FBBABA" }}>
                <AlertCircle size={18} style={{ color: "#D32F2F" }} className="flex-shrink-0 mt-0.5" />
                <p className="text-sm font-medium leading-relaxed" style={{ color: "#D32F2F" }}>{error}</p>
              </div>
            )}

            <form onSubmit={handleLogin} className="space-y-5">
              <div className="space-y-2">
                <label className="text-sm font-semibold ml-1" style={{ color: "#2C2F33" }}>Email Address</label>
                <div className="relative">
                  <div className="absolute left-3 top-1/2 -translate-y-1/2" style={{ color: "#636C7A" }}>
                    <Mail size={18} />
                  </div>
                  <input
                    type="email"
                    required
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="chairman@society.com"
                    className="w-full pl-10 pr-4 py-3 rounded-xl outline-none transition-all placeholder:text-[#636C7A]"
                    style={{ backgroundColor: "#F8F9FB", border: "1.5px solid #E0E2E7", color: "#0F2040" }}
                    onFocus={(e) => { e.target.style.borderColor = "#0F2040"; e.target.style.boxShadow = "0 0 0 3px rgba(15,32,64,0.08)"; }}
                    onBlur={(e) => { e.target.style.borderColor = "#E0E2E7"; e.target.style.boxShadow = "none"; }}
                  />
                </div>
              </div>

              <div className="space-y-2">
                <div className="flex items-center justify-between ml-1 mr-1">
                  <label className="text-sm font-semibold" style={{ color: "#2C2F33" }}>Password</label>
                  <a href="#" className="text-xs font-semibold" style={{ color: "#C5A065" }}>Forgot?</a>
                </div>
                <div className="relative">
                  <div className="absolute left-3 top-1/2 -translate-y-1/2" style={{ color: "#636C7A" }}>
                    <Lock size={18} />
                  </div>
                  <input
                    type="password"
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••"
                    className="w-full pl-10 pr-4 py-3 rounded-xl outline-none transition-all placeholder:text-[#636C7A]"
                    style={{ backgroundColor: "#F8F9FB", border: "1.5px solid #E0E2E7", color: "#0F2040" }}
                    onFocus={(e) => { e.target.style.borderColor = "#0F2040"; e.target.style.boxShadow = "0 0 0 3px rgba(15,32,64,0.08)"; }}
                    onBlur={(e) => { e.target.style.borderColor = "#E0E2E7"; e.target.style.boxShadow = "none"; }}
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full text-white py-3.5 rounded-xl font-bold shadow-lg transition-all active:scale-[0.98] disabled:opacity-70 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                style={{ backgroundColor: "#0F2040", boxShadow: "0 4px 12px rgba(15,32,64,0.25)" }}
                onMouseOver={(e) => (e.currentTarget.style.backgroundColor = "#1E3A66")}
                onMouseOut={(e) => (e.currentTarget.style.backgroundColor = "#0F2040")}
              >
                {loading ? (
                  <Loader2 size={20} className="animate-spin" />
                ) : (
                  "Sign In to Audit Log"
                )}
              </button>
            </form>
          </div>

          <div className="px-8 py-5 flex items-center justify-center" style={{ backgroundColor: "#F8F9FB", borderTop: "1px solid #E0E2E7" }}>
            <p className="text-xs font-medium" style={{ color: "#636C7A" }}>© 2025 Shivkrupasagar CHS Ltd. · Security Audit Log</p>
          </div>
        </div>
      </div>
    </div>
  );
}
