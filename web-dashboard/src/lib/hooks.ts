"use client";
import { useEffect, useState } from "react";
import { collection, onSnapshot, query, orderBy } from "firebase/firestore";
import { db } from "./firebase";
import type { User, Bill, Transaction, Expense, Notice, SocietyDocument, AuditLog } from "./types";

function useCollection<T>(collectionName: string, orderField?: string) {
  const [data, setData] = useState<T[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const colRef = collection(db, collectionName);
    const q = orderField ? query(colRef, orderBy(orderField, "desc")) : colRef;
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        const items = snapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        })) as T[];
        setData(items);
        setLoading(false);
      },
      (error) => {
        console.error(`Error listening to ${collectionName}:`, error);
        setLoading(false);
      }
    );
    return unsubscribe;
  }, [collectionName, orderField]);

  return { data, loading };
}

export function useUsers() {
  return useCollection<User>("users");
}

export function useBills() {
  return useCollection<Bill>("bills");
}

export function useTransactions() {
  return useCollection<Transaction>("transactions");
}

export function useExpenses() {
  return useCollection<Expense>("expenses");
}

export function useNotices() {
  return useCollection<Notice>("notices");
}

export function useDocuments() {
  return useCollection<SocietyDocument>("documents");
}

export function useAuditLogs() {
  return useCollection<AuditLog>("audit_logs");
}
