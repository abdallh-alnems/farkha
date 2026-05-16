"use client";

import { create } from "zustand";
import { persist } from "zustand/middleware";

interface User {
  name: string | null;
  phone: string | null;
  email: string | null;
  uid: string | null;
  photoUrl: string | null;
}

interface AuthState {
  user: User | null;
  isLoggedIn: boolean;
  hasEverLoggedIn: boolean;
  setUser: (user: User | null) => void;
  setLoggedIn: (value: boolean) => void;
  updateUser: (data: Partial<User>) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      isLoggedIn: false,
      hasEverLoggedIn: false,
      setUser: (user) =>
        set((state) => ({
          user,
          isLoggedIn: user !== null,
          hasEverLoggedIn: state.hasEverLoggedIn || user !== null,
        })),
      setLoggedIn: (value) => set({ isLoggedIn: value }),
      updateUser: (data) =>
        set((state) => ({
          user: state.user ? { ...state.user, ...data } : null,
        })),
      logout: () =>
        set((state) => ({
          user: null,
          isLoggedIn: false,
          hasEverLoggedIn: state.hasEverLoggedIn,
        })),
    }),
    {
      name: "farkha-auth",
      partialize: (state) => ({
        user: state.user,
        isLoggedIn: state.isLoggedIn,
        hasEverLoggedIn: state.hasEverLoggedIn,
      }),
    },
  ),
);
