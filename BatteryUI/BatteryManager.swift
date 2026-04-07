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
    private var powerSourceRunLoopSource: CFRunLoopSource?

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

        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        if let source = IOPSNotificationCreateRunLoopSource({ context in
            guard let context else { return }
            let manager = Unmanaged<BatteryManager>.fromOpaque(context).takeUnretainedValue()
            DispatchQueue.main.async { manager.refresh() }
        }, context)?.takeRetainedValue() {
            powerSourceRunLoopSource = source
            CFRunLoopAddSource(CFRunLoopGetMain(), source, .defaultMode)
        }
    }

    deinit {
        timer?.invalidate()
        if let obs = powerStateObserver {
            NotificationCenter.default.removeObserver(obs)
        }
        if let source = powerSourceRunLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .defaultMode)
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
