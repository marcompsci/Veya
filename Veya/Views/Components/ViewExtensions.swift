import SwiftUI

extension View {
    /// Hides the navigation bar on iOS; no-op on macOS where it isn't present.
    @ViewBuilder
    func veyaHideNavBar() -> some View {
        #if os(iOS)
        self.toolbarVisibility(.hidden, for: .navigationBar)
        #else
        self
        #endif
    }

    /// Uses iOS paged tab style; falls back to automatic on macOS.
    @ViewBuilder
    func veyaPageTabStyle() -> some View {
        #if os(iOS)
        self.tabViewStyle(.page(indexDisplayMode: .never))
        #else
        self.tabViewStyle(.automatic)
        #endif
    }

    /// Uses insetGrouped list style on iOS; sidebar on macOS.
    @ViewBuilder
    func veyaListStyle() -> some View {
        #if os(iOS)
        self.listStyle(.insetGrouped)
        #else
        self.listStyle(.sidebar)
        #endif
    }
}
