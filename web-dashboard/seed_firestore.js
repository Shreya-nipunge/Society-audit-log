const admin = require('firebase-admin');
const fs = require('fs');
require('dotenv').config({ path: '.env.local' });

// Check if service account file exists
const SERVICE_ACCOUNT_PATH = './serviceAccount.json';

if (!fs.existsSync(SERVICE_ACCOUNT_PATH)) {
  console.error("ERROR: 'serviceAccount.json' not found!");
  console.log("Please go to Firebase Console > Project Settings > Service Accounts.");
  console.log("Click 'Generate new private key' and save it as 'serviceAccount.json' in: " + __dirname);
  process.exit(1);
}

const serviceAccount = require(SERVICE_ACCOUNT_PATH);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();

async function seed() {
  console.log("🚀 Starting Firestore Seeding (Admin Mode)...");
  
  let rawContent = fs.readFileSync('./parsed_members_utf8.json', 'utf8');
  if (rawContent.charCodeAt(0) === 0xFEFF) {
    rawContent = rawContent.slice(1);
  }
  const rawData = JSON.parse(rawContent);

  const membersData = rawData.filter(row => 
    row.__EMPTY_2 && 
    row.__EMPTY_2 !== 'Name' && 
    row.__EMPTY_1 !== 'TOTAL' && 
    !row.__EMPTY_2.includes('SHIVKRUPASAGAR') &&
    row.__EMPTY_1 !== 'Room No.'
  );

  // 1. Clear existing data (optional, but good for clean seed)
  // we won't delete, just overwrite

  const batch = db.batch();

  console.log(`📦 Processing ${membersData.length} members...`);
  
  for (let i = 0; i < membersData.length; i++) {
    const row = membersData[i];
    const rawName = (row.__EMPTY_2 || "").trim().replace(/\r?\n|\r/g, ' ');
    const nameParts = rawName.split(/\s+/);
    const firstName = nameParts[0].toLowerCase().replace(/[^a-z]/g, '');
    const lastName = nameParts[nameParts.length - 1].toLowerCase().replace(/[^a-z]/g, '');
    const flatNo = String(row.__EMPTY_1 || "").padStart(3, '0');
    const uid = `web_member_${i + 1}`;
    const email = (i === 0 ? "chairman@society.com" : (i === 1 ? "secretary@society.com" : (i === 2 ? "treasurer@society.com" : `${firstName}${lastName}@gmail.com`)));

    const userData = {
      uid,
      name: rawName,
      email,
      phone: "9100000000", 
      flatNumber: flatNo,
      role: i === 0 ? "chairman" : (i === 1 ? "secretary" : (i === 2 ? "treasurer" : "member")),
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
      totalReceivable: Number(row.__EMPTY_12) || 0,
      totalReceived: Number(row.__EMPTY_13) || 0,
      closingBalance: Number(row.__EMPTY_14) || 0,
      fixedMonthlyCharges: Number(row.__EMPTY_16) || 0,
      annualCharges: Number(row.__EMPTY_17) || 0,
      variableCharges: Number(row.__EMPTY_18) || 0,
    };

    const userRef = db.collection('users').doc(uid);
    batch.set(userRef, userData);

    // Seed Transaction
    if (userData.totalReceived > 0) {
      const txId = `tx-${i + 1}`;
      batch.set(db.collection('transactions').doc(txId), {
        id: txId,
        memberId: uid,
        memberName: rawName,
        amount: userData.totalReceived,
        paymentMode: "UPI",
        status: "Completed",
        referenceNumber: `REF_INIT_${i + 1}`,
        paidAt: "2025-03-15T14:30:00Z",
        recordedBy: "Secretary"
      });
    }

    // Seed Bill
    if (userData.totalReceivable > 0) {
      const billId = `bill-${i + 1}`;
      batch.set(db.collection('bills').doc(billId), {
        id: billId,
        memberId: uid,
        memberName: rawName,
        flatNumber: flatNo,
        month: 2, // March
        year: 2025,
        maintenanceAmount: userData.maintenanceAmount,
        otherCharges: userData.totalReceivable - userData.maintenanceAmount,
        totalAmount: userData.totalReceivable,
        paidAmount: userData.totalReceived >= userData.totalReceivable ? userData.totalReceivable : userData.totalReceived,
        dueDate: "2025-03-31T23:59:59Z",
        status: userData.totalReceived >= userData.totalReceivable ? "Paid" : "Overdue",
        createdAt: "2025-03-01T10:00:00Z"
      });
    }
  }

  // Sample Expenses
  const mockExpenses = [
    { id: "exp-1", description: "Common Area Electricity", amount: 12500, category: "Utility", expenseDate: "2025-03-20T10:00:00Z", status: "Paid", vendor: "MSEDCL", paymentMode: "Bank Transfer", recordedBy: "Treasurer" },
    { id: "exp-2", description: "Security Services (Mar 2025)", amount: 45000, category: "Service", expenseDate: "2025-03-31T18:00:00Z", status: "Paid", vendor: "Z-Security Agency", paymentMode: "Cheque", recordedBy: "Secretary" },
  ];

  mockExpenses.forEach(exp => {
    batch.set(db.collection('expenses').doc(exp.id), exp);
  });

  // Sample Notices
  const mockNotices = [
    {
      id: "notice-1",
      title: "Annual General Body Meeting (AGM) 2025",
      body: "All members are requested to attend the Annual General Body Meeting scheduled for Sunday, 20th April 2025.",
      status: "Published",
      postedBy: "Pradnya S. Abhyankar",
      createdAt: "2025-03-25T10:00:00Z",
      publishedAt: "2025-03-25T14:00:00Z"
    }
  ];

  mockNotices.forEach(notice => {
    batch.set(db.collection('notices').doc(notice.id), notice);
  });

  await batch.commit();
  console.log("✅ Firestore Seeding Completed Successfully!");
  process.exit(0);
}

seed().catch(err => {
  console.error("❌ Seeding failed:", err);
  process.exit(1);
});
