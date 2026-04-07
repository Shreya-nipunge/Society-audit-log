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
    // Development Demo Bypass
    if (process.env.NODE_ENV === "development" && email === "admin@society.com" && password === "admin123") {
      setUser({
        uid: "demo-admin",
        email: "admin@society.com",
        displayName: "Demo Admin",
      } as FbUser);
      setProfile({
        uid: "demo-admin",
        name: "John Chairman (Demo)",
        email: "admin@society.com",
        role: "chairman",
        status: "Active",
      } as User);
      setLoading(false);
      return;
    }
    await signInWithEmailAndPassword(auth, email, password);
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
