import SwiftUI

struct BatteryIconView: View {
    let percentage: Int
    let isCharging: Bool

    private let bodyWidth: CGFloat = 32
    private let bodyHeight: CGFloat = 15
    private let bodyRadius: CGFloat = 3.5
    private let termWidth: CGFloat = 3
    private let termHeight: CGFloat = 7
    private let termRadius: CGFloat = 1.5
    private let lineWidth: CGFloat = 1.5
    private let inset: CGFloat = 2.0

    private var clamped: Int { max(0, min(100, percentage)) }

    var body: some View {
        HStack(spacing: 0) {
            batteryBody
            terminalNub
        }
    }

    private var batteryBody: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: bodyRadius)
                .strokeBorder(.primary.opacity(0.55), lineWidth: lineWidth)

            let fillFraction = CGFloat(clamped) / 100
            let maxFillWidth = bodyWidth - inset * 2
            let fillWidth = maxFillWidth * fillFraction

            if fillWidth > 0 {
                RoundedRectangle(cornerRadius: bodyRadius - 1)
                    .fill(fillColor)
                    .frame(width: fillWidth)
                    .padding(inset)
            }

            Text("\(clamped)")
                .font(.system(size: 9.5, weight: .bold, design: .rounded))
                .monospacedDigit()
                .frame(maxWidth: .infinity)
        }
        .frame(width: bodyWidth, height: bodyHeight)
    }

    private var terminalNub: some View {
        UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: termRadius,
            topTrailingRadius: termRadius
        )
        .fill(.primary.opacity(0.55))
        .frame(width: termWidth, height: termHeight)
        .offset(x: -lineWidth / 2)
    }

    private var fillColor: Color {
        if isCharging { return .green.opacity(0.45) }
        if clamped <= 10 { return .red.opacity(0.5) }
        if clamped <= 20 { return .orange.opacity(0.45) }
        return .primary.opacity(0.15)
    }
}

#Preview {
    HStack(spacing: 20) {
        BatteryIconView(percentage: 100, isCharging: false)
        BatteryIconView(percentage: 76, isCharging: false)
        BatteryIconView(percentage: 45, isCharging: true)
        BatteryIconView(percentage: 15, isCharging: false)
        BatteryIconView(percentage: 5, isCharging: false)
    }
    .padding()
}
