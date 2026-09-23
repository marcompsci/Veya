# Share Extension Setup

Follow these steps to add a Share Extension so users can share images into Veya from any app.

---

## Step 1 — Add the Share Extension target

1. In Xcode, go to **File → New → Target…**
2. Under **iOS**, select **Share Extension**.
3. Name it `VeyaShareExtension`.
4. Set **Deployment Target** to iOS 18.0.
5. Click **Finish**. Xcode will add a new target with a `ShareViewController.swift`.

---

## Step 2 — Configure supported content types

In the extension's `Info.plist`, set `NSExtensionAttributes → NSExtensionActivationRule` to accept images:

```xml
<key>NSExtensionActivationRule</key>
<dict>
    <key>NSExtensionActivationSupportsImageWithMaxCount</key>
    <integer>1</integer>
</dict>
```

This restricts the extension to appear only when the user shares a single image.

---

## Step 3 — Add the App Group

Both the main app target and the extension must belong to the same App Group to share data.

1. Select the **Veya** target → **Signing & Capabilities** → **+ Capability** → **App Groups**.
2. Add group: `group.com.yourcompany.veya` (replace with your actual bundle prefix).
3. Repeat for the **VeyaShareExtension** target.

---

## Step 4 — Write the incoming image from the extension

Replace the generated `ShareViewController.swift` with:

```swift
import UIKit
import Social
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments else {
            extensionContext?.completeRequest(returningItems: nil)
            return
        }

        let imageType = UTType.image.identifier
        for provider in attachments where provider.hasItemConformingToTypeIdentifier(imageType) {
            provider.loadDataRepresentation(forTypeIdentifier: imageType) { data, error in
                guard let data else {
                    self.extensionContext?.completeRequest(returningItems: nil)
                    return
                }
                do {
                    try SharedImageInbox.store(imageData: data)
                    self.openMainApp()
                } catch {
                    self.extensionContext?.completeRequest(returningItems: nil)
                }
            }
            return
        }
    }

    private func openMainApp() {
        guard let url = URL(string: "veya://import") else { return }
        var responder: UIResponder? = self
        while let r = responder {
            if let application = r as? UIApplication {
                application.open(url)
                break
            }
            responder = r.next
        }
        extensionContext?.completeRequest(returningItems: nil)
    }
}
```

> Note: Add `SharedImageInbox.swift` (already in the main target) to the Share Extension target's **Target Membership** so it can call `SharedImageInbox.store(imageData:)`.

---

## Step 5 — Register the URL scheme

In `Veya/Veya/Info.plist`, add:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>veya</string>
        </array>
        <key>CFBundleURLName</key>
        <string>com.yourcompany.veya</string>
    </dict>
</array>
```

---

## Step 6 — Handle the URL on launch

`RootView.swift` already contains:

```swift
.onOpenURL { url in
    handleIncomingURL(url)
}
```

And `handleIncomingURL` calls `SharedImageInbox.pendingImage()` to retrieve and display the shared image.

---

## Identifiers & Schemes (replace before release)

| Placeholder | Replace with |
|---|---|
| `group.com.yourcompany.veya` | Your real App Group ID |
| `veya://import` | Keep or change scheme, but update `Info.plist` and `RootView` to match |
