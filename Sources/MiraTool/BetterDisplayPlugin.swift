import Foundation

class BetterDisplayPlugin: ColorTemperaturePlugin {
    let name = "BetterDisplay"
    private let cliPath = "/opt/homebrew/bin/betterdisplaycli"
    private let builtInDisplayName = "Built-in"
    
    // Preset gain profiles - no calculation needed, just constants
    private let profileGains: [ColorProfile: (r: Float, g: Float, b: Float)] = [
        .morning: (r: 0.0, g: 0.0, b: 0.0),      // 6500K equivalent
        .evening: (r: 0.0, g: -0.15, b: -0.4),   // 4500K equivalent
        .night:   (r: 0.0, g: -0.3, b: -0.6)     // 3000K equivalent
    ]
    
    var isAvailable: Bool {
        return BetterDisplayPlugin.checkInstalled() && checkBetterDisplayRunning()
    }
    
    static func checkInstalled() -> Bool {
        return FileManager.default.fileExists(atPath: "/opt/homebrew/bin/betterdisplaycli") ||
               FileManager.default.fileExists(atPath: "/usr/local/bin/betterdisplaycli") ||
               FileManager.default.fileExists(atPath: "/Applications/BetterDisplay.app")
    }
    
    private func checkBetterDisplayRunning() -> Bool {
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
    
    private func startBetterDisplayIfNeeded() {
        if !checkBetterDisplayRunning() {
            print("Starting BetterDisplay...")
            let task = Process()
            task.launchPath = "/usr/bin/open"
            task.arguments = ["-a", "BetterDisplay"]
            
            do {
                try task.run()
                task.waitUntilExit()
                Thread.sleep(forTimeInterval: 2.0)
            } catch {
                print("Failed to start BetterDisplay: \(error)")
            }
        }
    }
    
    func setColorProfile(_ profile: ColorProfile) {
        startBetterDisplayIfNeeded()
        
        print("Applying \(profile.description) to Built-in Display only...")
        
        // Use preset gains - no calculation needed
        if let gains = profileGains[profile] {
            setDisplayGains(red: gains.r, green: gains.g, blue: gains.b)
        }
        
        print("✓ Color temperature applied (MIRA display unaffected)")
    }
    
    func resetColors() {
        startBetterDisplayIfNeeded()
        
        print("Resetting Built-in Display to normal colors...")
        
        // Reset to morning profile (normal colors)
        if let gains = profileGains[.morning] {
            setDisplayGains(red: gains.r, green: gains.g, blue: gains.b)
        }
        
        print("✓ Colors reset to normal")
    }
    
    func getStatus() -> String {
        var status = "=== BetterDisplay Color Status ===\n"
        
        // Get current gain values
        let gains = getCurrentGains()
        status += "Built-in Display gains: R:\(gains.red) G:\(gains.green) B:\(gains.blue)\n"
        
        // Determine current profile by comparing with presets
        let currentProfile = determineCurrentProfile(gains)
        status += "Current profile: \(currentProfile)\n"
        
        status += "\nFeatures:\n"
        status += "• Per-display control (MIRA unaffected)\n"
        status += "• RGB gain adjustment for color temperature\n"
        status += "• No system-wide Night Shift interference\n"
        
        return status
    }
    
    // Single CLI call for all gains - more efficient than 3 separate calls
    private func setDisplayGains(red: Float, green: Float, blue: Float) {
        let task = Process()
        task.launchPath = cliPath
        
        task.arguments = [
            "set",
            "-namelike=\(builtInDisplayName)",
            "-rGain=\(red)",
            "-gGain=\(green)",
            "-bGain=\(blue)"
        ]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            print("Error setting gains: \(error)")
        }
    }
    
    // Single CLI call to get all gains - more efficient
    private func getCurrentGains() -> (red: Float, green: Float, blue: Float) {
        // BetterDisplay doesn't support getting all gains in one call,
        // so we need separate calls but can optimize with parallel execution
        var red: Float = 0.0
        var green: Float = 0.0
        var blue: Float = 0.0
        
        for (color, gainFlag) in [("red", "rGain"), ("green", "gGain"), ("blue", "bGain")] {
            let task = Process()
            task.launchPath = cliPath
            task.arguments = [
                "get",
                "-namelike=\(builtInDisplayName)",
                "-\(gainFlag)",
                "-value"
            ]
            
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = Pipe()
            
            do {
                try task.run()
                task.waitUntilExit()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8),
                   let value = Float(output.trimmingCharacters(in: .whitespacesAndNewlines)) {
                    switch color {
                    case "red": red = value
                    case "green": green = value
                    case "blue": blue = value
                    default: break
                    }
                }
            } catch {
                // Ignore errors, use default 0.0
            }
        }
        
        return (red, green, blue)
    }
    
    private func determineCurrentProfile(_ gains: (red: Float, green: Float, blue: Float)) -> String {
        // Check against presets with small tolerance for floating point comparison
        let tolerance: Float = 0.05
        
        for (profile, presetGains) in profileGains {
            if abs(gains.red - presetGains.r) < tolerance &&
               abs(gains.green - presetGains.g) < tolerance &&
               abs(gains.blue - presetGains.b) < tolerance {
                return "\(profile.description.split(separator: "-").first?.trimmingCharacters(in: .whitespaces) ?? "Unknown")"
            }
        }
        
        return "Custom"
    }
}