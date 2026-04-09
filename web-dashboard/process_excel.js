const fs = require('fs');

let rawContent = fs.readFileSync('./parsed_members_utf8.json', 'utf8');
if (rawContent.charCodeAt(0) === 0xFEFF) {
  rawContent = rawContent.slice(1);
}
const rawData = JSON.parse(rawContent);

// Filter out header and TOTAL rows
const membersData = rawData.filter(row => 
    row.__EMPTY_2 && 
    row.__EMPTY_2 !== 'Name' && 
    row.__EMPTY_1 !== 'TOTAL' && 
    !row.__EMPTY_2.includes('SHIVKRUPASAGAR') &&
    row.__EMPTY_1 !== 'Room No.'
);

const usersForMobile = [];
const usersForWeb = [];
const mockTransactions = [];
const mockBills = [];
const mockAuditLogs = [];

// Master Admin for Web Application
usersForWeb.push({
    uid: "web_master_admin",
    name: "Society Admin",
    email: "admin@society.com",
    password: "admin123",
    role: "secretary", 
    status: "Active",
    flatNumber: "MASTER",
    phone: "9100000000",
    createdAt: new Date().toISOString(),
    openingBalance: 0,
    sinkingFund: 0,
    maintenanceAmount: 0,
    municipalTax: 0,
    noc: 0,
    parkingCharges: 0,
    delayCharges: 0,
    buildingFund: 0,
    roomTransferFees: 0,
    totalReceivable: 0,
    totalReceived: 0,
    closingBalance: 0,
    fixedMonthlyCharges: 0,
    annualCharges: 0,
    variableCharges: 0,
});

const committeeRoles = ["Chairman", "Secretary", "Treasurer"];

membersData.forEach((row, index) => {
    const rawName = (row.__EMPTY_2 || "").trim().replace(/\r?\n|\r/g, ' ');
    const nameParts = rawName.split(/\s+/);
    const firstName = nameParts[0].toLowerCase().replace(/[^a-z]/g, '');
    const lastName = nameParts[nameParts.length - 1].toLowerCase().replace(/[^a-z]/g, '');
    
    let email = `${firstName}${lastName}@gmail.com`;
    let password = `${firstName}123`;
    let role = "member";
    let uidMobile = `member_${index + 1}`;
    let uidWeb = `web_member_${index + 1}`;

    const totalReceivable = Number(row.__EMPTY_12) || 0;
    const totalReceived = Number(row.__EMPTY_13) || 0;
    const flatNo = String(row.__EMPTY_1 || "").padStart(3, '0');

    // 1. Generate Bill if there's a receivable
    if (totalReceivable > 0) {
        mockBills.push({
            id: `bill-${index + 1}`,
            memberId: uidWeb,
            memberName: rawName,
            flatNumber: flatNo,
            month: 3, // March
            year: 2025,
            maintenanceAmount: Number(row.__EMPTY_5) || 0,
            otherCharges: totalReceivable - (Number(row.__EMPTY_5) || 0),
            totalAmount: totalReceivable,
            paidAmount: totalReceived > totalReceivable ? totalReceivable : totalReceived,
            dueDate: "2025-03-31T23:59:59Z",
            status: totalReceived >= totalReceivable ? "Paid" : "Overdue",
            createdAt: "2025-03-01T10:00:00Z"
        });
    }

    // 2. Generate Transaction if there's received amount
    if (totalReceived > 0) {
        const recorderRole = committeeRoles[index % 3]; // Vary recorder
        mockTransactions.push({
            id: `tx-${index + 1}`,
            memberId: uidWeb,
            memberName: rawName,
            amount: totalReceived,
            paymentMode: "UPI",
            status: "Completed",
            referenceNumber: `REF${Date.now()}${index}`,
            paidAt: "2025-03-15T14:30:00Z",
            recordedBy: recorderRole
        });

        // Add to audit log
        if (mockAuditLogs.length < 20) {
            mockAuditLogs.push({
                id: `log-${Date.now()}-${index}`,
                action: "PAYMENT_RECEIVED",
                actorId: "system",
                actorRole: recorderRole,
                targetId: uidWeb,
                targetCollection: "members",
                timestamp: "2025-03-15T14:30:00Z",
                details: `Payment of ₹${totalReceived} received from ${rawName} (${flatNo})`
            });
        }
    }

    const commonData = {
        name: rawName,
        phone: "9100000000", 
        flatNumber: flatNo,
        status: "Active",
        createdAt: new Date().toISOString(),
        openingBalance: Number(row.__EMPTY_3) || 0,
        sinkingFund: Number(row.__EMPTY_4) || 0,
        maintenanceAmount: Number(row.__EMPTY_5) || 0,
        municipalTax: Number(row.__EMPTY_6) || 0,
        noc: Number(row.__EMPTY_7) || 0,
        parkingCharges: Number(row.__EMPTY_8) || 0,
        delayCharges: Number(row.__EMPTY_9) || 0,
        buildingFund: Number(row.__EMPTY_10) || 0,
        roomTransferFees: Number(row.__EMPTY_11) || 0,
        totalReceivable: totalReceivable,
        totalReceived: totalReceived,
        closingBalance: Number(row.__EMPTY_14) || 0,
        fixedMonthlyCharges: Number(row.__EMPTY_16) || 0,
        annualCharges: Number(row.__EMPTY_17) || 0,
        variableCharges: Number(row.__EMPTY_18) || 0,
    };

    // Mobile User Roles
    let mRole = "member";
    if (index === 0) mRole = "chairman";
    else if (index === 1) mRole = "secretary";
    else if (index === 2) mRole = "treasurer";

    usersForMobile.push({
        ...commonData,
        uid: uidMobile,
        email: (index < 3) ? (index === 0 ? "chairman@society.com" : index === 1 ? "secretary@society.com" : "treasurer@society.com") : email,
        password: (index < 3) ? "123456" : password,
        role: mRole
    });

    usersForWeb.push({
        ...commonData,
        uid: uidWeb,
        email: email,
        password: password,
        role: "member"
    });
});

// Sample Expenses with correct field names for Web UI
const mockExpenses = [
    { id: "exp-1", description: "Common Area Electricity", amount: 12500, category: "Utility", expenseDate: "2025-03-20T10:00:00Z", status: "Paid", vendor: "MSEDCL", paymentMode: "Bank Transfer", recordedBy: "Treasurer" },
    { id: "exp-2", description: "Security Services (Mar 2025)", amount: 45000, category: "Service", expenseDate: "2025-03-31T18:00:00Z", status: "Paid", vendor: "Z-Security Agency", paymentMode: "Cheque", recordedBy: "Secretary" },
    { id: "exp-3", description: "Water Tank Cleaning", amount: 8500, category: "Maintenance", expenseDate: "2025-03-05T11:00:00Z", status: "Paid", vendor: "FreshWater Services", paymentMode: "Cash", recordedBy: "Chairman" },
    { id: "exp-4", description: "Garden Maintenance", amount: 6000, category: "Maintenance", expenseDate: "2025-03-12T16:00:00Z", status: "Paid", vendor: "GreenCare Plumbers", paymentMode: "UPI", recordedBy: "Secretary" },
    { id: "exp-5", description: "Miscellaneous Stationery", amount: 1200, category: "Office", expenseDate: "2025-03-25T13:00:00Z", status: "Paid", vendor: "Local Store", paymentMode: "Cash", recordedBy: "Treasurer" }
];

// Add expense logs to audit
mockExpenses.forEach(exp => {
    mockAuditLogs.push({
        id: `aud-exp-${exp.id}`,
        action: "EXPENSE_RECORDED",
        actorId: "system",
        actorRole: exp.recordedBy,
        targetId: exp.id,
        targetCollection: "expenses",
        timestamp: exp.expenseDate,
        details: `${exp.description} of ₹${exp.amount} recorded.`
    });
});

// 1. Generate TS for Web Dashboard
const tsCode = `// Generated from parsed_members_utf8.json
import type { User, Transaction, Expense, Notice, SocietyDocument, AuditLog } from "./types";

export const mockUsers: User[] = ${JSON.stringify(usersForWeb, null, 2)};
export const mockTransactions: Transaction[] = ${JSON.stringify(mockTransactions, null, 2)};
export const mockBills: any[] = ${JSON.stringify(mockBills, null, 2)};
export const mockExpenses: Expense[] = ${JSON.stringify(mockExpenses, null, 2)};
export const mockAuditLogs: AuditLog[] = ${JSON.stringify(mockAuditLogs, null, 2)};
export const mockNotices: Notice[] = [
  {
    id: "notice-1",
    title: "Annual General Body Meeting (AGM) 2025",
    body: "All members are requested to attend the Annual General Body Meeting scheduled for Sunday, 20th April 2025 at 10:00 AM in the society clubhouse. The agenda includes financial auditing, upcoming maintenance plans, and committee elections.",
    status: "Published",
    attachmentDocIds: [],
    postedBy: "Pradnya S. Abhyankar",
    createdAt: "2025-03-25T10:00:00Z",
    publishedAt: "2025-03-25T14:00:00Z"
  },
  {
    id: "notice-2",
    title: "Terrace Waterproofing Work - Scheduling",
    body: "Repair and waterproofing work on the terrace of Wing A will commence on 1st April 2025. Residents are requested to avoid going to the terrace for the duration of the work. We appreciate your cooperation.",
    status: "Published",
    attachmentDocIds: [],
    postedBy: "Rajesh G. Shingare",
    createdAt: "2025-03-20T09:30:00Z",
    publishedAt: "2025-03-20T11:00:00Z"
  },
  {
    id: "notice-3",
    title: "Water Supply Interruption Notice",
    body: "Due to urgent pipeline maintenance by the Municipal Corporation, water supply will be interrupted on Wednesday, 27th March from 9:00 AM to 5:00 PM. Please store sufficient water for your needs.",
    status: "Draft",
    attachmentDocIds: [],
    postedBy: "Rajesh G. Shingare",
    createdAt: "2025-03-26T08:00:00Z",
    publishedAt: ""
  }
];
export const mockDocuments: SocietyDocument[] = [];
`;

fs.writeFileSync('./src/lib/mock-data.ts', tsCode);

// 2. Generate Dart for Flutter App
let dartCode = `// Generated Real Society Data
class RealSocietyData {
  static final List<Map<String, dynamic>> users = [
`;

usersForMobile.forEach(u => {
    const escapedName = u.name.replace(/'/g, "\\'");
    dartCode += `    {
      'uid': '${u.uid}',
      'name': '${escapedName}',
      'email': '${u.email}',
      'password': '${u.password}',
      'phone': '${u.phone}',
      'flatNumber': '${u.flatNumber}',
      'role': '${u.role}',
      'status': '${u.status}',
      'openingBalance': ${u.openingBalance},
      'sinkingFund': ${u.sinkingFund},
      'maintenanceAmount': ${u.maintenanceAmount},
      'municipalTax': ${u.municipalTax},
      'noc': ${u.noc},
      'parkingCharges': ${u.parkingCharges},
      'delayCharges': ${u.delayCharges},
      'buildingFund': ${u.buildingFund},
      'roomTransferFees': ${u.roomTransferFees},
      'totalReceivable': ${u.totalReceivable},
      'totalReceived': ${u.totalReceived},
      'closingBalance': ${u.closingBalance},
      'fixedMonthlyCharges': ${u.fixedMonthlyCharges},
      'annualCharges': ${u.annualCharges},
      'variableCharges': ${u.variableCharges},
    },\n`;
});

dartCode += `  ];
}
`;

fs.writeFileSync('../lib/core/utils/real_society_data.dart', dartCode);
console.log("Fixed Expenses fields & Varied Recorded By roles.");
