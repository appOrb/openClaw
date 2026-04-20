---
name: nextjs-feature
description: Add features to the ai_waiter.frontend Next.js 15 app using App Router, React 19, TypeScript 5.3, and Zustand
modelHint: research
---

# Next.js Feature Skill

## Repo: `appOrb/ai_waiter.frontend`
Stack: Next.js 15 (App Router), React 19, TypeScript 5.3, Zustand, Axios, @microsoft/signalr, Vitest, Playwright, ESLint, Prettier.

## Folder Structure
```
src/
  app/           ← App Router: layouts, pages, loading, error
  components/    ← Shared UI components
  stores/        ← Zustand state stores
  lib/           ← API clients (axios), signalr client, utilities
  types/         ← TypeScript interfaces/types
  hooks/         ← Custom React hooks
```

## Adding a New Page
```tsx
// src/app/menu/page.tsx
import { MenuList } from "@/components/menu/MenuList";

export default function MenuPage() {
  return (
    <main>
      <h1>Menu</h1>
      <MenuList />
    </main>
  );
}
```

## Zustand Store Pattern
```typescript
// src/stores/menuStore.ts
import { create } from "zustand";

interface MenuState {
  items: MenuItem[];
  isLoading: boolean;
  fetchItems: () => Promise<void>;
}

export const useMenuStore = create<MenuState>((set) => ({
  items: [],
  isLoading: false,
  fetchItems: async () => {
    set({ isLoading: true });
    const data = await api.getMenuItems();
    set({ items: data, isLoading: false });
  },
}));
```

## API Client (Axios)
```typescript
// src/lib/api.ts
import axios from "axios";
const api = axios.create({ baseURL: process.env.NEXT_PUBLIC_API_URL });
export const getMenuItems = () => api.get<MenuItem[]>("/api/menuitems").then(r => r.data);
```

## Environment Variables
- `NEXT_PUBLIC_API_URL` — backend URL (public)
- `NEXT_PUBLIC_SIGNALR_URL` — SignalR hub URL (public)

## Dev Commands
```bash
npm run dev        # start dev server
npm run build      # production build
npm run lint       # ESLint check
npm run test       # Vitest unit tests
npm run test:e2e   # Playwright e2e tests
```
