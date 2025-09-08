import Foundation
import AppKit

class ColorTemperatureManager {
    private let userDefaults = UserDefaults(suiteName: "com.apple.CoreBrightness")
    private let nightShiftDefaults = UserDefaults(suiteName: "com.apple.CoreBrightness.NightShift")
    
    enum ColorTemperature: Float {
        case cool = 6500.0      // Morning - more blue light
        case neutral = 5500.0   // Default
        case warm = 3200.0      // Evening - less blue light
        case veryWarm = 2700.0  // Night
    }
    
    enum TimeOfDay {
        case morning    // 6 AM - 6 PM
        case evening    // 6 PM - 10 PM  
        case night      // 10 PM - 6 AM
        
        var temperature: ColorTemperature {
            switch self {
            case .morning: return .cool
            case .evening: return .warm
            case .night: return .veryWarm
            }
        }
    }
    
    func getCurrentTimeOfDay() -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 6..<18: return .morning
        case 18..<22: return .evening
        default: return .night
        }
    }
    
    func setNightShiftEnabled(_ enabled: Bool) {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [
            "-e",
            """
            tell application "System Events"
                tell process "System Preferences"
                    \(enabled ? "do shell script \"defaults write /Library/Preferences/com.apple.CoreBrightness 'CBBlueReductionStatus' -dict-add 'AutoBlueReductionEnabled' -bool true\"" : "do shell script \"defaults write /Library/Preferences/com.apple.CoreBrightness 'CBBlueReductionStatus' -dict-add 'AutoBlueReductionEnabled' -bool false\"")
                end tell
            end tell
            """
        ]
        
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            print("Failed to set Night Shift: \(error)")
        }
    }
    
    func setColorTemperatureForCurrentTime() {
        let timeOfDay = getCurrentTimeOfDay()
        print("Setting color temperature for \(timeOfDay)")
        
        switch timeOfDay {
        case .morning:
            enableNightShift(false)
            print("Morning mode: Disabled Night Shift (more blue light)")
            
        case .evening:
            enableNightShift(true)
            setNightShiftStrength(0.3) // Moderate warmth
            print("Evening mode: Moderate Night Shift")
            
        case .night:
            enableNightShift(true)
            setNightShiftStrength(0.8) // High warmth
            print("Night mode: Strong Night Shift (very warm)")
        }
    }
    
    func enableNightShift(_ enabled: Bool) {
        let script = enabled ? 
            "tell application \"System Events\" to keystroke \"\" using {shift down}" :
            "tell application \"System Events\" to keystroke \"\" using {shift down}"
        
        executeAppleScript(script)
    }
    
    func setNightShiftStrength(_ strength: Float) {
        // Use defaults command to set Night Shift strength
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = [
            "write",
            "com.apple.CoreBrightness",
            "CBBlueReductionStatus",
            "-dict-add",
            "BlueReductionFactor",
            String(strength)
        ]
        
        do {
            try task.run()
            task.waitUntilExit()
            
            // Notify the system to refresh the setting
            notifyNightShiftChanged()
        } catch {
            print("Failed to set Night Shift strength: \(error)")
        }
    }
    
    private func notifyNightShiftChanged() {
        let task = Process()
        task.launchPath = "/usr/bin/killall"
        task.arguments = ["corebrightnessdiag"]
        
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            // Ignore errors - this is just a notification
        }
    }
    
    private func executeAppleScript(_ script: String) {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", script]
        
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            print("AppleScript error: \(error)")
        }
    }
    
    func getColorTemperatureStatus() -> (enabled: Bool, strength: Float, timeOfDay: TimeOfDay) {
        let timeOfDay = getCurrentTimeOfDay()
        
        // Try to read current Night Shift settings
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["read", "com.apple.CoreBrightness", "CBBlueReductionStatus"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        var enabled = false
        var strength: Float = 0.0
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                enabled = output.contains("AutoBlueReductionEnabled = 1")
                
                // Parse strength if available
                if let range = output.range(of: "BlueReductionFactor = ") {
                    let substring = output[range.upperBound...]
                    if let value = Float(String(substring.prefix(while: { $0.isNumber || $0 == "." }))) {
                        strength = value
                    }
                }
            }
        } catch {
            print("Failed to read Night Shift status: \(error)")
        }
        
        return (enabled, strength, timeOfDay)
    }
}