import SwiftUI

public struct CircularGaugeView: View {
    public let title: String
    public let icon: String
    public let percent: Double
    public let subtitle: String
    public let gradient: [Color]
    public var size: CGFloat = 88
    
    public init(
        title: String,
        icon: String,
        percent: Double,
        subtitle: String,
        gradient: [Color],
        size: CGFloat = 88
    ) {
        self.title = title
        self.icon = icon
        self.percent = percent
        self.subtitle = subtitle
        self.gradient = gradient
        self.size = size
    }
    
    private var progress: Double {
        min(max(percent / 100.0, 0.0), 1.0)
    }
    
    public var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Background track ring
                Circle()
                    .stroke(Color.white.opacity(0.08), style: StrokeStyle(lineWidth: 7, lineCap: .round))
                
                // Progress arc
                Circle()
                    .trim(from: 0.0, to: CGFloat(progress))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: gradient + [gradient.first ?? .cyan]),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 7, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: progress)
                    .shadow(color: (gradient.last ?? .cyan).opacity(0.4), radius: 4, x: 0, y: 0)
                
                // Center percentage text and icon
                VStack(spacing: 1) {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(gradient.first ?? .primary)
                    
                    Text("\(Int(percent.rounded()))%")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                }
            }
            .frame(width: size, height: size)
            
            // Labels below ring
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                
                Text(subtitle)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.55))
                    .lineLimit(1)
            }
        }
    }
}
