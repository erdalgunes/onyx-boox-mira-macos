import Foundation

class BetterDisplayPlugin: ColorTemperaturePlugin {
    let name = "BetterDisplay"
    private let cliPath = "/opt/homebrew/bin/betterdisplaycli"
    private let builtInDisplayName = "Built-in"
    
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
        
        let gains = getGainsForProfile(profile)
        
        print("Applying \(profile.description) to Built-in Display only...")
        
        setDisplayGain("red", value: gains.red)
        setDisplayGain("green", value: gains.green)
        setDisplayGain("blue", value: gains.blue)
        
        print("✓ Color temperature applied (MIRA display unaffected)")
    }
    
    func resetColors() {
        startBetterDisplayIfNeeded()
        
        print("Resetting Built-in Display to normal colors...")
        
        setDisplayGain("red", value: 0.0)
        setDisplayGain("green", value: 0.0)
        setDisplayGain("blue", value: 0.0)
        
        print("✓ Colors reset to normal")
    }
    
    func getStatus() -> String {
        var status = "=== BetterDisplay Color Status ===\n"
        
        // Get current gain values
        let gains = getCurrentGains()
        status += "Built-in Display gains: R:\(gains.red) G:\(gains.green) B:\(gains.blue)\n"
        
        // Determine current profile based on gains
        if gains.blue < -0.5 {
            status += "Current profile: Night (very warm)\n"
        } else if gains.blue < -0.3 {
            status += "Current profile: Evening (warm)\n"
        } else if abs(gains.red) < 0.1 && abs(gains.green) < 0.1 && abs(gains.blue) < 0.1 {
            status += "Current profile: Normal/Morning (cool)\n"
        } else {
            status += "Current profile: Custom\n"
        }
        
        status += "\nFeatures:\n"
        status += "• Per-display control (MIRA unaffected)\n"
        status += "• No system-wide Night Shift interference\n"
        
        return status
    }
    
    private func getGainsForProfile(_ profile: ColorProfile) -> (red: Float, green: Float, blue: Float) {
        switch profile {
        case .morning:
            return (red: 0.0, green: 0.0, blue: 0.0)
        case .evening:
            return (red: 0.0, green: -0.15, blue: -0.40)
        case .night:
            return (red: 0.0, green: -0.30, blue: -0.60)
        }
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
            "-namelike=\(builtInDisplayName)",
            "\(gainParam)=\(value)"
        ]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            print("Error setting \(color) gain: \(error)")
        }
    }
    
    private func getCurrentGains() -> (red: Float, green: Float, blue: Float) {
        var red: Float = 0.0
        var green: Float = 0.0
        var blue: Float = 0.0
        
        for (color, index) in [("r", 0), ("g", 1), ("b", 2)] {
            let task = Process()
            task.launchPath = cliPath
            task.arguments = [
                "get",
                "-namelike=\(builtInDisplayName)",
                "-\(color)Gain",
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
                    switch index {
                    case 0: red = value
                    case 1: green = value
                    case 2: blue = value
                    default: break
                    }
                }
            } catch {
                // Ignore errors, use default 0.0
            }
        }
        
        return (red, green, blue)
    }
}