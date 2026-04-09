const admin = require('firebase-admin');
const fs = require('fs');

const SERVICE_ACCOUNT_PATH = './serviceAccount.json';
const serviceAccount = require(SERVICE_ACCOUNT_PATH);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function fixRoles() {
  const batch = db.batch();

  const m1 = db.collection('users').doc('web_member_1');
  batch.update(m1, { role: 'member', email: 'pradnyasabhyankar@gmail.com' });

  const m2 = db.collection('users').doc('web_member_2');
  batch.update(m2, { role: 'member', email: 'pradnyasabhyankar2@gmail.com' });

  const m3 = db.collection('users').doc('web_member_3');
  batch.update(m3, { role: 'member', email: 'rajeshgshingare@gmail.com' });

  await batch.commit();
  console.log("Successfully demoted real members to 'member' role and fixed emails.");
  process.exit(0);
}

fixRoles();
