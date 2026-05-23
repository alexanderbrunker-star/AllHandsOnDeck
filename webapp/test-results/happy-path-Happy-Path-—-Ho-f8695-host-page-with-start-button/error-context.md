# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: happy-path.spec.ts >> Happy Path — Host Page >> renders host page with start button
- Location: e2e/happy-path.spec.ts:130:3

# Error details

```
Error: expect(locator).toBeVisible() failed

Locator: getByText(/Start as Host/i)
Expected: visible
Timeout: 5000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" with timeout 5000ms
  - waiting for getByText(/Start as Host/i)

```

```yaml
- text: 🏴‍☠️
- paragraph: "NotSupportedError: Not supported"
- button "Try Again"
- button "Back"
```

# Test source

```ts
  34  |     const severeMessages = collectSevereConsoleMessages(page);
  35  | 
  36  |     await page.goto("/");
  37  |     await page.waitForLoadState("networkidle");
  38  | 
  39  |     const joinButton = page.getByRole("button", { name: "Join →" });
  40  |     await expect(joinButton).toBeDisabled();
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
> 134 |     await expect(page.getByText(/Start as Host/i)).toBeVisible();
      |                                                    ^ Error: expect(locator).toBeVisible() failed
  135 |     expect(msgs).toHaveLength(0);
  136 |   });
  137 | 
  138 |   test("shows back button on host page", async ({ page }) => {
  139 |     await page.goto("/host");
  140 |     await page.waitForLoadState("networkidle");
  141 |     await expect(page.locator("button:has-text('‹')")).toBeVisible();
  142 |   });
  143 | 
  144 |   test("navigates to home on back click", async ({ page }) => {
  145 |     await page.goto("/host");
  146 |     await page.waitForLoadState("networkidle");
  147 |     await page.locator("button:has-text('‹')").first().click();
  148 |     await page.waitForURL(/\/$/);
  149 |   });
  150 | 
  151 |   test("shows camera error gracefully when camera denied", async ({ page }) => {
  152 |     await page.context().grantPermissions([], { origin: "http://localhost:5173" });
  153 |     const msgs = collectSevereConsoleMessages(page);
  154 |     await page.goto("/host");
  155 |     await page.waitForLoadState("networkidle");
  156 |     await page.getByText(/Start as Host/i).click();
  157 |     await page.waitForTimeout(1000);
  158 |     const hasError = await page.getByText(/Camera|Denied|Error/i).isVisible().catch(() => false);
  159 |     if (hasError) {
  160 |       await expect(page.getByText(/Camera|Denied/i)).toBeVisible();
  161 |     }
  162 |     expect(msgs.length).toBeLessThan(3);
  163 |   });
  164 | 
  165 |   test("host page layout matches iOS-style top bar", async ({ page }) => {
  166 |     await page.goto("/host");
  167 |     await page.waitForLoadState("networkidle");
  168 |     const backBtn = page.locator("button:has-text('‹')");
  169 |     await expect(backBtn).toBeVisible();
  170 |   });
  171 | });
  172 | 
```