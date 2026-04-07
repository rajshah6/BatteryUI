import SwiftUI

@main
struct BatteryUIApp: App {
    @State private var batteryManager = BatteryManager()

    var body: some Scene {
        MenuBarExtra {
            Text("Battery: \(batteryManager.percentage)%")
            Text(batteryManager.isCharging ? "Charging" : "On Battery")
            Divider()
            Button("Quit BatteryUI") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            Image(nsImage: BatteryIconView.menuBarImage(
                percentage: batteryManager.percentage,
                isCharging: batteryManager.isCharging
            ))
        }
    }
}
