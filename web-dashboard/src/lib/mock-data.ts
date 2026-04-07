// Mock data for demo/development — mirrors the Flutter MockData class
import type { User, Bill, Transaction, Expense, Notice, SocietyDocument, AuditLog } from "./types";

export const mockUsers: User[] = [
  { uid: "admin_1", name: "John Chairman", email: "chairman@society.com", phone: "9876543210", flatNumber: "A-001", role: "chairman", status: "Active", createdAt: "2024-01-01T10:00:00Z" },
  { uid: "admin_2", name: "Alice Secretary", email: "secretary@society.com", phone: "9876543211", flatNumber: "A-002", role: "secretary", status: "Active", createdAt: "2024-01-01T10:00:00Z" },
  { uid: "admin_3", name: "Bob Treasurer", email: "treasurer@society.com", phone: "9876543212", flatNumber: "A-003", role: "treasurer", status: "Active", createdAt: "2024-01-01T10:00:00Z" },
  { uid: "member_1", name: "Rajesh Sharma", email: "rajesh.sharma@gmail.com", phone: "9823456701", flatNumber: "A-101", role: "member", status: "Active", createdAt: "2024-02-01T10:00:00Z" },
  { uid: "member_2", name: "Priya Mehta", email: "priya.mehta@gmail.com", phone: "9823456702", flatNumber: "A-102", role: "member", status: "Active", createdAt: "2024-02-01T10:00:00Z" },
  { uid: "member_3", name: "Suresh Patil", email: "suresh.patil@gmail.com", phone: "9823456703", flatNumber: "A-103", role: "member", status: "Active", createdAt: "2024-02-01T10:00:00Z" },
  { uid: "member_4", name: "Anita Desai", email: "anita.desai@gmail.com", phone: "9823456704", flatNumber: "A-104", role: "member", status: "Active", createdAt: "2024-03-01T10:00:00Z" },
  { uid: "member_5", name: "Vikram Joshi", email: "vikram.joshi@gmail.com", phone: "9823456705", flatNumber: "B-101", role: "member", status: "Active", createdAt: "2024-03-01T10:00:00Z" },
  { uid: "member_6", name: "Kavita Nair", email: "kavita.nair@gmail.com", phone: "9823456706", flatNumber: "B-102", role: "member", status: "Active", createdAt: "2024-03-01T10:00:00Z" },
  { uid: "member_7", name: "Amit Kulkarni", email: "amit.kulkarni@gmail.com", phone: "9823456707", flatNumber: "B-103", role: "member", status: "Active", createdAt: "2024-04-01T10:00:00Z" },
  { uid: "member_8", name: "Sunita Rao", email: "sunita.rao@gmail.com", phone: "9823456708", flatNumber: "B-104", role: "member", status: "Active", createdAt: "2024-04-01T10:00:00Z" },
  { uid: "member_9", name: "Deepak Verma", email: "deepak.verma@gmail.com", phone: "9823456709", flatNumber: "C-101", role: "member", status: "Active", createdAt: "2024-05-01T10:00:00Z" },
  { uid: "member_10", name: "Pooja Iyer", email: "pooja.iyer@gmail.com", phone: "9823456710", flatNumber: "C-102", role: "member", status: "Active", createdAt: "2024-05-01T10:00:00Z" },
];

export const mockTransactions: Transaction[] = [
  { id: "tx_1", memberId: "member_1", billId: "bill_1", amount: 4500, paymentMode: "UPI", referenceNumber: "UPI123456789", receiptUrl: "", recordedBy: "admin_3", paidAt: "2025-01-15T10:00:00Z" },
  { id: "tx_2", memberId: "member_2", billId: "bill_2", amount: 4500, paymentMode: "Bank Transfer", referenceNumber: "NEFT789012", receiptUrl: "", recordedBy: "admin_3", paidAt: "2025-01-18T14:30:00Z" },
  { id: "tx_3", memberId: "member_3", billId: "bill_3", amount: 4500, paymentMode: "Cheque", referenceNumber: "CHQ654321", receiptUrl: "", recordedBy: "admin_3", paidAt: "2025-01-20T11:00:00Z" },
  { id: "tx_4", memberId: "member_5", billId: "bill_5", amount: 4500, paymentMode: "UPI", referenceNumber: "UPI567890", receiptUrl: "", recordedBy: "admin_3", paidAt: "2025-02-05T09:00:00Z" },
  { id: "tx_5", memberId: "member_7", billId: "bill_7", amount: 4500, paymentMode: "Cash", referenceNumber: "CASH001", receiptUrl: "", recordedBy: "admin_2", paidAt: "2025-02-10T16:00:00Z" },
  { id: "tx_6", memberId: "member_1", billId: "bill_11", amount: 4500, paymentMode: "UPI", referenceNumber: "UPI999888", receiptUrl: "", recordedBy: "admin_3", paidAt: "2025-02-15T10:30:00Z" },
  { id: "tx_7", memberId: "member_4", billId: "bill_4", amount: 4500, paymentMode: "Bank Transfer", referenceNumber: "NEFT445566", receiptUrl: "", recordedBy: "admin_3", paidAt: "2025-02-20T13:00:00Z" },
];

export const mockBills: Bill[] = [
  { id: "bill_1", memberId: "member_1", flatNumber: "A-101", month: 1, year: 2025, maintenanceAmount: 3000, otherCharges: 1500, totalAmount: 4500, paidAmount: 4500, status: "Paid", generatedAt: "2025-01-01T00:00:00Z", dueDate: "2025-01-25T00:00:00Z" },
  { id: "bill_2", memberId: "member_2", flatNumber: "A-102", month: 1, year: 2025, maintenanceAmount: 3000, otherCharges: 1500, totalAmount: 4500, paidAmount: 4500, status: "Paid", generatedAt: "2025-01-01T00:00:00Z", dueDate: "2025-01-25T00:00:00Z" },
  { id: "bill_3", memberId: "member_3", flatNumber: "A-103", month: 1, year: 2025, maintenanceAmount: 3000, otherCharges: 1500, totalAmount: 4500, paidAmount: 4500, status: "Paid", generatedAt: "2025-01-01T00:00:00Z", dueDate: "2025-01-25T00:00:00Z" },
  { id: "bill_4", memberId: "member_4", flatNumber: "A-104", month: 1, year: 2025, maintenanceAmount: 3000, otherCharges: 1500, totalAmount: 4500, paidAmount: 4500, status: "Paid", generatedAt: "2025-01-01T00:00:00Z", dueDate: "2025-01-25T00:00:00Z" },
  { id: "bill_5", memberId: "member_5", flatNumber: "B-101", month: 1, year: 2025, maintenanceAmount: 3000, otherCharges: 1500, totalAmount: 4500, paidAmount: 4500, status: "Paid", generatedAt: "2025-01-01T00:00:00Z", dueDate: "2025-01-25T00:00:00Z" },
  { id: "bill_6", memberId: "member_6", flatNumber: "B-102", month: 1, year: 2025, maintenanceAmount: 3000, otherCharges: 1500, totalAmount: 4500, paidAmount: 0, status: "Pending", generatedAt: "2025-01-01T00:00:00Z", dueDate: "2025-01-25T00:00:00Z" },
  { id: "bill_7", memberId: "member_7", flatNumber: "B-103", month: 1, year: 2025, maintenanceAmount: 3000, otherCharges: 1500, totalAmount: 4500, paidAmount: 4500, status: "Paid", generatedAt: "2025-01-01T00:00:00Z", dueDate: "2025-01-25T00:00:00Z" },
  { id: "bill_8", memberId: "member_8", flatNumber: "B-104", month: 2, year: 2025, maintenanceAmount: 3000, otherCharges: 1500, totalAmount: 4500, paidAmount: 0, status: "Pending", generatedAt: "2025-02-01T00:00:00Z", dueDate: "2025-02-25T00:00:00Z" },
  { id: "bill_9", memberId: "member_9", flatNumber: "C-101", month: 2, year: 2025, maintenanceAmount: 3000, otherCharges: 1500, totalAmount: 4500, paidAmount: 0, status: "Overdue", generatedAt: "2025-02-01T00:00:00Z", dueDate: "2025-02-25T00:00:00Z" },
  { id: "bill_10", memberId: "member_10", flatNumber: "C-102", month: 2, year: 2025, maintenanceAmount: 3000, otherCharges: 1500, totalAmount: 4500, paidAmount: 0, status: "Pending", generatedAt: "2025-02-01T00:00:00Z", dueDate: "2025-02-25T00:00:00Z" },
];

export const mockExpenses: Expense[] = [
  { id: "EXP-001", category: "Electricity Bill", description: "Common area electricity bill for January 2025", amount: 8500, paymentMode: "Bank Transfer", vendor: "MSEDCL", voucherDocId: "", recordedBy: "Alice Secretary", expenseDate: "2025-01-15T00:00:00Z" },
  { id: "EXP-002", category: "Plumbing Work", description: "Underground water tank repair and pipe leakage fix", amount: 12000, paymentMode: "Cash", vendor: "Sharma Plumbing Services", voucherDocId: "", recordedBy: "Alice Secretary", expenseDate: "2025-01-20T00:00:00Z" },
  { id: "EXP-003", category: "Security Services", description: "Security guard salary for January 2025", amount: 15000, paymentMode: "UPI", vendor: "Rajesh Kumar (Watchman)", voucherDocId: "", recordedBy: "Bob Treasurer", expenseDate: "2025-01-31T00:00:00Z" },
  { id: "EXP-004", category: "Pest Control", description: "Quarterly pest control treatment for all floors", amount: 6500, paymentMode: "Cheque", vendor: "PestFree Solutions Pvt Ltd", voucherDocId: "", recordedBy: "Alice Secretary", expenseDate: "2025-02-05T00:00:00Z" },
  { id: "EXP-005", category: "Lift Maintenance", description: "Lift AMC payment Q1 2025 - 2 lifts", amount: 25000, paymentMode: "Bank Transfer", vendor: "ThyssenKrupp Elevator India", voucherDocId: "", recordedBy: "Alice Secretary", expenseDate: "2025-02-10T00:00:00Z" },
  { id: "EXP-006", category: "Garden Maintenance", description: "Monthly gardening and landscaping", amount: 4000, paymentMode: "Cash", vendor: "Green Gardens Co.", voucherDocId: "", recordedBy: "Bob Treasurer", expenseDate: "2025-02-15T00:00:00Z" },
  { id: "EXP-007", category: "Water Supply", description: "Tanker water for February shortage", amount: 3500, paymentMode: "UPI", vendor: "AquaSupply Services", voucherDocId: "", recordedBy: "Alice Secretary", expenseDate: "2025-02-18T00:00:00Z" },
];

export const mockNotices: Notice[] = [
  { id: "n1", title: "Annual General Meeting", body: "The Annual General Meeting of the society will be held on 25th March 2026 at the Society Clubhouse. All members are requested to attend.", status: "Published", attachmentDocIds: [], postedBy: "Secretary", createdAt: "2026-03-01T10:00:00Z", publishedAt: "2026-03-01T10:00:00Z" },
  { id: "n2", title: "Water Supply Maintenance", body: "The water supply will be suspended on 22nd February 2026 from 10:00 AM to 4:00 PM for cleaning and maintenance of the overhead tanks.", status: "Published", attachmentDocIds: [], postedBy: "Secretary", createdAt: "2026-02-18T10:00:00Z", publishedAt: "2026-02-18T10:00:00Z" },
  { id: "n3", title: "Security Drill Notification", body: "A fire safety drill is scheduled for 5th March 2026 at 11:00 AM. This drill is mandatory for all residents.", status: "Published", attachmentDocIds: [], postedBy: "Security Chief", createdAt: "2026-02-25T10:00:00Z", publishedAt: "2026-02-25T10:00:00Z" },
  { id: "n4", title: "Republic Day Celebration (Draft)", body: "Flag hoisting ceremony will be held at 9 AM in the main ground.", status: "Draft", attachmentDocIds: [], postedBy: "Chairman", createdAt: "2026-01-20T10:00:00Z", publishedAt: "" },
  { id: "n5", title: "Lift Painting Schedule", body: "Lifts will be painted on 10th and 11th March. Please use stairs.", status: "Draft", attachmentDocIds: [], postedBy: "Maintenance Manager", createdAt: "2026-03-05T10:00:00Z", publishedAt: "" },
];

export const mockDocuments: SocietyDocument[] = [
  { id: "doc_1", fileName: "AGM_2024_Minutes.pdf", fileType: "PDF", storageUrl: "", linkedTo: "notices", linkedId: "n1", category: "AGM Minutes", uploadedBy: "Secretary", uploadedAt: "2024-07-15T10:00:00Z" },
  { id: "doc_2", fileName: "Audit_Report_2023.pdf", fileType: "PDF", storageUrl: "", linkedTo: "", linkedId: "", category: "Audit Reports", uploadedBy: "Chairman", uploadedAt: "2024-03-01T10:00:00Z" },
  { id: "doc_3", fileName: "Annual_Report_2024.pdf", fileType: "PDF", storageUrl: "", linkedTo: "", linkedId: "", category: "Annual Reports", uploadedBy: "Treasurer", uploadedAt: "2024-12-15T10:00:00Z" },
  { id: "doc_4", fileName: "Circular_Water_Maintenance.pdf", fileType: "PDF", storageUrl: "", linkedTo: "notices", linkedId: "n2", category: "Circulars", uploadedBy: "Secretary", uploadedAt: "2026-02-18T10:00:00Z" },
];

export const mockAuditLogs: AuditLog[] = [
  { id: "log_1", actorId: "admin_2", actorRole: "secretary", action: "ADD_MEMBER", targetCollection: "users", targetId: "member_1", timestamp: "2024-02-01T10:00:00Z" },
  { id: "log_2", actorId: "admin_3", actorRole: "treasurer", action: "RECORD_PAYMENT", targetCollection: "transactions", targetId: "tx_1", timestamp: "2025-01-15T10:00:00Z" },
  { id: "log_3", actorId: "admin_2", actorRole: "secretary", action: "RECORD_EXPENSE", targetCollection: "expenses", targetId: "EXP-001", timestamp: "2025-01-15T10:30:00Z" },
  { id: "log_4", actorId: "admin_1", actorRole: "chairman", action: "GENERATE_BILLS", targetCollection: "bills", targetId: "bill_1", timestamp: "2025-01-01T09:00:00Z" },
  { id: "log_5", actorId: "admin_2", actorRole: "secretary", action: "POST_NOTICE", targetCollection: "notices", targetId: "n1", timestamp: "2026-03-01T10:00:00Z" },
  { id: "log_6", actorId: "admin_2", actorRole: "secretary", action: "UPLOAD_DOCUMENT", targetCollection: "documents", targetId: "doc_1", timestamp: "2024-07-15T10:00:00Z" },
  { id: "log_7", actorId: "admin_3", actorRole: "treasurer", action: "RECORD_PAYMENT", targetCollection: "transactions", targetId: "tx_2", timestamp: "2025-01-18T14:30:00Z" },
  { id: "log_8", actorId: "admin_2", actorRole: "secretary", action: "RECORD_EXPENSE", targetCollection: "expenses", targetId: "EXP-005", timestamp: "2025-02-10T09:00:00Z" },
  { id: "log_9", actorId: "admin_1", actorRole: "chairman", action: "DEACTIVATE_MEMBER", targetCollection: "users", targetId: "member_12", timestamp: "2025-03-01T11:00:00Z" },
  { id: "log_10", actorId: "admin_2", actorRole: "secretary", action: "EDIT_MEMBER", targetCollection: "users", targetId: "member_5", timestamp: "2025-03-05T14:00:00Z" },
];
