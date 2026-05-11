# swift-drops-sdk-example

Example iOS app for `swift-drops-sdk`.

Mirrors the Android example at a higher level:
- a setup screen for auth token / tracker / DDC inputs
- a dedicated payer-auth demo screen with a live event log

## Local setup

This example expects the SDK repo to exist as a sibling directory:

```
../swift-drops-sdk
```

The Xcode project references it as a local Swift Package from that relative path.

## Run

Open `Example.xcodeproj` in Xcode, select an iPhone simulator, and hit Run.

## Flow

1. Enter:
   - environment (local / dev / sandbox / prod)
   - auth token
   - tracker
   - DDC JWT
   - DDC URL
2. Optionally fill in billing fields and toggle Do Capture / Do Card on File
3. Tap **Open Payer Auth Demo**
4. The app pushes a screen that hosts `SafepayPayerAuthenticationView`
5. Event callbacks are prepended to the on-screen log
