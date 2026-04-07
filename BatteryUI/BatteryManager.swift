import Foundation
import IOKit.ps

@Observable
final class BatteryManager {
    var percentage: Int = 0
    var isCharging: Bool = false
    var isPluggedIn: Bool = false
    var isLowPowerMode: Bool = false

    private var timer: Timer?
    private var powerStateObserver: Any?

    init() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.refresh()
        }
        powerStateObserver = NotificationCenter.default.addObserver(
            forName: .NSProcessInfoPowerStateDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refresh()
        }
    }

    deinit {
        timer?.invalidate()
        if let obs = powerStateObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }

    func refresh() {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              let source = sources.first,
              let info = IOPSGetPowerSourceDescription(snapshot, source)?
                  .takeUnretainedValue() as? [String: Any]
        else { return }

        percentage = info[kIOPSCurrentCapacityKey as String] as? Int ?? 0
        isCharging = info[kIOPSIsChargingKey as String] as? Bool ?? false
        let state = info[kIOPSPowerSourceStateKey as String] as? String
        isPluggedIn = state == (kIOPSACPowerValue as String)
        isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    }
}
