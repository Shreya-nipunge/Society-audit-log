"use client";
import { Header } from "@/components/Header";
import { mockUsers } from "@/lib/mock-data";
import { Search, Filter, UserPlus, MoreHorizontal, Mail, Phone, Home, Shield } from "lucide-react";
import { useState } from "react";
import { cn } from "@/lib/utils";

const roleColors: Record<string, string> = {
  chairman: "bg-purple-100 text-purple-700",
  secretary: "bg-blue-100 text-blue-700",
  treasurer: "bg-emerald-100 text-emerald-700",
  member: "bg-slate-100 text-slate-600",
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
            <div className="flex items-center gap-2 bg-white border border-slate-200 rounded-lg px-3 py-2 flex-1 sm:w-72">
              <Search size={16} className="text-slate-400" />
              <input
                type="text"
                placeholder="Search by name, email, or flat..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="bg-transparent text-sm outline-none w-full"
              />
            </div>
            <div className="flex items-center gap-1 bg-white border border-slate-200 rounded-lg px-2 py-1">
              {["all", "chairman", "secretary", "treasurer", "member"].map((role) => (
                <button
                  key={role}
                  onClick={() => setRoleFilter(role)}
                  className={cn(
                    "px-3 py-1.5 rounded-md text-xs font-medium transition-all capitalize",
                    roleFilter === role ? "bg-indigo-100 text-indigo-700" : "text-slate-500 hover:bg-slate-50"
                  )}
                >
                  {role}
                </button>
              ))}
            </div>
          </div>
          <button className="flex items-center gap-2 bg-indigo-600 text-white px-4 py-2.5 rounded-lg text-sm font-medium hover:bg-indigo-700 transition-colors">
            <UserPlus size={16} />
            Add Member
          </button>
        </div>

        {/* Table */}
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-200">
                  <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Member</th>
                  <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Flat</th>
                  <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Contact</th>
                  <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Role</th>
                  <th className="text-left text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Status</th>
                  <th className="text-right text-xs font-semibold text-slate-500 uppercase tracking-wider px-6 py-3">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filtered.map((user) => (
                  <tr key={user.uid} className="hover:bg-slate-50/50 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-9 h-9 rounded-full bg-gradient-to-br from-indigo-400 to-purple-500 flex items-center justify-center text-white text-xs font-bold">
                          {user.name.split(" ").map((n) => n[0]).join("").slice(0, 2)}
                        </div>
                        <div>
                          <p className="text-sm font-semibold text-slate-800">{user.name}</p>
                          <p className="text-xs text-slate-400">{user.email}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-1.5">
                        <Home size={13} className="text-slate-400" />
                        <span className="text-sm font-medium text-slate-700">{user.flatNumber}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-1.5">
                        <Phone size={13} className="text-slate-400" />
                        <span className="text-sm text-slate-600">{user.phone}</span>
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
                        "inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold",
                        user.status === "Active" ? "bg-emerald-50 text-emerald-700" : "bg-red-50 text-red-600"
                      )}>
                        <span className={cn("w-1.5 h-1.5 rounded-full mr-1.5", user.status === "Active" ? "bg-emerald-500" : "bg-red-500")} />
                        {user.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <button className="p-1.5 rounded-lg hover:bg-slate-100 transition-colors">
                        <MoreHorizontal size={16} className="text-slate-400" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <div className="px-6 py-3 bg-slate-50 border-t border-slate-200 flex items-center justify-between">
            <p className="text-xs text-slate-500">Showing {filtered.length} of {mockUsers.length} members</p>
          </div>
        </div>
      </div>
    </>
  );
}
