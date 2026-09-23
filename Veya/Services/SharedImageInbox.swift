import Foundation

/// Reads images placed into the shared App Group by the Share Extension.
/// App Group identifier: group.com.yourcompany.veya
/// URL scheme for handoff:  veya://import
///
/// When the Share Extension is added (see ShareExtensionSetup.md), it will
/// write the incoming image data to `inboxURL` and then open the Veya app
/// via the URL scheme. On launch, call `pendingImage()` to retrieve it.
struct SharedImageInbox {
    static let appGroupIdentifier = "group.com.yourcompany.veya"
    static let inboxFilename = "pending_shared_image.jpg"

    private static var inboxURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
            .appendingPathComponent(inboxFilename)
    }

    /// Returns and clears raw image data dropped by the Share Extension.
    /// The caller is responsible for converting Data → UIImage.
    static func pendingImageData() -> Data? {
        guard let url = inboxURL,
              FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        try? FileManager.default.removeItem(at: url)
        return data
    }

    /// Call from the Share Extension target to store an image for the main app.
    static func store(imageData: Data) throws {
        guard let url = inboxURL else {
            throw VeyaError.imageProcessingFailed
        }
        try imageData.write(to: url, options: .atomic)
    }
}
