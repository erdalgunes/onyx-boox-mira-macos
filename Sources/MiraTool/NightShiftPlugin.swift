import Foundation

class NightShiftPlugin: ColorTemperaturePlugin {
    let name = "Night Shift (System)"
    
    var isAvailable: Bool {
        // Night Shift is always available on macOS, but with limitations
        return true
    }
    
    func setColorProfile(_ profile: ColorProfile) {
        print("⚠️  Warning: Night Shift affects ALL displays including MIRA")
        print("For per-display control, install BetterDisplay:")
        print("  brew install --cask betterdisplay")
        print("")
        
        switch profile {
        case .morning:
            disableNightShift()
            print("✓ Night Shift disabled (cool temperature)")
            
        case .evening, .night:
            enableNightShift()
            print("✓ Night Shift enabled (warm temperature)")
        }
    }
    
    func resetColors() {
        disableNightShift()
        print("✓ Night Shift disabled")
    }
    
    func getStatus() -> String {
        var status = "=== Night Shift Status ===\n"
        
        let enabled = isNightShiftEnabled()
        status += "Night Shift: \(enabled ? "Enabled" : "Disabled")\n"
        status += "\n⚠️  Limitations:\n"
        status += "• Affects ALL displays (including MIRA)\n"
        status += "• No per-display control\n"
        status += "• Limited customization\n"
        status += "\nRecommended: Install BetterDisplay for better control\n"
        status += "  brew install --cask betterdisplay\n"
        
        return status
    }
    
    private func enableNightShift() {
        runCommand("/usr/bin/defaults", args: [
            "-currentHost", "write",
            "com.apple.CoreBrightness",
            "CBBlueReductionStatus",
            "-dict-add",
            "BlueReductionEnabled", "-bool", "true"
        ])
        notifyBrightnessChange()
    }
    
    private func disableNightShift() {
        runCommand("/usr/bin/defaults", args: [
            "-currentHost", "write",
            "com.apple.CoreBrightness",
            "CBBlueReductionStatus",
            "-dict-add",
            "BlueReductionEnabled", "-bool", "false"
        ])
        notifyBrightnessChange()
    }
    
    private func isNightShiftEnabled() -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["-currentHost", "read", "com.apple.CoreBrightness", "CBBlueReductionStatus"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8) {
                    return output.contains("BlueReductionEnabled = 1")
                }
            }
        } catch {
            // Ignore errors
        }
        
        return false
    }
    
    private func notifyBrightnessChange() {
        runCommand("/usr/bin/killall", args: ["-HUP", "corebrightnessdiag"], ignoreErrors: true)
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
}