import Foundation
import CoreGraphics
import IOKit
import AppKit

class MiraManager {
    private var powerAssertion: PowerAssertion?
    private let statusFile = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".mira_status")
    
    func startPreventingSleep() {
        if powerAssertion?.isActive == true {
            print("✓ Sleep prevention is already active")
            return
        }
        
        let miraInfo = detectMira()
        if !miraInfo.detected && !isForceMode() {
            print("⚠️  Mira display not detected")
            print("   Use 'mira start --force' to start anyway")
            return
        }
        
        powerAssertion = PowerAssertion()
        powerAssertion?.createAssertion()
        
        saveStatus(true, miraInfo: miraInfo)
        
        if miraInfo.detected {
            print("✓ Sleep prevention started for Mira display")
            if let name = miraInfo.displayName {
                print("  Display: \(name)")
            }
        } else {
            print("✓ Sleep prevention started (forced mode)")
        }
    }
    
    func stopPreventingSleep() {
        guard powerAssertion?.isActive == true else {
            print("Sleep prevention is not active")
            return
        }
        
        powerAssertion?.releaseAssertion()
        powerAssertion = nil
        saveStatus(false, miraInfo: (false, nil))
        print("✓ Sleep prevention stopped")
    }
    
    func checkStatus() {
        let miraInfo = detectMira()
        
        print("=== Mira Display Status ===")
        print("Display detected: \(miraInfo.detected ? "Yes" : "No")")
        if let name = miraInfo.displayName {
            print("Display name: \(name)")
        }
        
        let assertionActive = powerAssertion?.isActive ?? loadPersistedStatus()
        print("Sleep prevention: \(assertionActive ? "Active" : "Inactive")")
        
        print("\nConnected displays:")
        listAllDisplays()
    }
    
    private func detectMira() -> (detected: Bool, displayName: String?) {
        var displayCount: UInt32 = 0
        var displayIDs = [CGDirectDisplayID](repeating: 0, count: 16)
        
        CGGetOnlineDisplayList(16, &displayIDs, &displayCount)
        
        for i in 0..<Int(displayCount) {
            let displayID = displayIDs[i]
            if let displayName = getDisplayName(for: displayID) {
                let lowerName = displayName.lowercased()
                if lowerName.contains("mira") || lowerName.contains("onyx") || lowerName.contains("boox") {
                    return (true, displayName)
                }
            }
        }
        
        return (false, nil)
    }
    
    private func getDisplayName(for displayID: CGDirectDisplayID) -> String? {
        guard let screenNumber = NSScreen.screens.firstIndex(where: { 
            $0.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID == displayID 
        }) else { return nil }
        
        let screen = NSScreen.screens[screenNumber]
        return screen.localizedName
    }
    
    private func listAllDisplays() {
        var displayCount: UInt32 = 0
        var displayIDs = [CGDirectDisplayID](repeating: 0, count: 16)
        
        CGGetOnlineDisplayList(16, &displayIDs, &displayCount)
        
        for i in 0..<Int(displayCount) {
            let displayID = displayIDs[i]
            let isPrimary = CGDisplayIsMain(displayID) != 0
            let displayName = getDisplayName(for: displayID) ?? "Unknown"
            print("  \(i+1). \(displayName)\(isPrimary ? " (Primary)" : "")")
        }
    }
    
    private func isForceMode() -> Bool {
        return CommandLine.arguments.contains("--force") || CommandLine.arguments.contains("-f")
    }
    
    private func saveStatus(_ active: Bool, miraInfo: (detected: Bool, displayName: String?)) {
        let status = [
            "active": active,
            "timestamp": Date().timeIntervalSince1970,
            "miraDetected": miraInfo.detected,
            "displayName": miraInfo.displayName ?? ""
        ] as [String : Any]
        
        if let data = try? JSONSerialization.data(withJSONObject: status) {
            try? data.write(to: statusFile)
        }
    }
    
    private func loadPersistedStatus() -> Bool {
        guard let data = try? Data(contentsOf: statusFile),
              let status = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let active = status["active"] as? Bool else {
            return false
        }
        return active
    }
}