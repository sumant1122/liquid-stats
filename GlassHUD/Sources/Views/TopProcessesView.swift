import SwiftUI

public struct TopProcessesView: View {
    public let processes: [ProcessItem]
    
    public init(processes: [ProcessItem]) {
        self.processes = processes
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.orange)
                    
                    Text("TOP PROCESSES")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.8)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Text("CPU %")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            if processes.isEmpty {
                HStack {
                    Spacer()
                    Text("Sampling processes...")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.white.opacity(0.35))
                    Spacer()
                }
                .padding(.vertical, 4)
            } else {
                VStack(spacing: 4) {
                    ForEach(processes) { item in
                        HStack(spacing: 6) {
                            Text(item.name)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            Spacer(minLength: 4)
                            
                            // Mini horizontal bar
                            GeometryReader { geo in
                                let barWidth = geo.size.width * CGFloat(min(item.cpuPercent / 100.0, 1.0))
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.08))
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.cyan.opacity(0.8), .orange.opacity(0.9)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: max(barWidth, 2))
                                }
                            }
                            .frame(width: 44, height: 4)
                            
                            Text(String(format: "%.1f%%", item.cpuPercent))
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(item.cpuPercent > 50.0 ? .orange : .white.opacity(0.85))
                                .frame(width: 42, alignment: .trailing)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
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
