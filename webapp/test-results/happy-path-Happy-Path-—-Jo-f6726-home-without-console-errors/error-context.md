# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: happy-path.spec.ts >> Happy Path — Join Page (no backend) >> clicks home join flow and returns home without console errors
- Location: e2e/happy-path.spec.ts:33:3

# Error details

```
Error: expect(locator).toBeDisabled() failed

Locator: getByRole('button', { name: 'Join →' })
Expected: disabled
Timeout: 5000ms
Error: element(s) not found

Call log:
  - Expect "toBeDisabled" with timeout 5000ms
  - waiting for getByRole('button', { name: 'Join →' })

```

```yaml
- text: ⚓︎ by Captain Leopard
- button "Identity settings": ⚙
- heading "All Hands On Deck" [level=1]
- paragraph: Web viewer for Captain's live crew photo session.
- button "📷 Start Crew Photo"
- textbox "ABCDEF1234"
- button "◈ Join Session" [disabled]
- text: 🌐 Allow Web Viewers BETA Off — nearby only
- paragraph: No install. No sign-in.
- paragraph: "\"What's a pirate's fav letter? Ye think it's R — but it's the C!\""
- paragraph:
  - link "Privacy":
    - /url: /privacy
  - text: ·
  - link "Imprint":
    - /url: /imprint
```

# Test source

```ts
  1   | import { test, expect } from "@playwright/test";
  2   | 
  3   | function collectSevereConsoleMessages(page: import("@playwright/test").Page) {
  4   |   const messages: string[] = [];
  5   |   page.on("console", (message) => {
  6   |     if (["error", "warning"].includes(message.type())) {
  7   |       messages.push(`${message.type()}: ${message.text()}`);
  8   |     }
  9   |   });
  10  |   page.on("pageerror", (error) => {
  11  |     messages.push(`pageerror: ${error.message}`);
  12  |   });
  13  |   return messages;
  14  | }
  15  | 
  16  | test.describe("Happy Path — Landing Page", () => {
  17  |   test("renders with hero and navigation", async ({ page }) => {
  18  |     await page.goto("/");
  19  |     await page.waitForLoadState("networkidle");
  20  |     await expect(page.locator("body")).toBeVisible();
  21  |   });
  22  | 
  23  |   test("has join link or prompt visible", async ({ page }) => {
  24  |     await page.goto("/");
  25  |     await page.waitForLoadState("networkidle");
  26  |     const bodyText = await page.textContent("body");
  27  |     expect(bodyText).toBeTruthy();
  28  |     expect(bodyText!.length).toBeGreaterThan(0);
  29  |   });
  30  | });
  31  | 
  32  | test.describe("Happy Path — Join Page (no backend)", () => {
  33  |   test("clicks home join flow and returns home without console errors", async ({ page }) => {
  34  |     const severeMessages = collectSevereConsoleMessages(page);
  35  | 
  36  |     await page.goto("/");
  37  |     await page.waitForLoadState("networkidle");
  38  | 
  39  |     const joinButton = page.getByRole("button", { name: "Join →" });
> 40  |     await expect(joinButton).toBeDisabled();
      |                              ^ Error: expect(locator).toBeDisabled() failed
  41  | 
  42  |     await page.getByPlaceholder("ABCDEF1234").fill("abc123");
  43  |     await expect(page.getByPlaceholder("ABCDEF1234")).toHaveValue("ABC123");
  44  |     await expect(joinButton).toBeEnabled();
  45  | 
  46  |     await joinButton.click();
  47  |     await page.waitForURL("**/join/ABC123");
  48  |     await expect(page.getByText("ABC123")).toBeVisible();
  49  |     await expect(page.getByText("NOT FOUND").first()).toBeVisible();
  50  | 
  51  |     await page.getByRole("button", { name: "Back" }).last().click();
  52  |     await page.waitForURL("/");
  53  |     await expect(page.getByRole("button", { name: "Join →" })).toBeVisible();
  54  |     expect(severeMessages).toEqual([]);
  55  |   });
  56  | 
  57  |   test("renders with session ID in URL", async ({ page }) => {
  58  |     await page.goto("/join/HAPPYTEST");
  59  |     await page.waitForLoadState("networkidle");
  60  |     await expect(page.locator("body")).toBeVisible();
  61  |   });
  62  | 
  63  |   test("opens iOS QR join URL with short-lived token query", async ({ page }) => {
  64  |     await page.goto("/join/7NMDA6TAE9?session_id=7NMDA6TAE9&token=test-token&expires_at=2026-05-06T18%3A00%3A00Z");
  65  |     await page.waitForLoadState("networkidle");
  66  | 
  67  |     await expect(page).toHaveURL(/\/join\/7NMDA6TAE9\?/);
  68  |     await expect(page.getByText("7NMDA6TAE9")).toBeVisible();
  69  |     await expect(page.locator("body")).toBeVisible();
  70  |   });
  71  | 
  72  |   test("shows content without crashing", async ({ page }) => {
  73  |     await page.goto("/join/HAPPYTEST");
  74  |     await page.waitForLoadState("networkidle");
  75  |     const bodyText = await page.textContent("body");
  76  |     expect(bodyText).toBeTruthy();
  77  |   });
  78  | 
  79  |   test("responsive on mobile viewport", async ({ page }) => {
  80  |     await page.setViewportSize({ width: 390, height: 844 });
  81  |     await page.goto("/join/MOBILE01");
  82  |     await page.waitForLoadState("networkidle");
  83  |     await expect(page.locator("body")).toBeVisible();
  84  |   });
  85  | 
  86  |   test("responsive on tablet viewport", async ({ page }) => {
  87  |     await page.setViewportSize({ width: 820, height: 1180 });
  88  |     await page.goto("/join/TABLET01");
  89  |     await page.waitForLoadState("networkidle");
  90  |     await expect(page.locator("body")).toBeVisible();
  91  |   });
  92  | });
  93  | 
  94  | test.describe("Happy Path — Join Page (mock Supabase data)", () => {
  95  |   test("shows preview frame when available", async ({ page }) => {
  96  |     await page.goto("/join/HAPPYTEST");
  97  |     await page.waitForLoadState("networkidle");
  98  |     // Page should render without crashing when Supabase is not configured locally.
  99  |     await page.waitForTimeout(2000);
  100 |     await expect(page.locator("body")).toBeVisible();
  101 |   });
  102 | 
  103 |   test("renders the join shell without Supabase credentials", async ({ page }) => {
  104 |     await page.goto("/join/HAPPYTEST");
  105 |     await page.waitForLoadState("networkidle");
  106 |     await page.waitForTimeout(2000);
  107 |     await expect(page.locator("body")).toBeVisible();
  108 |   });
  109 | });
  110 | 
  111 | test.describe("Happy Path — Navigation", () => {
  112 |   test("root path redirects or shows landing", async ({ page }) => {
  113 |     const response = await page.goto("/");
  114 |     expect(response?.status()).toBeLessThan(400);
  115 |   });
  116 | 
  117 |   test("join path returns 200", async ({ page }) => {
  118 |     const response = await page.goto("/join/NAVTEST");
  119 |     expect(response?.status()).toBeLessThan(400);
  120 |   });
  121 | 
  122 |   test("unknown path does not crash", async ({ page }) => {
  123 |     const response = await page.goto("/unknown/path");
  124 |     // SPA should still return HTML
  125 |     expect(response?.status()).toBeLessThan(500);
  126 |   });
  127 | });
  128 | 
  129 | test.describe("Happy Path — Host Page", () => {
  130 |   test("renders host page with start button", async ({ page }) => {
  131 |     const msgs = collectSevereConsoleMessages(page);
  132 |     await page.goto("/host");
  133 |     await page.waitForLoadState("networkidle");
  134 |     await expect(page.getByText(/Start as Host/i)).toBeVisible();
  135 |     expect(msgs).toHaveLength(0);
  136 |   });
  137 | 
  138 |   test("shows back button on host page", async ({ page }) => {
  139 |     await page.goto("/host");
  140 |     await page.waitForLoadState("networkidle");
```