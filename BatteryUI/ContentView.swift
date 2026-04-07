import SwiftUI
import AppKit

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

    // MARK: - NSImage for MenuBarExtra label

    static func menuBarImage(percentage: Int, isPluggedIn: Bool, isLowPowerMode: Bool) -> NSImage {
        let clamped = max(0, min(100, percentage))

        let bodyW: CGFloat = 32
        let bodyH: CGFloat = 15
        let bodyR: CGFloat = 3.5
        let termW: CGFloat = 3
        let termH: CGFloat = 7
        let termR: CGFloat = 1.5
        let stroke: CGFloat = 1.5
        let pad: CGFloat = 2.0

        let totalW = bodyW + termW

        let image = NSImage(size: NSSize(width: totalW, height: bodyH), flipped: false) { _ in
            let chrome = NSColor.white.withAlphaComponent(0.85)
            let fillColor: NSColor
            if isLowPowerMode {
                fillColor = .systemYellow
            } else if clamped <= 20 {
                fillColor = .systemRed
            } else if isPluggedIn {
                fillColor = .systemGreen
            } else {
                fillColor = .white.withAlphaComponent(0.3)
            }

            // Battery body outline
            let bodyRect = NSRect(x: stroke / 2, y: stroke / 2,
                                  width: bodyW - stroke, height: bodyH - stroke)
            let bodyPath = NSBezierPath(roundedRect: bodyRect, xRadius: bodyR, yRadius: bodyR)
            bodyPath.lineWidth = stroke
            chrome.setStroke()
            bodyPath.stroke()

            // Fill level (always green)
            let fillMaxW = bodyW - pad * 2 - stroke
            let fillW = fillMaxW * CGFloat(clamped) / 100
            if fillW > 0 {
                let fillRect = NSRect(x: pad + stroke / 2, y: pad + stroke / 2,
                                      width: fillW, height: bodyH - pad * 2 - stroke)
                let fillPath = NSBezierPath(roundedRect: fillRect,
                                            xRadius: max(0, bodyR - 1),
                                            yRadius: max(0, bodyR - 1))
                fillColor.setFill()
                fillPath.fill()
            }

            // Terminal nub
            let termX = bodyW - stroke / 2
            let termY = (bodyH - termH) / 2
            let termRect = NSRect(x: termX, y: termY, width: termW, height: termH)
            let termPath = NSBezierPath(roundedRect: termRect, xRadius: termR, yRadius: termR)
            chrome.setFill()
            termPath.fill()

            // Percentage text
            let baseDesc = NSFont.systemFont(ofSize: 9.5, weight: .bold).fontDescriptor
            let roundedDesc = baseDesc.withDesign(.rounded) ?? baseDesc
            let font = NSFont(descriptor: roundedDesc, size: 9.5)
                ?? NSFont.boldSystemFont(ofSize: 9.5)

            let style = NSMutableParagraphStyle()
            style.alignment = .center

            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: isLowPowerMode ? NSColor.black : NSColor.white,
                .paragraphStyle: style,
            ]
            let text = "\(clamped)" as NSString
            let textSize = text.size(withAttributes: attrs)
            let textRect = NSRect(x: 0,
                                  y: (bodyH - textSize.height) / 2,
                                  width: bodyW,
                                  height: textSize.height)
            text.draw(in: textRect, withAttributes: attrs)

            return true
        }

        image.isTemplate = false
        return image
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
