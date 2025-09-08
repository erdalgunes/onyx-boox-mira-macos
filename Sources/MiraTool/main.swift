import Foundation

let version = "1.1.0"

func printUsage() {
    print("""
    mira - macOS CLI tool for Onyx Boox Mira e-ink display
    Version \(version)
    
    Usage:
      mira <command> [options]
    
    Commands:
      start         Prevent display and system sleep
      stop          Stop preventing sleep
      status        Show current status and connected displays
      temp          Color temperature commands:
                      temp auto     - Auto-adjust based on time of day
                      temp morning  - Cool temperature (more blue light)
                      temp evening  - Warm temperature (less blue light)
                      temp night    - Very warm temperature
                      temp reset    - Reset to normal colors
                      temp status   - Show current temperature settings
      help          Show this help message
    
    Options:
      --force, -f   Force start even if Mira is not detected
    
    Examples:
      mira start            # Start if Mira is detected
      mira start --force    # Start regardless of detection
      mira status           # Check current status
      mira stop             # Stop sleep prevention
    """)
}

let arguments = CommandLine.arguments.dropFirst()

guard let command = arguments.first else {
    printUsage()
    exit(0)
}

let manager = MiraManager()
let pluginManager = PluginManager.shared

switch command.lowercased() {
case "start":
    manager.startPreventingSleep()
    
case "stop":
    manager.stopPreventingSleep()
    
case "status":
    manager.checkStatus()
    
case "temp":
    guard let subCommand = arguments.dropFirst().first?.lowercased() else {
        print("Error: temp command requires a subcommand")
        print("Use: mira temp auto|morning|evening|night|status")
        exit(1)
    }
    
    switch subCommand {
    case "auto":
        pluginManager.autoAdjust()
        
    case "morning":
        pluginManager.applyColorProfile(.morning)
        
    case "evening":
        pluginManager.applyColorProfile(.evening)
        
    case "night":
        pluginManager.applyColorProfile(.night)
        
    case "reset":
        pluginManager.resetColors()
        
    case "status":
        pluginManager.showStatus()
        
    case "plugins":
        pluginManager.listPlugins()
        
    default:
        print("Error: Unknown temp command '\(subCommand)'")
        print("Use: mira temp auto|morning|evening|night|status")
        exit(1)
    }
    
case "help", "--help", "-h":
    printUsage()
    
case "--version", "-v", "version":
    print("mira version \(version)")
    
default:
    print("Error: Unknown command '\(command)'")
    print("Run 'mira help' for usage information")
    exit(1)
}