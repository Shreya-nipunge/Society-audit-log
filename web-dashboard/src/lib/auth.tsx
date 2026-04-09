"use client";
import { createContext, useContext, useEffect, useState, ReactNode } from "react";
import { onAuthStateChanged, signInWithEmailAndPassword, signOut as fbSignOut, type User as FbUser } from "firebase/auth";
import { doc, getDoc } from "firebase/firestore";
import { auth, db } from "./firebase";
import type { User } from "./types";

interface AuthContextType {
  user: FbUser | null;
  profile: User | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  profile: null,
  loading: true,
  signIn: async () => {},
  signOut: async () => {},
});

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<FbUser | null>(null);
  const [profile, setProfile] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (fbUser) => {
      setUser(fbUser);
      if (fbUser) {
        try {
          const userDoc = await getDoc(doc(db, "users", fbUser.uid));
          if (userDoc.exists()) {
            setProfile({ uid: fbUser.uid, ...userDoc.data() } as User);
          }
        } catch (e) {
          console.error("Error fetching user profile:", e);
        }
      } else {
        setProfile(null);
      }
      setLoading(false);
    });
    return unsubscribe;
  }, []);

  const signIn = async (email: string, password: string) => {
    // Web Dashboard Master Admin Pass for 3 Roles
    const allowedRoles: Record<string, { uid: string; role: string; name: string }> = {
      "chairman@society.com": { uid: "web_member_1", role: "chairman", name: "Society Chairman" },
      "secretary@society.com": { uid: "web_member_2", role: "secretary", name: "Society Secretary" },
      "treasurer@society.com": { uid: "web_member_3", role: "treasurer", name: "Society Treasurer" },
    };

    if (allowedRoles[email] && password === "123456") {
      setLoading(true);
      const { uid, role, name } = allowedRoles[email];

      try {
        // Try fetching actual data from firestore first
        const userDoc = await getDoc(doc(db, "users", uid));
        if (userDoc.exists()) {
          setProfile({ uid, ...userDoc.data() } as User);
        } else {
          // Fallback to locally defined profile
          setProfile({
            uid,
            name,
            email,
            phone: "9876543210",
            flatNumber: "Admin Office",
            role,
            status: "active",
            createdAt: new Date().toISOString(),
            openingBalance: 0, sinkingFund: 0, maintenanceAmount: 3000, municipalTax: 500, noc: 0, 
            parkingCharges: 200, delayCharges: 0, buildingFund: 0, roomTransferFees: 0, 
            totalReceivable: 3700, totalReceived: 0, closingBalance: 3700, 
            fixedMonthlyCharges: 3000, annualCharges: 0, variableCharges: 700
          });
        }
      } catch (err) {
        console.error("Error fetching user data during login bypass", err);
      }

      setUser({
        uid, 
        email,
        displayName: name,
      } as any);
      setLoading(false);
      return;
    }

    // Attempt Firebase Auth sign-in as fallback just in case they are actually in Firebase Auth
    try {
      setLoading(true);
      await signInWithEmailAndPassword(auth, email, password);
      setLoading(false);
    } catch (firebaseErr: any) {
      setLoading(false);
      throw new Error("Invalid credentials for Web Admin Portal.");
    }
  };

  const signOutFn = async () => {
    if (user?.uid === "demo-admin") {
      setUser(null);
      setProfile(null);
      return;
    }
    await fbSignOut(auth);
    setProfile(null);
  };

  return (
    <AuthContext.Provider value={{ user, profile, loading, signIn, signOut: signOutFn }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
