# Mobile and desktop distribution

**Snapshot 2026-10-03.** Prices in USD from the linked pages (local currency may differ). The
skill prepares signing config, store metadata and the exact submit command; **the user pays the
fees, signs, notarizes and submits.** Store review and account verification take days — put them
at the top of `ship.md`.

## 1. Accounts and fees

| Target | Account | Cost | Rule to say up front | URL |
|---|---|---|---|---|
| **macOS outside the App Store** (DMG / direct download) | Apple Developer Program | **$99/yr** | Covered by the same membership: a **Developer ID Application** certificate + **notarization** (`xcrun notarytool submit <dmg> --keychain-profile <name> --wait` then `xcrun stapler staple <app>`). Without it Gatekeeper blocks the app with "cannot be opened". Not the App Store, no review, no 15–30% commission. | https://developer.apple.com/programs/enroll/ · https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution |
| **Mac App Store / iOS App Store** | Apple Developer Program | **$99/yr**; organizations need a D-U-N-S number | App Review (days); commission 15% under the Small Business Program (≤ $1M/yr), else 30%. TestFlight for betas. Individuals enroll with ID verification. | https://developer.apple.com/support/compare-memberships/ · https://developer.apple.com/app-store/small-business-program/ |
| **Google Play** | Google Play Console | **$25 one time** | **Personal accounts created after 2023-11-13 must run a closed test with ≥ 12 testers opted in for 14 consecutive days** before production access; opting out resets the clock. Service fee 15% on the first $1M/yr and on subscriptions. | https://support.google.com/googleplay/android-developer/answer/6112435 · https://support.google.com/googleplay/android-developer/answer/14151465 · https://support.google.com/googleplay/android-developer/answer/112622 |
| **Microsoft Store** (Windows) | Partner Center developer account | **Free** (individual or company; ID verification) | Store-distributed MSIX is **signed by the Store** — no certificate to buy. The simplest Windows path for a Colombian individual. | https://learn.microsoft.com/en-us/windows/apps/publish/partner-center/open-a-developer-account |
| **winget** (Windows, direct) | GitHub account | Free | PR a YAML manifest to `microsoft/winget-pkgs`; the installer itself still needs code signing to avoid SmartScreen warnings. | https://learn.microsoft.com/en-us/windows/package-manager/package/ |
| **Windows outside the Store** (EXE/MSI direct download) | Code-signing certificate | **Azure Artifact Signing** (ex Trusted Signing) Basic ≈ $9.99/mo for 5,000 signatures (unverified; the Azure page did not render prices). **Individuals: US and Canada only; organizations: US, CA, EU, UK** (unverified). Otherwise an **OV/EV certificate from a CA ≈ $200–500/yr** (unverified), EV on a hardware token. | **A Colombian individual cannot use Azure Artifact Signing** → ship through the Microsoft Store, or budget an OV/EV cert, or accept SmartScreen warnings while reputation builds. | https://azure.microsoft.com/en-us/pricing/details/artifact-signing/ · https://learn.microsoft.com/en-us/windows/apps/package-and-deploy/code-signing-options |

## 2. Frameworks (one line each)

| Framework | What it ships | Build/distribute docs | MCP (user runs it) |
|---|---|---|---|
| **Expo / EAS** (React Native) | iOS + Android from one codebase; EAS Build in the cloud (free: 15 Android + 15 iOS builds/mo, 1,000 update MAU; Starter $19/mo; Production $199/mo), `eas submit` to both stores, OTA updates | https://docs.expo.dev/eas/ · https://expo.dev/pricing | `claude mcp add --transport http expo https://mcp.expo.dev/mcp` (docs search needs a paid EAS plan) · https://docs.expo.dev/eas/ai/mcp/ |
| **Flutter** | Android, iOS, macOS, Windows, Linux, Web from one Dart codebase; per-platform deployment guides | https://docs.flutter.dev/deployment | `dart mcp-server` (docs/tooling; see the build skill's docs-mcps) |
| **Tauri 2** | Small native desktop (macOS DMG / App Store, Windows MSI/NSIS / Microsoft Store, Linux AppImage/deb/rpm/Flatpak/Snap/AUR) + iOS/Android with a web frontend; signing required on most platforms | https://v2.tauri.app/distribute/ | none |
| **Electron** | Desktop via Electron Forge: `@electron/osx-sign`, `@electron/notarize`, `@electron/windows-sign`; Windows signing via Azure Artifact Signing or an EV cert on a hardware token | https://www.electronjs.org/docs/latest/tutorial/code-signing | none |

## 3. What the skill prepares vs what the user runs

| Step | Skill writes | User runs |
|---|---|---|
| macOS signing | `codesign` + `notarytool` commands with the Developer ID identity name and a keychain profile placeholder; hardened runtime entitlements file | `xcrun notarytool store-credentials`, `codesign --deep --options runtime …`, `xcrun notarytool submit … --wait`, `xcrun stapler staple …` |
| iOS / Android (Expo) | `eas.json` profiles (preview, production), `app.json` identifiers, store listing text | `eas build --platform all --profile production`, `eas submit` |
| Google Play testers | A closed-testing checklist: 12 testers, opt-in link, 14-day calendar reminder | Invites testers, applies for production access |
| Windows | MSIX packaging config (Tauri/Electron Forge), Partner Center listing text | Creates the Partner Center account, uploads the package |
| All | `ship.md` items with dates (review wait, 14-day tester window), `decisions.md` line with the URL | Pays the $99 / $25, submits |

## Sources

https://developer.apple.com/programs/enroll/ · https://developer.apple.com/support/compare-memberships/ ·
https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution ·
https://developer.apple.com/app-store/small-business-program/ ·
https://support.google.com/googleplay/android-developer/answer/6112435 ·
https://support.google.com/googleplay/android-developer/answer/14151465 ·
https://support.google.com/googleplay/android-developer/answer/112622 ·
https://learn.microsoft.com/en-us/windows/apps/publish/partner-center/open-a-developer-account ·
https://learn.microsoft.com/en-us/windows/package-manager/package/ ·
https://azure.microsoft.com/en-us/pricing/details/artifact-signing/ ·
https://learn.microsoft.com/en-us/windows/apps/package-and-deploy/code-signing-options ·
https://expo.dev/pricing · https://docs.expo.dev/eas/ai/mcp/ · https://docs.flutter.dev/deployment ·
https://v2.tauri.app/distribute/ · https://www.electronjs.org/docs/latest/tutorial/code-signing
