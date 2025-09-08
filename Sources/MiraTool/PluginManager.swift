import Foundation

protocol ColorTemperaturePlugin: AnyObject {
    var name: String { get }
    var isAvailable: Bool { get }
    func setColorProfile(_ profile: ColorProfile)
    func resetColors()
    func getStatus() -> String
}

enum ColorProfile {
    case morning
    case evening
    case night
    
    var description: String {
        switch self {
        case .morning: return "Cool (6500K) - Full blue light"
        case .evening: return "Warm (4500K) - Reduced blue light"
        case .night: return "Very warm (3000K) - Minimal blue light"
        }
    }
}

class PluginManager {
    static let shared = PluginManager()
    private var plugins: [ColorTemperaturePlugin] = []
    private var activePlugin: ColorTemperaturePlugin?
    
    private init() {
        loadAvailablePlugins()
    }
    
    private func loadAvailablePlugins() {
        // Check for BetterDisplay
        if BetterDisplayPlugin.checkInstalled() {
            let betterDisplay = BetterDisplayPlugin()
            plugins.append(betterDisplay)
            print("✓ BetterDisplay plugin loaded")
        } else {
            // Suggest BetterDisplay installation for optimal experience
            suggestBetterDisplay()
        }
        
        // Check for f.lux (future)
        // if FluxPlugin.checkInstalled() {
        //     plugins.append(FluxPlugin())
        // }
        
        // Fallback to built-in Night Shift
        plugins.append(NightShiftPlugin())
        
        // Set the first available plugin as active
        activePlugin = plugins.first { $0.isAvailable }
    }
    
    func listPlugins() {
        print("=== Available Color Temperature Plugins ===")
        for plugin in plugins {
            let status = plugin.isAvailable ? "✓ Available" : "✗ Not available"
            let active = plugin === activePlugin ? " (Active)" : ""
            print("\(plugin.name): \(status)\(active)")
        }
    }
    
    func setActivePlugin(name: String) -> Bool {
        if let plugin = plugins.first(where: { $0.name.lowercased() == name.lowercased() && $0.isAvailable }) {
            activePlugin = plugin
            print("Active plugin set to: \(plugin.name)")
            return true
        }
        print("Plugin '\(name)' not found or not available")
        return false
    }
    
    func applyColorProfile(_ profile: ColorProfile) {
        guard let plugin = activePlugin else {
            print("No color temperature plugin available")
            print("Install BetterDisplay for per-display control: brew install --cask betterdisplay")
            return
        }
        
        plugin.setColorProfile(profile)
    }
    
    func resetColors() {
        guard let plugin = activePlugin else {
            print("No color temperature plugin available")
            return
        }
        
        plugin.resetColors()
    }
    
    func showStatus() {
        guard let plugin = activePlugin else {
            print("No color temperature plugin available")
            return
        }
        
        print("Active plugin: \(plugin.name)")
        print(plugin.getStatus())
    }
    
    func getCurrentTimeProfile() -> ColorProfile {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 6..<18: return .morning
        case 18..<22: return .evening
        default: return .night
        }
    }
    
    func autoAdjust() {
        let profile = getCurrentTimeProfile()
        print("Auto-adjusting for \(profile.description)")
        applyColorProfile(profile)
    }
    
    private func suggestBetterDisplay() {
        print("💡 BetterDisplay not detected")
        print("   For optimal per-display color control that keeps your")
        print("   Mira e-ink display unaffected, install BetterDisplay:")
        print("")
        print("   brew install --cask betterdisplay")
        print("")
        print("   Using Night Shift fallback (affects all displays)")
    }
    
    func checkOptimalSetup() -> Bool {
        return BetterDisplayPlugin.checkInstalled()
    }
}