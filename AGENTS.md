# BLEScanner - Master Agent Instructions

**Last updated**: October 3, 2025

## Overview

This document serves as the master instructions file for AI coding agents working on the BLEScanner project. All agents should read and follow these guidelines.

## Core Principles

### 1. Commit Workflow (CRITICAL)

**NEVER commit automatically** - This is the most important rule.

When the user asks to commit changes:
1. **Check repository status**: Run `git status` to see what has changed
2. **Stage all changes**: Use `git add .` to stage modified, new, and deleted files
3. **Analyze changes**: Review staged changes with `git diff --staged`
4. **Generate commit message**: Create a detailed commit message using conventional commits format
5. **Present to user**: Show the generated commit message and wait for explicit confirmation
6. **Execute only after confirmation**: Run `git commit` only when user explicitly approves

**User triggers**: When user says "commit the latest changes", "commit these changes", "stage and commit", etc., follow the workflow above but STOP before executing the commit.

### 2. Conventional Commit Format

Use this structure for all commit messages:

```
<type>(<scope>): <description>

[optional body explaining what and why, not how]

[optional footer(s) with breaking changes, closes issues, etc.]
```

**Commit types**:
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation updates
- `refactor`: Code refactoring without behavior changes
- `test`: Adding or modifying tests
- `chore`: Maintenance tasks (dependencies, build config)
- `style`: Code style changes (formatting, linting)
- `perf`: Performance improvements
- `ci`: CI/CD configuration changes
- `build`: Build system changes
- `revert`: Reverting previous commits

**Scopes for this project**:
- `parser`: Manufacturer data parsing logic
- `scanner`: BLE scanning and device discovery
- `signal`: RSSI analysis and distance estimation
- `cli`: Command-line interface and argument handling
- `docs`: Documentation and instruction files
- `deps`: Dependency management
- `config`: Project configuration files

### 3. Documentation Standards

- Write clear, professional documentation without emojis
- Use plain text formatting and descriptive language
- Focus on technical accuracy and readability
- Maintain consistent formatting throughout all documentation
- Update timestamps when modifying instruction files

### 4. Code Quality Standards

- Follow Swift naming conventions (camelCase for variables/functions, PascalCase for types)
- Use meaningful variable and function names
- Prefer explicit types when clarity is improved
- Use guard statements for early returns
- Implement proper error handling
- Add detailed comments for complex logic

### 5. Instruction File Maintenance

**When to update AGENTS.md** (this file):
- Coding standards or conventions change
- New project-wide policies are established
- Commit workflow modifications
- Documentation style guidelines evolve
- Cross-project decisions are made
- Project-specific technical details change
- New manufacturer support is added
- Build or run instructions are modified
- Data structure documentation updates
- Project architecture changes

**Update format for AGENTS.md**:
- Update "Last updated" timestamp at the top
- Add entry to "Recent Updates & Decisions" section at the bottom
- Include: date, brief description, reasoning

### 6. File Operations

- Always use absolute file paths when invoking tools
- Read sufficient context before making changes
- Never use placeholder comments like `...existing code...` in actual edits
- Prefer larger, meaningful reads over many small consecutive reads
- Use appropriate tools: `replace_string_in_file` for edits, not terminal commands

### 7. Context Gathering

- Don't make assumptions - gather context first
- Use semantic search for unfamiliar codebases
- Read files in large chunks when possible
- Call multiple independent tools in parallel when appropriate
- Never call `semantic_search` in parallel with other tools

### 8. Communication Style

- Keep answers short and impersonal
- Use proper Markdown formatting
- Wrap filenames and symbols in backticks
- Don't mention tool names to users (say "I'll run a command" not "I'll use run_in_terminal")
- Use KaTeX for math equations when needed

## Project-Specific Context

**Project**: BLEScanner - Swift CLI tool for Bluetooth Low Energy device scanning and analysis

**Repository**: https://github.com/ultralove/beacon-browser

**Technologies**:
- Language: Swift 6.1+
- Package Manager: Swift Package Manager (SPM)
- Platform: macOS
- Dependencies: Swift Argument Parser, CoreBluetooth

**Primary Files**:
- `Sources/BLEScanner.swift`: Main application code
- `Package.swift`: SPM configuration
- `.github/copilot-instructions.md`: Reference to this file

## Project Structure

```
BLEScanner/
├── Package.swift                 # Swift Package Manager configuration
├── Package.resolved             # Dependency lock file
├── Sources/
│   └── BLEScanner.swift         # Main application code
├── .build/                      # Build artifacts (auto-generated)
└── .vscode/                     # VS Code configuration
```

## Core Components

### Scanner Class
- **Purpose**: Main BLE scanning implementation
- **Responsibilities**:
  - CoreBluetooth central manager delegate
  - Device discovery and advertisement data parsing
  - Signal quality analysis and distance estimation
  - Manufacturer-specific data interpretation

### Manufacturer Data Parsing
The tool includes specialized parsers for:
- **Apple**: iBeacon, AirPods, Handoff/Continuity, Nearby/AirDrop
- **Microsoft**: CDP (Cross Device Protocol), Surface devices
- **Samsung**: Device-specific data structures
- **Nordic Semiconductor**: Development/test devices
- **Govee**: Smart home devices (LED strips, sensors)
- **Generic**: Unknown manufacturers with pattern detection

### Signal Analysis
- RSSI-based signal quality assessment (Excellent to Barely Detectable)
- Distance estimation based on signal strength
- TX Power level reporting when available

## Development Guidelines

### Adding New Manufacturer Support
1. Add company identifier to the `companies` dictionary in `getManufacturerName()`
2. Add case to the switch statement in `parseManufacturerSpecificData()`
3. Implement dedicated parsing function following pattern: `parse{Company}ManufacturerData()`
4. Include detailed comments about data structure interpretation

### Data Analysis Patterns
- Use hexdump for raw data visualization
- Implement structured parsing with field-by-field analysis
- Provide meaningful interpretations of numeric values
- Include ASCII representation when applicable
- Add context about device capabilities and expected behavior

### Testing Considerations
- Test with real BLE devices when possible
- Verify manufacturer data parsing accuracy
- Test signal strength calculations across different distances
- Validate edge cases (empty data, incomplete packets)

## Build & Run Instructions

### Development
```bash
swift build
swift run
```

### Release Build
```bash
swift build -c release
```

### Dependencies Update
```bash
swift package update
```

## CLI Usage
The tool starts scanning immediately and displays detailed information about discovered BLE devices. Use Ctrl+C to stop scanning gracefully.

## Data Structure Notes

### Advertisement Data Keys
- `CBAdvertisementDataLocalNameKey`: Device local name
- `CBAdvertisementDataManufacturerDataKey`: Manufacturer-specific data
- `CBAdvertisementDataServiceUUIDsKey`: Advertised service UUIDs
- `CBAdvertisementDataServiceDataKey`: Service-specific data
- `CBAdvertisementDataTxPowerLevelKey`: Transmission power level
- `CBAdvertisementDataIsConnectable`: Connection capability
- `CBAdvertisementDataSolicitedServiceUUIIDsKey`: Requested services
- `CBAdvertisementDataOverflowServiceUUIDsKey`: Additional services

### Common Manufacturer Data Formats
- **Company ID**: First 2 bytes (little-endian)
- **Apple iBeacon**: 23 bytes total (UUID + Major + Minor + TX Power)
- **Govee Devices**: Status/config data with device type identification
- **Nordic**: Development device type and version information

## Future Enhancement Ideas
- Add support for connecting to discovered devices
- Implement service and characteristic exploration
- Add filtering options (by manufacturer, signal strength, etc.)
- Create output formats (JSON, CSV) for data analysis
- Add device tracking and change detection over time
- Implement manufacturer data decoding for additional companies

## Troubleshooting
- Ensure Bluetooth is enabled and powered on
- Check macOS privacy settings for Bluetooth access
- Verify device is in advertising mode for testing
- Some devices may use randomized MAC addresses
- Signal strength varies with environment and obstacles

## Pre-commit Checklist

Before presenting commits to the user, verify:

- [ ] Code compiles without errors or warnings
- [ ] All new functionality is properly documented
- [ ] Code follows Swift style guidelines
- [ ] Changes are logical and complete
- [ ] Commit message follows conventional format
- [ ] Appropriate scope is used
- [ ] Manufacturer data parsing follows established patterns (if applicable)
- [ ] Signal analysis calculations are accurate (if applicable)
- [ ] Privacy and security considerations are maintained
- [ ] Performance impact is acceptable

## Security & Privacy

- Respect user privacy and data
- Follow Microsoft content policies
- Avoid copyrighted content
- Consider security implications of all changes
- Never expose sensitive information in logs or commits

---

## Recent Updates & Decisions

### October 3, 2025

- **Initial creation**: Established master agent instructions file
- **Reasoning**: Centralize cross-project agent behavior and commit workflow; separate from project-specific technical details in `.github/copilot-instructions.md`
- **Key decision**: Explicit user confirmation required for all git commits (NEVER auto-commit)

### October 3, 2025

- **Consolidated instructions**: Moved all content from `.github/copilot-instructions.md` to AGENTS.md
- **Reasoning**: Single source of truth for all agent instructions - simpler maintenance and clearer structure
- **Change**: `.github/copilot-instructions.md` now contains only a reference to AGENTS.md
