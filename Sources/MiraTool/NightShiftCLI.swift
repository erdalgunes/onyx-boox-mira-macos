import Foundation

class NightShiftCLI {
    
    enum TimeOfDay: String, CaseIterable {
        case morning = "morning"
        case evening = "evening" 
        case night = "night"
        
        var description: String {
            switch self {
            case .morning: return "Morning (6AM-6PM): Cool temperature, more blue light"
            case .evening: return "Evening (6PM-10PM): Warm temperature, reduced blue light"  
            case .night: return "Night (10PM-6AM): Very warm temperature, minimal blue light"
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
    
    func setColorTemperatureForCurrentTime() {
        let timeOfDay = getCurrentTimeOfDay()
        print("Current time period: \(timeOfDay.rawValue)")
        
        switch timeOfDay {
        case .morning:
            disableNightShift()
            
        case .evening:
            enableNightShift()
            print("✓ Evening mode: Night Shift enabled (warm temperature)")
            
        case .night:
            enableNightShift()
            print("✓ Night mode: Night Shift enabled (very warm temperature)")
        }
    }
    
    func disableNightShift() {
        // Use defaults to disable Night Shift
        runCommand("/usr/bin/defaults", args: ["-currentHost", "write", "com.apple.CoreBrightness", "CBBlueReductionStatus", "-dict-add", "BlueReductionEnabled", "-bool", "false"])
        
        // Trigger the change
        notifyBrightnessChange()
        print("✓ Morning mode: Night Shift disabled (more blue light)")
    }
    
    func enableNightShift() {
        // Use defaults to enable Night Shift
        runCommand("/usr/bin/defaults", args: ["-currentHost", "write", "com.apple.CoreBrightness", "CBBlueReductionStatus", "-dict-add", "BlueReductionEnabled", "-bool", "true"])
        
        // Trigger the change
        notifyBrightnessChange()
    }
    
    private func notifyBrightnessChange() {
        // Notify CoreBrightness about the change
        runCommand("/usr/bin/killall", args: ["-HUP", "corebrightnessdiag"], ignoreErrors: true)
        
        // Alternative: restart the brightness daemon
        runCommand("/usr/bin/pkill", args: ["-f", "corebrightnessdiag"], ignoreErrors: true)
    }
    
    private func runCommand(_ command: String, args: [String], ignoreErrors: Bool = false) {
        let task = Process()
        task.launchPath = command
        task.arguments = args
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if !ignoreErrors && task.terminationStatus != 0 {
                print("Warning: Command failed with status \(task.terminationStatus)")
            }
        } catch {
            if !ignoreErrors {
                print("Error running command: \(error)")
            }
        }
    }
    
    func getNightShiftStatus() -> (enabled: Bool, timeOfDay: TimeOfDay) {
        let timeOfDay = getCurrentTimeOfDay()
        
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["-currentHost", "read", "com.apple.CoreBrightness", "CBBlueReductionStatus"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        
        var enabled = false
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8) {
                    enabled = output.contains("BlueReductionEnabled = 1")
                }
            }
        } catch {
            // Default to false if can't read
        }
        
        return (enabled, timeOfDay)
    }
    
    func showDetailedStatus() {
        let (enabled, timeOfDay) = getNightShiftStatus()
        
        print("=== Color Temperature Status ===")
        print("Night Shift enabled: \(enabled ? "Yes" : "No")")
        print("Current time period: \(timeOfDay.rawValue)")
        print("Recommended: \(timeOfDay.description)")
        print("")
        print("Manual controls:")
        print("  mira temp morning  - Disable Night Shift")
        print("  mira temp evening  - Enable Night Shift") 
        print("  mira temp night    - Enable Night Shift")
        print("  mira temp auto     - Auto-adjust for time of day")
    }
}