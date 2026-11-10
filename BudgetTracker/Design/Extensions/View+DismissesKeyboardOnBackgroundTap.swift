import SwiftUI

extension View {
    /// Dismisses the keyboard when a tap lands on space that no child view handles.
    /// Child gestures take precedence over this one, so buttons, links and text fields
    /// keep working without closing the keyboard.
    func dismissesKeyboardOnBackgroundTap() -> some View {
        contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
                )
            }
    }
}
