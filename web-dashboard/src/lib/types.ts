// Firestore ERD types — exactly matching the schema
export interface User {
  uid: string;
  name: string;
  email: string;
  phone: string;
  flatNumber: string;
  role: "chairman" | "secretary" | "treasurer" | "member";
  status: string;
  password?: string;
  createdAt: string | Date;

  // Ledger Data (B-O)
  openingBalance: number;
  sinkingFund: number;
  maintenanceAmount: number;
  municipalTax: number;
  noc: number;
  parkingCharges: number;
  delayCharges: number;
  buildingFund: number;
  roomTransferFees: number;
  totalReceivable: number;
  totalReceived: number;
  closingBalance: number;

  // Charges Types (Q-S)
  fixedMonthlyCharges: number;
  annualCharges: number;
  variableCharges: number;
}

export interface Bill {
  id: string;
  memberId: string;
  flatNumber: string;
  month: number;
  year: number;
  maintenanceAmount: number;
  otherCharges: number;
  totalAmount: number;
  paidAmount: number;
  status: string;
  generatedAt: string | Date;
  dueDate: string | Date;
}

export interface Transaction {
  id: string;
  memberId: string;
  memberName: string;
  billId?: string;
  amount: number;
  paymentMode: string;
  referenceNumber: string;
  receiptUrl?: string;
  recordedBy: string;
  paidAt: string | Date;
}

export interface Expense {
  id: string;
  category: string;
  description: string;
  amount: number;
  paymentMode: string;
  vendor: string;
  voucherDocId: string;
  recordedBy: string;
  expenseDate: string | Date;
}

export interface Notice {
  id: string;
  title: string;
  body: string;
  status: string;
  attachmentDocIds: string[];
  postedBy: string;
  createdAt: string | Date;
  publishedAt: string | Date;
}

export interface SocietyDocument {
  id: string;
  fileName: string;
  fileType: string;
  storageUrl: string;
  linkedTo: string;
  linkedId: string;
  category: string;
  uploadedBy: string;
  uploadedAt: string | Date;
}

export interface AuditLog {
  id: string;
  actorId: string;
  actorRole: string;
  action: string;
  targetCollection: string;
  targetId: string;
  timestamp: string | Date;
}
