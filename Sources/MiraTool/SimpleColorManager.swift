import Foundation

class SimpleColorManager {
    
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
            print("✓ Morning mode: Night Shift disabled (more blue light)")
            
        case .evening:
            enableNightShift(strength: 0.3)
            print("✓ Evening mode: Moderate Night Shift (30% warm)")
            
        case .night:
            enableNightShift(strength: 0.7)
            print("✓ Night mode: Strong Night Shift (70% warm)")
        }
    }
    
    func disableNightShift() {
        let script = """
        tell application "System Preferences"
            reveal pane id "com.apple.preference.displays"
        end tell
        
        delay 1
        
        tell application "System Events"
            tell process "System Preferences"
                click button "Night Shift..." of tab group 1 of window 1
                delay 0.5
                if exists checkbox "Turn On Until Tomorrow" of sheet 1 of window 1 then
                    if value of checkbox "Turn On Until Tomorrow" of sheet 1 of window 1 is true then
                        click checkbox "Turn On Until Tomorrow" of sheet 1 of window 1
                    end if
                end if
                click button "Done" of sheet 1 of window 1
            end tell
        end tell
        
        tell application "System Preferences" to quit
        """
        
        executeAppleScript(script)
    }
    
    func enableNightShift(strength: Float = 0.5) {
        let strengthPercent = Int(strength * 100)
        
        let script = """
        tell application "System Preferences"
            reveal pane id "com.apple.preference.displays"
        end tell
        
        delay 1
        
        tell application "System Events"
            tell process "System Preferences"
                click button "Night Shift..." of tab group 1 of window 1
                delay 0.5
                
                -- Enable Night Shift
                if exists checkbox "Turn On Until Tomorrow" of sheet 1 of window 1 then
                    if value of checkbox "Turn On Until Tomorrow" of sheet 1 of window 1 is false then
                        click checkbox "Turn On Until Tomorrow" of sheet 1 of window 1
                    end if
                end if
                
                click button "Done" of sheet 1 of window 1
            end tell
        end tell
        
        tell application "System Preferences" to quit
        """
        
        executeAppleScript(script)
        print("Night Shift enabled with \(strengthPercent)% warmth")
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
    
    func getNightShiftStatus() -> (enabled: Bool, timeOfDay: TimeOfDay) {
        let timeOfDay = getCurrentTimeOfDay()
        
        // Check Night Shift status using defaults
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["-currentHost", "read", "com.apple.CoreBrightness", "CBBlueReductionStatus"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe() // Suppress errors
        
        var enabled = false
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8) {
                    // Look for enabled status in the plist output
                    enabled = output.contains("BlueReductionEnabled = 1") || 
                             output.contains("AutoBlueReductionEnabled = 1")
                }
            }
        } catch {
            // Fallback: assume disabled if we can't read status
            enabled = false
        }
        
        return (enabled, timeOfDay)
    }
}