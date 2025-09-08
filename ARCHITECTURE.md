# Mira CLI Architecture

## Design Principles

This project follows core software engineering principles:

### DRY (Don't Repeat Yourself)
- Single `ColorProfile` enum definition in PluginManager
- Protocol-based plugin system eliminates code duplication
- Removed 4 redundant manager files during refactoring

### KISS (Keep It Simple, Stupid)
- Plugin architecture justified for clean separation of concerns
- Progressive enhancement: works without dependencies, better with them
- Minimal abstraction cost (116 lines for PluginManager)

### YAGNI (You Aren't Gonna Need It)
- Removed unused managers: BetterDisplayManager, ColorTemperatureManager, SimpleColorManager, NightShiftCLI
- Kept only essential plugins: BetterDisplay and NightShift
- No speculative features added

### SOLID Principles
- **Single Responsibility**: Each plugin manages its own display control
- **Open/Closed**: New plugins can be added without modifying existing code
- **Liskov Substitution**: All plugins implement ColorTemperaturePlugin protocol
- **Interface Segregation**: Minimal protocol with only essential methods
- **Dependency Inversion**: Main depends on abstraction (PluginManager), not concrete plugins

## Architecture Overview

```
┌─────────────┐
│  main.swift │
└──────┬──────┘
       │ uses
       ▼
┌──────────────────┐
│  PluginManager   │ ◄── Singleton pattern
│    (116 lines)   │     Progressive enhancement
└────────┬─────────┘
         │ manages
         ▼
┌──────────────────────────────────┐
│   ColorTemperaturePlugin         │ ◄── Protocol abstraction
│   - name: String                 │
│   - isAvailable: Bool            │
│   - setColorProfile()            │
│   - resetColors()                │
│   - getStatus()                  │
└────────┬──────────────┬──────────┘
         │              │
    implements     implements
         │              │
         ▼              ▼
┌─────────────┐  ┌─────────────────┐
│BetterDisplay│  │   NightShift    │
│   Plugin    │  │     Plugin      │
│             │  │                 │
│ Per-display │  │  System-wide    │
│   control   │  │   fallback      │
└─────────────┘  └─────────────────┘
```

## Plugin System Rationale

### Why Plugins for Only 2 Implementations?

1. **Clean Separation**: Each plugin encapsulates platform-specific logic
2. **Progressive Enhancement**: 
   - Works without dependencies (NightShift)
   - Better with BetterDisplay installed
   - Future support for f.lux, Lunar, etc.
3. **User Experience**: Auto-detection and suggestions guide users to optimal setup
4. **Minimal Cost**: 116 lines is not bloat for the flexibility gained

### Plugin Priority

1. **BetterDisplay** (Primary)
   - Per-display control
   - Keeps e-ink display unaffected
   - Requires installation

2. **Night Shift** (Fallback)
   - Built into macOS
   - Zero dependencies
   - Clear warnings about limitations

## File Structure

```
Sources/MiraTool/
├── main.swift              # CLI entry point
├── MiraManager.swift       # Display detection & sleep prevention
├── PowerAssertion.swift   # macOS power management
├── PluginManager.swift     # Plugin orchestration
├── BetterDisplayPlugin.swift  # BetterDisplay integration
└── NightShiftPlugin.swift # Night Shift fallback
```

## Distribution Strategy

### Homebrew Tap
- Repository: `homebrew-mira`
- Formula: Binary distribution with SHA256
- Dependencies: None required, BetterDisplay optional

### Binary Release
- Pre-compiled for fast installation
- No build dependencies for users
- Universal binary for Apple Silicon and Intel

## Future Extensibility

The plugin architecture allows easy addition of:
- f.lux integration
- Lunar app support
- Custom color profiles
- Time-based automation

## Decision Log

### 2024-01 - Initial Architecture
- Decision: Use plugin architecture despite only 2 implementations
- Rationale: Clean separation, progressive enhancement, future extensibility
- Outcome: Flexible system with minimal overhead

### 2024-01 - Remove Unused Managers
- Decision: Delete 4 unused manager files
- Rationale: YAGNI violation, unnecessary complexity
- Outcome: Reduced codebase by ~600 lines

### 2024-01 - Keep Night Shift Fallback
- Decision: Retain Night Shift plugin despite limitations
- Rationale: Zero-dependency solution for new users
- Outcome: Works out-of-box with clear upgrade path