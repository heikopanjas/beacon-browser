# BLEScanner

A powerful Swift command-line tool for scanning and analyzing Bluetooth Low Energy (BLE) devices on macOS. Discover nearby devices, decode manufacturer-specific data, and analyze signal characteristics with detailed real-time output.

## Features

- **Real-time BLE Device Discovery** - Continuously scan and display nearby BLE devices
- **Signal Analysis** - RSSI-based signal quality assessment and distance estimation
- **Manufacturer Data Parsing** - Specialized decoders for major device manufacturers
- **Device Information** - Display names, UUIDs, services, and connectivity status
- **Detailed Output** - Hexdump visualization and structured data interpretation
- **High Performance** - Built with Swift 6.1+ and optimized CoreBluetooth implementation

## Supported Manufacturers

BLEScanner includes specialized parsers for:

- **Apple** - iBeacon, AirPods, Handoff/Continuity, Nearby/AirDrop protocols
- **Microsoft** - Cross Device Protocol (CDP), Surface devices
- **Samsung** - Galaxy devices and accessories
- **Govee** - Smart home devices (LED strips, sensors, thermometers)
- **Nordic Semiconductor** - Development boards and reference designs
- **Xiaomi** - Mi Band, smart home devices
- **Garmin** - Fitness trackers and smartwatches
- **Sony** - Audio devices and accessories
- **Google/Nest** - Smart home ecosystem devices
- **Amazon** - Echo devices and Alexa accessories

And many more, with automatic detection for unknown manufacturers.

## Requirements

- **macOS** 10.15+ (Catalina or later)
- **Swift** 6.1+
- **Bluetooth LE** compatible hardware
- **Privacy permissions** for Bluetooth access

## Installation

### Using Swift Package Manager

1. Clone the repository:

```bash
git clone https://github.com/yourusername/BLEScanner.git
cd BLEScanner
```

2. Build the project:

```bash
swift build -c release
```

3. Run the scanner:

```bash
swift run
```

### Development Build

For development and debugging:

```bash
swift build
swift run
```

## Usage

Simply run the tool to start scanning:

```bash
./BLEScanner
```

The scanner will immediately begin discovering BLE devices and display detailed information including:

- Device identifiers and names
- Signal strength (RSSI) and estimated distance
- Manufacturer-specific data with decoded information
- Advertised services and characteristics
- Connection capabilities

### Sample Output

```text
Device: iPhone (John's iPhone)
   └─ Address: 12:34:56:78:9A:BC
   └─ RSSI: -45 dBm (Excellent signal, ~1.0m)
   └─ Manufacturer: Apple, Inc. (0x004C)
   └─ Data: Handoff/Continuity - Activity: 0x01, Status: 0x00
   └─ Services: [180F] Battery Service
   └─ Connectable: Yes

Device: AirPods Pro
   └─ Address: AA:BB:CC:DD:EE:FF
   └─ RSSI: -52 dBm (Good signal, ~1.5m)
   └─ Manufacturer: Apple, Inc. (0x004C)
   └─ Data: AirPods Pro - Battery L:85% R:82% Case:95%
   └─ TX Power: 12 dBm
   └─ Connectable: Yes
```

### Controls

- **Ctrl+C** - Stop scanning gracefully
- **Cmd+C** - Force quit (if needed)

## Signal Quality Indicators

| RSSI Range | Quality | Estimated Distance |
|------------|---------|-------------------|
| > -30 dBm | Excellent | < 1m |
| -30 to -67 dBm | Good | 1-10m |
| -67 to -70 dBm | Fair | 10-15m |
| -70 to -80 dBm | Weak | 15-25m |
| < -80 dBm | Barely Detectable | > 25m |

*Note: Distance estimates are approximate and vary based on environmental factors*

## Architecture

### Core Components

- **Scanner Class** - CoreBluetooth central manager implementation
- **Manufacturer Data Parsers** - Specialized decoders for device-specific protocols
- **Signal Analysis** - RSSI processing and distance estimation
- **Data Visualization** - Hexdump and structured output formatting

### Project Structure

```text
BLEScanner/
├── Package.swift              # Swift Package Manager configuration
├── Sources/
│   └── BLEScanner.swift      # Main application code
├── README.md                 # This file
├── .copilot-instructions.md  # Development guidelines
└── .gitignore               # Git ignore patterns
```

## Development

### Building from Source

1. Ensure you have Xcode Command Line Tools installed:

```bash
xcode-select --install
```

2. Clone and build:

```bash
git clone <repository-url>
cd BLEScanner
swift build
```

### Adding New Manufacturer Support

1. Add company identifier to the `companies` dictionary
2. Implement parsing function following the pattern: `parse{Company}ManufacturerData()`
3. Add case to the manufacturer data switch statement
4. Include comprehensive comments about data structure

See `.copilot-instructions.md` for detailed development guidelines.

### Dependencies

- [Swift Argument Parser](https://github.com/apple/swift-argument-parser) - Command-line interface framework

## Privacy & Security

- **Passive Scanning Only** - No device connections are established
- **Local Processing** - All data analysis happens on your device
- **No Data Collection** - No information is transmitted or stored remotely
- **Privacy Compliant** - Respects BLE privacy features and MAC randomization

## Troubleshooting

### Common Issues

#### Bluetooth Permission Denied

- Go to System Preferences → Security & Privacy → Privacy → Bluetooth
- Ensure Terminal (or your terminal app) has permission

#### No Devices Found

- Verify Bluetooth is enabled and powered on
- Check that target devices are in advertising mode
- Some devices use MAC address randomization

#### Build Errors

- Ensure Xcode Command Line Tools are installed
- Update to latest Swift toolchain if needed
- Check macOS version compatibility

### Debug Mode

For additional debugging information, you can modify the source to enable verbose logging or add custom filters.

## Contributing

Contributions are welcome! Please see the development guidelines in `.copilot-instructions.md` for:

- Code style requirements
- Commit message conventions
- Testing procedures
- Adding new manufacturer support

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Apple's CoreBluetooth framework for BLE functionality
- Swift Argument Parser for CLI interface
- The BLE community for manufacturer data format documentation

## Changelog

### v1.0.0 (Initial Release)

- Real-time BLE device scanning
- Manufacturer data parsing for major brands
- Signal strength analysis and distance estimation
- Comprehensive device information display
- Cross-platform Swift implementation

---

**Note**: This tool is for educational and development purposes. Always respect device privacy and local regulations when scanning for BLE devices.
