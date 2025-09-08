import Foundation

let version = "1.0.0"

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

switch command.lowercased() {
case "start":
    manager.startPreventingSleep()
    
case "stop":
    manager.stopPreventingSleep()
    
case "status":
    manager.checkStatus()
    
case "help", "--help", "-h":
    printUsage()
    
case "--version", "-v", "version":
    print("mira version \(version)")
    
default:
    print("Error: Unknown command '\(command)'")
    print("Run 'mira help' for usage information")
    exit(1)
}