"use client";
import { Header } from "@/components/Header";
import { mockUsers } from "@/lib/mock-data";
import { Search, Filter, UserPlus, MoreHorizontal, Mail, Phone, Home, Shield } from "lucide-react";
import { useState } from "react";
import { cn } from "@/lib/utils";

const roleColors: Record<string, string> = {
  chairman: "bg-[#D32F2F]/10 text-[#D32F2F]",
  secretary: "bg-[#0288D1]/10 text-[#0288D1]",
  treasurer: "bg-[#C5A065]/10 text-[#967635]",
  member: "bg-[#0F2040]/5 text-[#0F2040]",
};

export default function MembersPage() {
  const [search, setSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState("all");

  const filtered = mockUsers.filter((u) => {
    const matchesSearch = u.name.toLowerCase().includes(search.toLowerCase()) ||
      u.email.toLowerCase().includes(search.toLowerCase()) ||
      u.flatNumber.toLowerCase().includes(search.toLowerCase());
    const matchesRole = roleFilter === "all" || u.role === roleFilter;
    return matchesSearch && matchesRole;
  });

  return (
    <>
      <Header title="Member Management" subtitle={`${mockUsers.length} registered members`} />
      <div className="p-8">
        {/* Toolbar */}
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6">
          <div className="flex items-center gap-3 w-full sm:w-auto">
            <div className="flex items-center gap-2 bg-white rounded-lg px-3 py-2 flex-1 sm:w-72" style={{ border: "1px solid #E0E2E7" }}>
              <Search size={16} style={{ color: "#636C7A" }} />
              <input
                type="text"
                placeholder="Search by name, email, or flat..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="bg-transparent text-sm outline-none w-full placeholder:text-[#636C7A]"
                style={{ color: "#2C2F33" }}
              />
            </div>
            <div className="flex items-center gap-1 bg-white rounded-lg px-2 py-1" style={{ border: "1px solid #E0E2E7" }}>
              {["all", "chairman", "secretary", "treasurer", "member"].map((role) => (
                <button
                  key={role}
                  onClick={() => setRoleFilter(role)}
                  className="px-3 py-1.5 rounded-md text-xs font-medium transition-all capitalize"
                  style={roleFilter === role ? { backgroundColor: "#0F2040", color: "#FFFFFF" } : { color: "#636C7A" }}
                >
                  {role}
                </button>
              ))}
            </div>
          </div>
          <button className="flex items-center gap-2 text-white px-4 py-2.5 rounded-lg text-sm font-medium transition-colors" style={{ backgroundColor: "#0F2040" }} onMouseOver={(e) => (e.currentTarget.style.backgroundColor = "#1E3A66")} onMouseOut={(e) => (e.currentTarget.style.backgroundColor = "#0F2040")}>
            <UserPlus size={16} />
            Add Member
          </button>
        </div>

        {/* Table */}
        <div className="bg-white rounded-xl overflow-hidden" style={{ border: "1px solid #E0E2E7" }}>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr style={{ backgroundColor: "#F8F9FB", borderBottom: "1px solid #E0E2E7" }}>
                  <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Member</th>
                  <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Flat</th>
                  <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Contact</th>
                  <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Role</th>
                  <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Status</th>
                  <th className="text-right text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filtered.map((user) => (
                  <tr key={user.uid} className="hover:bg-slate-50/50 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-9 h-9 rounded-full flex items-center justify-center text-white text-xs font-bold" style={{ background: "linear-gradient(135deg, #0F2040, #1E3A66)" }}>
                          {user.name.split(" ").map((n) => n[0]).join("").slice(0, 2)}
                        </div>
                        <div>
                          <p className="text-sm font-semibold" style={{ color: "#0F2040" }}>{user.name}</p>
                          <p className="text-xs" style={{ color: "#636C7A" }}>{user.email}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-1.5">
                        <Home size={13} style={{ color: "#636C7A" }} />
                        <span className="text-sm font-medium" style={{ color: "#2C2F33" }}>{user.flatNumber}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-1.5">
                        <Phone size={13} style={{ color: "#636C7A" }} />
                        <span className="text-sm" style={{ color: "#636C7A" }}>{user.phone}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className={cn("inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold capitalize", roleColors[user.role])}>
                        {user.role !== "member" && <Shield size={11} />}
                        {user.role}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <span className={cn(
                        "inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold"
                      )} style={user.status === "Active" ? { backgroundColor: "rgba(46,125,50,0.08)", color: "#2E7D32" } : { backgroundColor: "rgba(211,47,47,0.08)", color: "#D32F2F" }}>
                        <span className="w-1.5 h-1.5 rounded-full mr-1.5" style={{ backgroundColor: user.status === "Active" ? "#2E7D32" : "#D32F2F" }} />
                        {user.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <button className="p-1.5 rounded-lg hover:bg-slate-100 transition-colors">
                        <MoreHorizontal size={16} style={{ color: "#636C7A" }} />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <div className="px-6 py-3 flex items-center justify-between" style={{ backgroundColor: "#F8F9FB", borderTop: "1px solid #E0E2E7" }}>
            <p className="text-xs" style={{ color: "#636C7A" }}>Showing {filtered.length} of {mockUsers.length} members</p>
          </div>
        </div>
      </div>
    </>
  );
}
