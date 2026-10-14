import SwiftUI

public struct MetricCardView: View {
    public let icon: String
    public let iconColor: Color
    public let title: String
    public let primaryValue: String
    public let secondaryValue: String?
    
    public init(
        icon: String,
        iconColor: Color,
        title: String,
        primaryValue: String,
        secondaryValue: String? = nil
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.primaryValue = primaryValue
        self.secondaryValue = secondaryValue
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.18))
                    .frame(width: 26, height: 26)
                
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.55))
                
                Text(primaryValue)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))
                    .lineLimit(1)
            }
            
            Spacer(minLength: 0)
            
            if let secondary = secondaryValue {
                Text(secondary)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.45))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5)
                )
        )
    }
}
