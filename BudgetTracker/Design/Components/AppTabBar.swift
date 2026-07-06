import SwiftUI

struct AppTabBar: View {
    static let height: CGFloat = 64.0

    private let tabs: [Tab]

    @Binding private var selectedTab: Tab
    private let addButtonAction: () -> Void

    init(tabs: [Tab], selectedTab: Binding<Tab>, addButtonAction: @escaping () -> Void) {
        self.tabs = tabs
        _selectedTab = selectedTab
        self.addButtonAction = addButtonAction
    }

    @Namespace private var highlightNamespace

    var body: some View {
        HStack(spacing: 0) {
            Spacer()

            tabsView

            Spacer()

            addButton

            Spacer()
        }
    }

    private var addButton: some View {
        Button(
            action: addButtonAction,
            label: {
                let iconSize: CGFloat = 18
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: AppTabBar.height, height: AppTabBar.height)
            }
        )
        .background(backgroundView)
    }

    private var tabsView: some View {
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
        .background(backgroundView)
    }

    private var backgroundView: some View {
        Capsule()
            .fill(Color.bgSurface.opacity(0.95))
            .stroke(Color.borderSubtle, lineWidth: 1)
    }

    private func buildTabItem(for tab: Tab, isSelected: Bool) -> some View {
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
                .fixedSize()
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
