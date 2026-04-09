"use client";
import React from "react";
import { Header } from "@/components/Header";
import { Search, UserPlus, MoreHorizontal, Home, Shield } from "lucide-react";
import { useState, useEffect } from "react";
import { cn } from "@/lib/utils";
import { MemberModal } from "@/components/MemberModal";
import { User } from "@/lib/types";
import { subscribeToMembers } from "@/lib/firestore-service";

const roleColors: Record<string, string> = {
  chairman: "bg-[#D32F2F]/10 text-[#D32F2F]",
  secretary: "bg-[#0288D1]/10 text-[#0288D1]",
  treasurer: "bg-[#C5A065]/10 text-[#967635]",
  member: "bg-[#0F2040]/5 text-[#0F2040]",
};

import { useAuth } from "@/lib/auth";

export default function MembersPage() {
  const { user, loading: authLoading } = useAuth();
  const [search, setSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState("all");
  const [users, setUsers] = useState<User[]>([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [expandedRow, setExpandedRow] = useState<string | null>(null);

  useEffect(() => {
    if (!user || authLoading) return;
    const unsub = subscribeToMembers(setUsers);
    return () => unsub();
  }, [user, authLoading]);

  const toggleRow = (uid: string) => {
    setExpandedRow(expandedRow === uid ? null : uid);
  };

  const filtered = users.filter((u) => {
    if (u.role !== "member") return false; // Hide officials from this list
    const matchesSearch = u.name.toLowerCase().includes(search.toLowerCase()) ||
      u.email.toLowerCase().includes(search.toLowerCase()) ||
      u.flatNumber.toLowerCase().includes(search.toLowerCase());
    const matchesRole = roleFilter === "all" || u.role === roleFilter;
    return matchesSearch && matchesRole;
  });

  const handleAddMember = async (member: any) => {
    // Simulate network delay for realistic feel
    await new Promise(resolve => setTimeout(resolve, 500));
    setUsers(prev => [member, ...prev]);
  };

  return (
    <>
      <Header title="Member Management" subtitle={`${filtered.length} registered members`} />
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
          <button onClick={() => setIsModalOpen(true)} className="flex items-center gap-2 text-white px-4 py-2.5 rounded-lg text-sm font-medium transition-colors" style={{ backgroundColor: "#0F2040" }} onMouseOver={(e) => (e.currentTarget.style.backgroundColor = "#1E3A66")} onMouseOut={(e) => (e.currentTarget.style.backgroundColor = "#0F2040")}>
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
                  <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Role</th>
                  <th className="text-left text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Status</th>
                  <th className="text-right text-xs font-semibold uppercase tracking-wider px-6 py-3" style={{ color: "#636C7A" }}>Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filtered.map((user) => (
                  <React.Fragment key={user.uid}>
                    <tr
                      className={cn(
                        "hover:bg-slate-50/50 transition-colors cursor-pointer",
                        expandedRow === user.uid && "bg-[#F8F9FB]/50"
                      )}
                      onClick={() => toggleRow(user.uid)}
                    >
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          <div
                            className="w-9 h-9 rounded-full flex items-center justify-center text-white text-xs font-bold"
                            style={{
                              background: "linear-gradient(135deg, #0F2040, #1E3A66)",
                            }}
                          >
                            {user.name.split(" ").map((n) => n[0]).join("").slice(0, 2)}
                          </div>
                          <div>
                            <p className="text-sm font-semibold" style={{ color: "#0F2040" }}>
                              {user.name}
                            </p>
                            <p className="text-xs" style={{ color: "#636C7A" }}>
                              {user.email}
                            </p>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-1.5">
                          <Home size={13} style={{ color: "#636C7A" }} />
                          <span className="text-sm font-medium" style={{ color: "#2C2F33" }}>
                            {user.flatNumber}
                          </span>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <span
                          className={cn(
                            "inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold capitalize",
                            roleColors[user.role]
                          )}
                        >
                          {user.role !== "member" && <Shield size={11} />}
                          {user.role}
                        </span>
                      </td>
                      <td className="px-6 py-4">
                        <span
                          className={cn(
                            "inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold"
                          )}
                          style={
                            user.status === "Active"
                              ? { backgroundColor: "rgba(46,125,50,0.08)", color: "#2E7D32" }
                              : { backgroundColor: "rgba(211,47,47,0.08)", color: "#D32F2F" }
                          }
                        >
                          <span
                            className="w-1.5 h-1.5 rounded-full mr-1.5"
                            style={{
                              backgroundColor:
                                user.status === "Active" ? "#2E7D32" : "#D32F2F",
                            }}
                          />
                          {user.status}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-right">
                        <div className="flex items-center justify-end gap-3">
                          <button 
                            onClick={(e) => {
                              e.stopPropagation();
                              toggleRow(user.uid);
                            }}
                            className="px-3 py-1.5 rounded-lg text-xs font-semibold transition-all border"
                            style={expandedRow === user.uid 
                              ? { backgroundColor: "#0F2040", color: "#FFFFFF", borderColor: "#0F2040" } 
                              : { borderColor: "#E0E2E7", color: "#636C7A" }}
                          >
                            {expandedRow === user.uid ? "Hide Details" : "View Details"}
                          </button>
                          <button className="p-1.5 rounded-lg hover:bg-slate-100 transition-colors">
                            <MoreHorizontal size={16} style={{ color: "#636C7A" }} />
                          </button>
                        </div>
                      </td>
                    </tr>
                    {expandedRow === user.uid && (
                      <tr key={`${user.uid}-details`} className="bg-[#F8F9FB]/30">
                        <td colSpan={5} className="px-8 py-6 border-b border-slate-100">
                          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                            {/* Society Ledger (B-O) */}
                            <div>
                              <h4 className="text-xs font-bold uppercase tracking-wider text-[#636C7A] mb-4">
                                Society Ledger (B-O)
                              </h4>
                              <div className="bg-white rounded-lg p-4 border border-slate-100 shadow-sm">
                                <div className="space-y-2">
                                  {[
                                    ["Opening Balance (1-Apr)", user.openingBalance],
                                    ["Sinking Fund", user.sinkingFund],
                                    ["Maintenance", user.maintenanceAmount],
                                    ["Municipal Tax", user.municipalTax],
                                    ["NOC", user.noc],
                                    ["Parking Charges", user.parkingCharges],
                                    ["Delay Charges", user.delayCharges],
                                    ["Building Fund", user.buildingFund],
                                    ["Room Transfer Fees", user.roomTransferFees],
                                  ].map(([label, value]) => (
                                    <div
                                      key={label as string}
                                      className="flex justify-between text-xs"
                                    >
                                      <span style={{ color: "#636C7A" }}>{label}</span>
                                      <span className="font-medium" style={{ color: "#2C2F33" }}>
                                        ₹{(value as number || 0).toLocaleString()}
                                      </span>
                                    </div>
                                  ))}
                                  <div className="pt-2 mt-2 border-t border-slate-100 space-y-2">
                                    <div className="flex justify-between text-xs font-bold">
                                      <span style={{ color: "#0F2040" }}>Total Receivable</span>
                                      <span style={{ color: "#0F2040" }}>
                                        ₹{(user.totalReceivable || 0).toLocaleString()}
                                      </span>
                                    </div>
                                    <div className="flex justify-between text-xs font-bold">
                                      <span style={{ color: "#2E7D32" }}>Total Received</span>
                                      <span style={{ color: "#2E7D32" }}>
                                        ₹{(user.totalReceived || 0).toLocaleString()}
                                      </span>
                                    </div>
                                    <div className="flex justify-between text-xs font-bold border-t border-slate-100 pt-2">
                                      <span style={{ color: "#D32F2F" }}>
                                        Closing Balance (31-Mar)
                                      </span>
                                      <span style={{ color: "#D32F2F" }}>
                                        ₹{(user.closingBalance || 0).toLocaleString()}
                                      </span>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </div>

                            {/* Charges Types (Q-S) */}
                            <div>
                              <h4 className="text-xs font-bold uppercase tracking-wider text-[#636C7A] mb-4">
                                Charges Types (Q-S)
                              </h4>
                              <div className="grid grid-cols-3 gap-3">
                                {[
                                  {
                                    label: "Fixed Monthly",
                                    value: user.fixedMonthlyCharges,
                                    color: "#0F2040",
                                  },
                                  {
                                    label: "Annual Fees",
                                    value: user.annualCharges,
                                    color: "#C5A065",
                                  },
                                  {
                                    label: "Variable",
                                    value: user.variableCharges,
                                    color: "#6366F1",
                                  },
                                ].map((item) => (
                                  <div
                                    key={item.label}
                                    className="p-3 rounded-xl border flex flex-col items-center justify-center text-center transition-all bg-white"
                                    style={{
                                      borderColor: `${item.color}15`,
                                      backgroundColor: `${item.color}05`,
                                    }}
                                  >
                                    <p
                                      className="text-[10px] font-bold uppercase mb-1"
                                      style={{ color: item.color }}
                                    >
                                      {item.label}
                                    </p>
                                    <p className="text-sm font-bold" style={{ color: item.color }}>
                                      ₹{(item.value || 0).toLocaleString()}
                                    </p>
                                  </div>
                                ))}
                              </div>
                            </div>
                          </div>
                        </td>
                      </tr>
                    )}
                  </React.Fragment>
                ))}
              </tbody>
            </table>
          </div>
          <div className="px-6 py-3 flex items-center justify-between" style={{ backgroundColor: "#F8F9FB", borderTop: "1px solid #E0E2E7" }}>
            <p className="text-xs" style={{ color: "#636C7A" }}>Showing {filtered.length} of {users.length} members</p>
          </div>
        </div>
      </div>
      <MemberModal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} onAdd={handleAddMember} />
    </>
  );
}
