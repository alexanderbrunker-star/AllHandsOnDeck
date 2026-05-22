import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "./e2e",
  timeout: 30000,
  retries: 0,
  use: {
    baseURL: "http://localhost:5173",
    viewport: { width: 390, height: 844 },
  },
  webServer: {
    command: "VITE_ENABLE_LIVEKIT_BETA=false VITE_SUPABASE_URL= VITE_SUPABASE_ANON_KEY= VITE_LIVEKIT_TOKEN_ENDPOINT= npx vite --port 5173",
    url: "http://localhost:5173",
    reuseExistingServer: true,
  },
});
