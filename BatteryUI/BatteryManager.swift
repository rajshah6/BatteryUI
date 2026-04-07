import Foundation
import IOKit.ps

@Observable
final class BatteryManager {
    var percentage: Int = 0
    var isCharging: Bool = false
    var isPluggedIn: Bool = false

    private var timer: Timer?

    init() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    deinit {
        timer?.invalidate()
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
    }
}
