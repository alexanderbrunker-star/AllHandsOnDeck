# All Hands on Deck

[![iOS CI](https://github.com/alexanderbrunker-star/all-hands-on-deck/actions/workflows/ios-ci.yml/badge.svg)](https://github.com/alexanderbrunker-star/all-hands-on-deck/actions/workflows/ios-ci.yml)
[![Webapp CI](https://github.com/alexanderbrunker-star/all-hands-on-deck/actions/workflows/webapp-ci.yml/badge.svg)](https://github.com/alexanderbrunker-star/all-hands-on-deck/actions/workflows/webapp-ci.yml)
[![Server CI](https://github.com/alexanderbrunker-star/all-hands-on-deck/actions/workflows/server-ci.yml/badge.svg)](https://github.com/alexanderbrunker-star/all-hands-on-deck/actions/workflows/server-ci.yml)

> Experimental work by Captain Leopard
> *"Everyone sees the group photo before it's taken."*

iOS-first MVP for a live-viewfinder group photo. One person sets up their iPhone as the camera; everyone else sees the frame live on their devices — natively or in a browser, no installation required.

## Quick Start

```bash
# iOS
xcodegen generate
xcodebuild -project AllHandsOnDeck.xcodeproj -scheme AllHandsOnDeck \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build

# Webapp
cd webapp && npm ci && npm run dev

# Server (optional)
cd server && npm ci && npm run dev
```

## Repository Layout

| Directory | Purpose |
|-----------|---------|
| `AllHandsOnDeck/` | iOS App (SwiftUI) |
| `AllHandsOnDeckTests/` | XCTest unit tests |
| `AllHandsOnDeckUITests/` | XCUITest UI tests |
| `AllHandsOnDeckWatch/` | Apple Watch companion |
| `webapp/` | Vite + React web viewer |
| `server/` | Node/TS signaling & token server |
| `supabase/` | Database migrations & config |
| `scripts/` | E2E test & utility scripts |
| `docs/` | Full documentation |

## Documentation

- [Project Details](docs/README.md) — architecture, features, pipelines
- [Setup Guide](docs/SETUP.md) — Supabase, environment, deployment
- [Contributing](docs/contributing/CONTRIBUTING.md) — coding rules & conventions
- [Checklist](docs/contributing/CHECKLIST.md) — definition of done
- [Changelog](docs/CHANGELOG.md)
- [App Store Listing](docs/STORE.md) — draft for App Store Connect

## Status

Feature-complete, App Store ready. Web viewers are a beta feature.

**Tech stack:** SwiftUI, Multipeer Connectivity, Vision, Supabase, Vite/React, WebSocket relay.
