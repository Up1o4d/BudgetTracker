import SwiftUI

struct AppTabBar: View {
    static let height: CGFloat = 64.0

    private let tabs: [Tab]
    @Binding private var selectedTab: Tab

    init(tabs: [Tab], selectedTab: Binding<Tab>) {
        self.tabs = tabs
        _selectedTab = selectedTab
    }

    @Namespace private var highlightNamespace

    var body: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                buildTabItem(for: tab, isSelected: tab == selectedTab)
                    .onTapGesture { selectedTab = tab }
                if tab != tabs.last {
                    Color.clear.frame(width: 16, height: 0)
                }
            }
        }
        .padding(.horizontal, 32)
        .frame(height: AppTabBar.height)
        .background(
            Capsule()
                .fill(Color.bgSurface)
                .stroke(Color.borderSubtle, lineWidth: 1)
        )
    }

    func buildTabItem(for tab: Tab, isSelected: Bool) -> some View {
        VStack {
            let iconSize: CGFloat = 25
            Image(systemName: tab.systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .padding(.vertical, 4)
                .padding(.horizontal, 16)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(Color.accentLime.opacity(0.2))
                            .stroke(Color.accentLime, lineWidth: 1)
                            .matchedGeometryEffect(id: "tabHighlight", in: highlightNamespace)
                    }
                }
            Text(tab.name)
        }
        .foregroundStyle(isSelected ? Color.accentLime : Color.textSecondary)
        .textStyle(.tab)
        .animation(.spring(duration: 0.2), value: isSelected)
    }
}

#Preview {
    @Previewable @State var selectedTab: Tab = .home
    AppTabBar(tabs: Tab.allCases, selectedTab: $selectedTab)
}
