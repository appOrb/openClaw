---
name: vitest-playwright
description: Write Vitest unit tests and Playwright e2e/accessibility tests for the ai_waiter.frontend
modelHint: repetitive
---

# Vitest + Playwright Testing Skill

## Repo: `appOrb/ai_waiter.frontend`

## Vitest Unit Tests
Tests live next to source files: `src/components/MenuItem.test.tsx`

```typescript
// src/components/MenuItem.test.tsx
import { render, screen } from "@testing-library/react";
import { describe, it, expect, vi } from "vitest";
import { MenuItem } from "./MenuItem";

describe("MenuItem", () => {
  it("renders name and price", () => {
    render(<MenuItem name="Burger" price={12.99} onAdd={vi.fn()} />);
    expect(screen.getByText("Burger")).toBeInTheDocument();
    expect(screen.getByText("$12.99")).toBeInTheDocument();
  });

  it("calls onAdd when button clicked", async () => {
    const onAdd = vi.fn();
    const { getByRole } = render(<MenuItem name="Burger" price={12.99} onAdd={onAdd} />);
    await userEvent.click(getByRole("button", { name: /add/i }));
    expect(onAdd).toHaveBeenCalledOnce();
  });
});
```

## Zustand Store Tests
```typescript
import { renderHook, act } from "@testing-library/react";
import { useMenuStore } from "@/stores/menuStore";

it("fetches and stores menu items", async () => {
  vi.spyOn(api, "getMenuItems").mockResolvedValue([{ id: "1", name: "Burger", price: 12.99 }]);
  const { result } = renderHook(() => useMenuStore());
  await act(() => result.current.fetchItems());
  expect(result.current.items).toHaveLength(1);
});
```

## Playwright E2E Tests
```typescript
// e2e/menu.spec.ts
import { test, expect } from "@playwright/test";

test("user can view menu items", async ({ page }) => {
  await page.goto("/menu");
  await expect(page.getByRole("heading", { name: "Menu" })).toBeVisible();
  await expect(page.getByTestId("menu-item")).toHaveCount(await page.getByTestId("menu-item").count());
});

test("accessibility: no WCAG violations", async ({ page }) => {
  await page.goto("/menu");
  const accessibilityScanResults = await new AxeBuilder({ page }).analyze();
  expect(accessibilityScanResults.violations).toEqual([]);
});
```

## Run Tests
```bash
npm run test           # Vitest unit tests (watch mode)
npm run test:run       # Vitest single run (CI)
npm run test:e2e       # Playwright (needs running server)
npm run test:e2e:ci    # Playwright with bundled dev server
```
