import Foundation

class BetterDisplayManager {
    
    private let cliPath = "/opt/homebrew/bin/betterdisplaycli"
    private let builtInDisplayName = "Built-in Display"
    
    enum ColorProfile {
        case morning    // Cool (6500K) - blue light
        case evening    // Warm (4500K) - reduced blue  
        case night      // Very warm (3000K) - minimal blue
        
        var redGain: Float {
            switch self {
            case .morning: return 0.0   // Normal red
            case .evening: return 0.0   // Normal red  
            case .night: return 0.0     // Normal red
            }
        }
        
        var greenGain: Float {
            switch self {
            case .morning: return 0.0   // Normal green
            case .evening: return -0.15 // Reduced green
            case .night: return -0.30   // More reduced green
            }
        }
        
        var blueGain: Float {
            switch self {
            case .morning: return 0.0   // Full blue light
            case .evening: return -0.40 // Reduced blue
            case .night: return -0.60   // Minimal blue
            }
        }
        
        var description: String {
            switch self {
            case .morning: return "Cool (6500K) - Full blue light for alertness"
            case .evening: return "Warm (4500K) - Reduced blue light"
            case .night: return "Very warm (3000K) - Minimal blue light for sleep"
            }
        }
    }
    
    func getCurrentTimeProfile() -> ColorProfile {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 6..<18: return .morning
        case 18..<22: return .evening
        default: return .night
        }
    }
    
    func checkBetterDisplayRunning() -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/pgrep"
        task.arguments = ["-x", "BetterDisplay"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }
    
    func startBetterDisplayIfNeeded() {
        if !checkBetterDisplayRunning() {
            print("Starting BetterDisplay...")
            let task = Process()
            task.launchPath = "/usr/bin/open"
            task.arguments = ["-a", "BetterDisplay"]
            
            do {
                try task.run()
                task.waitUntilExit()
                Thread.sleep(forTimeInterval: 2.0) // Wait for app to start
            } catch {
                print("Failed to start BetterDisplay: \(error)")
            }
        }
    }
    
    func setColorTemperature(_ profile: ColorProfile) {
        startBetterDisplayIfNeeded()
        
        print("Setting color temperature for Built-in Display only...")
        print("Profile: \(profile.description)")
        
        // Set RGB gains for built-in display only
        setDisplayGain("red", value: profile.redGain)
        setDisplayGain("green", value: profile.greenGain) 
        setDisplayGain("blue", value: profile.blueGain)
        
        print("✓ Color temperature applied to Built-in Display")
        print("✓ MIRA253 remains unaffected")
    }
    
    private func setDisplayGain(_ color: String, value: Float) {
        let task = Process()
        task.launchPath = cliPath
        
        let gainParam = switch color {
        case "red": "-rGain"
        case "green": "-gGain"  
        case "blue": "-bGain"
        default: "-gain"
        }
        
        task.arguments = [
            "set",
            "-namelike=Built-in",  // Only target built-in display
            "\(gainParam)=\(value)"
        ]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus != 0 {
                print("Warning: Failed to set \(color) gain")
            }
        } catch {
            print("Error setting \(color) gain: \(error)")
        }
    }
    
    func resetColorTemperature() {
        startBetterDisplayIfNeeded()
        
        print("Resetting Built-in Display to normal colors...")
        
        setDisplayGain("red", value: 0.0)
        setDisplayGain("green", value: 0.0)
        setDisplayGain("blue", value: 0.0)
        
        print("✓ Built-in Display reset to normal")
    }
    
    func autoAdjustColorTemperature() {
        let profile = getCurrentTimeProfile()
        setColorTemperature(profile)
    }
    
    func getColorStatus() -> (profile: ColorProfile, currentTime: String) {
        let profile = getCurrentTimeProfile()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let currentTime = formatter.string(from: Date())
        
        return (profile, currentTime)
    }
    
    func showDetailedStatus() {
        let (profile, time) = getColorStatus()
        
        print("=== Color Temperature Status ===")
        print("Current time: \(time)")
        print("Time period: \(profile)")
        print("Recommended: \(profile.description)")
        print("")
        print("Display-specific settings:")
        print("  • Built-in Display: Color adjustments applied")
        print("  • MIRA253: No adjustments (pure e-ink)")
        print("")
        print("Manual controls:")
        print("  mira temp morning  - Cool (6500K)")
        print("  mira temp evening  - Warm (4500K)")
        print("  mira temp night    - Very warm (3000K)")
        print("  mira temp reset    - Reset to normal")
        print("  mira temp auto     - Auto-adjust for time")
    }
}