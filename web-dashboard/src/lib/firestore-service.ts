import { 
  collection, 
  query, 
  onSnapshot, 
  orderBy, 
  limit, 
  doc, 
  updateDoc, 
  addDoc,
  Timestamp 
} from "firebase/firestore";
import { db } from "./firebase";
import type { User, Transaction, Expense, Notice, AuditLog, SocietyDocument } from "./types";

/**
 * Real-time listener for the members list
 */
export function subscribeToMembers(callback: (members: User[]) => void) {
  const q = query(collection(db, "users"), orderBy("flatNumber", "asc"));
  return onSnapshot(q, (snapshot) => {
    const members = snapshot.docs.map(doc => ({ uid: doc.id, ...doc.data() } as User));
    callback(members);
  });
}

/**
 * Real-time listener for transactions
 */
export function subscribeToTransactions(callback: (transactions: Transaction[]) => void) {
  const q = query(collection(db, "transactions"), orderBy("paidAt", "desc"), limit(100));
  return onSnapshot(q, (snapshot) => {
    const transactions = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Transaction));
    callback(transactions);
  });
}

/**
 * Real-time listener for bills
 */
export function subscribeToBills(callback: (bills: any[]) => void) {
  const q = query(collection(db, "bills"), orderBy("dueDate", "desc"));
  return onSnapshot(q, (snapshot) => {
    const bills = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    callback(bills);
  });
}

/**
 * Real-time listener for expenses
 */
export function subscribeToExpenses(callback: (expenses: Expense[]) => void) {
  const q = query(collection(db, "expenses"), orderBy("expenseDate", "desc"));
  return onSnapshot(q, (snapshot) => {
    const expenses = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Expense));
    callback(expenses);
  });
}

/**
 * Real-time listener for notices
 */
export function subscribeToNotices(callback: (notices: Notice[]) => void) {
  const q = query(collection(db, "notices"), orderBy("createdAt", "desc"));
  return onSnapshot(q, (snapshot) => {
    const notices = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Notice));
    callback(notices);
  });
}

/**
 * Real-time listener for documents
 */
export function subscribeToDocuments(callback: (documents: SocietyDocument[]) => void) {
  const q = query(collection(db, "documents"), orderBy("uploadedAt", "desc"));
  return onSnapshot(q, (snapshot) => {
    const docs = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as SocietyDocument));
    callback(docs);
  });
}

/**
 * Real-time listener for audit logs
 */
export function subscribeToAuditLogs(callback: (logs: AuditLog[]) => void) {
  const q = query(collection(db, "audit_logs"), orderBy("timestamp", "desc"), limit(50));
  return onSnapshot(q, (snapshot) => {
    const logs = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as AuditLog));
    callback(logs);
  });
}

/**
 * Update member status (example write operation)
 */
export async function updateMemberStatus(uid: string, status: string) {
  const userRef = doc(db, "users", uid);
  await updateDoc(userRef, { status });
}

/**
 * Post a new notice (example write operation)
 */
export async function postNotice(notice: Omit<Notice, 'id'>) {
  await addDoc(collection(db, "notices"), {
    ...notice,
    createdAt: new Date().toISOString(),
    publishedAt: notice.status === 'Published' ? new Date().toISOString() : ''
  });
}
