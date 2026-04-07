import SwiftUI
import AppKit

@main
struct BatteryUIApp: App {
    @State private var batteryManager = BatteryManager()

    var body: some Scene {
        MenuBarExtra {
            Text("Power Source: \(batteryManager.isPluggedIn ? "Power Adapter" : "Battery")")
            Divider()
            Button("Battery Settings…") {
                Self.openSystemBatterySettings()
            }
            Divider()
            Button("Quit BatteryUI") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            Image(nsImage: BatteryIconView.menuBarImage(
                percentage: batteryManager.percentage,
                isPluggedIn: batteryManager.isPluggedIn,
                isLowPowerMode: batteryManager.isLowPowerMode
            ))
        }
    }

    private static func openSystemBatterySettings() {
        if #available(macOS 13.0, *) {
            if let url = URL(string: "x-apple.systempreferences:com.apple.Battery-Settings.extension") {
                NSWorkspace.shared.open(url)
                return
            }
        }
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.battery") {
            NSWorkspace.shared.open(url)
        }
    }
}
