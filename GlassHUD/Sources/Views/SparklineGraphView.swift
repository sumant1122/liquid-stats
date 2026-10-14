import SwiftUI

public struct SparklineGraphView: View {
    public let data: [Double]
    public let title: String
    public let gradient: [Color]
    public var height: CGFloat = 36
    
    public init(data: [Double], title: String, gradient: [Color], height: CGFloat = 36) {
        self.data = data
        self.title = title
        self.gradient = gradient
        self.height = height
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                if let last = data.last {
                    Text(String(format: "%.1f%%", last))
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor((gradient.first ?? .cyan).opacity(0.9))
                }
            }
            
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let points = self.computePoints(width: w, height: h)
                
                ZStack {
                    // Subtle background grid lines
                    VStack {
                        Divider().background(Color.white.opacity(0.06))
                        Spacer()
                        Divider().background(Color.white.opacity(0.06))
                    }
                    
                    // Gradient Area Fill
                    if points.count > 1 {
                        Path { path in
                            path.move(to: CGPoint(x: points[0].x, y: h))
                            for pt in points {
                                path.addLine(to: pt)
                            }
                            if let last = points.last {
                                path.addLine(to: CGPoint(x: last.x, y: h))
                            }
                            path.closeSubpath()
                        }
                        .fill(
                            LinearGradient(
                                colors: [
                                    (gradient.first ?? .cyan).opacity(0.35),
                                    (gradient.last ?? .blue).opacity(0.02)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        // Line Path
                        Path { path in
                            path.move(to: points[0])
                            for i in 1..<points.count {
                                path.addLine(to: points[i])
                            }
                        }
                        .stroke(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round)
                        )
                    }
                }
            }
            .frame(height: height)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
    }
    
    private func computePoints(width: CGFloat, height: CGFloat) -> [CGPoint] {
        guard data.count > 1 else { return [] }
        let step = width / CGFloat(max(data.count - 1, 1))
        
        return data.enumerated().map { index, val in
            let clamped = min(max(val, 0.0), 100.0)
            let y = height - (CGFloat(clamped / 100.0) * height)
            return CGPoint(x: CGFloat(index) * step, y: y)
        }
    }
}
