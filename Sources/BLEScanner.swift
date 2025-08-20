// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import CoreBluetooth
import Foundation

class Scanner: NSObject, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager!

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }

    // Company Identifier lookup (first 2 bytes of manufacturer data)
    private func getManufacturerName(from data: Data) -> String? {
        guard data.count >= 2 else { return nil }

        // Company identifier is little-endian in the first 2 bytes
        let companyId = UInt16(data[0]) | (UInt16(data[1]) << 8)

        // Common company identifiers (partial list)
        let companies: [UInt16: String] = [
            0x004C: "Apple, Inc.",
            0x0006: "Microsoft",
            0x00E0: "Google",
            0x00D8: "Garmin International",
            0x008B: "Fitbit, Inc.",
            0x0005: "Broadcom Corporation",
            0x000F: "Broadcom Corporation",
            0x0059: "Nordic Semiconductor ASA",
            0x0087: "Garmin International",
            0x0075: "Samsung Electronics Co. Ltd.",
            0x0118: "Xiaomi Inc.",
            0x02E5: "Linxens",
            0x0171: "NXP Semiconductors",
            0x0224: "Amazon.com Services LLC",
            0x01D7: "Sony Corporation",
            0x006F: "Sony Corporation",
            0x008C: "Qualcomm",
            0x00BF: "Qualcomm Connected Experiences, Inc.",
            0x0131: "Nest Labs Inc.",
            0x0157: "Tesla Motors",
            0x004F: "TomTom International BV",
            0x0001: "Ericsson Technology Licensing",
            0x0002: "Nokia Mobile Phones",
            0x0003: "Intel Corp.",
            0x0004: "IBM Corp.",
            0x0007: "Lucent",
            0x0008: "Motorola",
            0x000A: "Qualcomm",
            0x000D: "Texas Instruments Inc.",
            0x0010: "Symbol Technologies, Inc.",
            0x0013: "Toshiba Corp.",
            0x0015: "Rohde & Schwarz GmbH & Co. KG",
            0x001D: "Qualcomm",
            0x001F: "AVM Berlin",
            0x0025: "NEC Corporation",
            0x0030: "ST Microelectronics",
            0x003A: "Medtronic, Inc.",
            0x0046: "Mitel Semiconductor",
            0x0047: "Cisco Systems, Inc.",
            0x0702: "SAF Tehnika JSC (Aranet)",
            0x0009: "Hewlett-Packard Company",
            0x0065: "HP Inc.",
            0x037A: "Elgato Systems GmbH",
            0x03C1: "Ember Technologies, Inc.",
            0x3601: "Shenzhen Minew Technologies Co., Ltd.",
            0x8802: "Govee Life Inc.",
            0x8803: "Govee Life Inc."
        ]

        return companies[companyId]
    }

    private func parseManufacturerSpecificData(_ data: Data) {
        guard data.count >= 2 else { return }

        let companyId = UInt16(data[0]) | (UInt16(data[1]) << 8)
        let payload = data.dropFirst(2)

        switch companyId {
            case 0x004C:  // Apple
                parseAppleManufacturerData(payload)
            case 0x0006:  // Microsoft
                parseMicrosoftManufacturerData(payload)
            case 0x0075:  // Samsung
                parseSamsungManufacturerData(payload)
            case 0x0059:  // Nordic Semiconductor
                parseNordicManufacturerData(payload)
            case 0x8803:  // Govee
                parseGoveeManufacturerData(payload)
            default:
                parseGenericManufacturerData(payload, companyId: companyId)
        }
    }

    private func parseAppleManufacturerData(_ data: Data) {
        guard !data.isEmpty else { return }

        let type = data[0]
        print("  Apple Data Type: 0x\(String(format: "%02x", type))")

        switch type {
            case 0x02:  // iBeacon
                if data.count >= 23 {  // iBeacon needs 23 bytes: 1 + 1 + 16 + 2 + 2 + 1
                    let uuid = data[2 ..< 18]  // UUID is 16 bytes starting at offset 2
                    let major = UInt16(data[18]) << 8 | UInt16(data[19])
                    let minor = UInt16(data[20]) << 8 | UInt16(data[21])
                    let txPower = Int8(bitPattern: data[22])

                    print("  iBeacon UUID: \(uuid.map { String(format: "%02x", $0) }.joined())")
                    print("  iBeacon Major: \(major)")
                    print("  iBeacon Minor: \(minor)")
                    print("  iBeacon TX Power: \(txPower) dBm")
                }
                else {
                    print("  Incomplete iBeacon data (\(data.count) bytes, need 23)")
                }
            case 0x10:  // Nearby
                print("  Apple Nearby/AirDrop data")
            case 0x12:  // Handoff
                print("  Apple Handoff/Continuity data")
            case 0x07:  // AirPods
                print("  Apple AirPods data")
                if data.count > 1 {
                    let subtype = data[1]
                    print("  AirPods Subtype: 0x\(String(format: "%02x", subtype))")
                }
            default:
                print("  Unknown Apple data type")
        }
    }

    private func parseMicrosoftManufacturerData(_ data: Data) {
        guard !data.isEmpty else { return }

        let scenario = data[0]
        print("  Microsoft Scenario: 0x\(String(format: "%02x", scenario))")

        switch scenario {
            case 0x01:  // Microsoft CDP (Cross Device Protocol)
                print("  Microsoft CDP (Cross Device Protocol)")
            case 0x03:  // Microsoft Surface
                print("  Microsoft Surface device")
            default:
                print("  Unknown Microsoft scenario")
        }
    }

    private func parseSamsungManufacturerData(_ data: Data) {
        print("  Samsung-specific data")
        if !data.isEmpty {
            let type = data[0]
            print("  Samsung Data Type: 0x\(String(format: "%02x", type))")
        }
    }

    private func parseNordicManufacturerData(_ data: Data) {
        print("  Nordic Semiconductor data (likely development/test device)")
        if data.count >= 2 {
            let deviceType = data[0]
            let version = data[1]
            print("  Device Type: 0x\(String(format: "%02x", deviceType))")
            print("  Version: 0x\(String(format: "%02x", version))")
        }
    }

    private func parseGoveeManufacturerData(_ data: Data) {
        print("  Govee smart device data")

        guard data.count >= 5 else {
            print("  Incomplete Govee data (\(data.count) bytes)")
            return
        }

        // Govee data structure analysis based on: 03 88 ec 00 0a 02 00
        // After company ID (03 88), we have: ec 00 0a 02 00

        let byte0 = data[0]  // 0xec
        let byte1 = data[1]  // 0x00
        let byte2 = data[2]  // 0x0a
        let byte3 = data[3]  // 0x02
        let byte4 = data[4]  // 0x00

        print("  Device Type/Model: 0x\(String(format: "%02x", byte0))")

        // Byte 0 (0xec) appears to be device type identifier
        switch byte0 {
            case 0xec:
                print("  Device Category: LED Strip Light (H6125 series)")
            default:
                print("  Device Category: Unknown Govee device type")
        }

        // Byte 1-2 might be status or configuration
        let statusWord = UInt16(byte1) | (UInt16(byte2) << 8)
        print("  Status/Config: 0x\(String(format: "%04x", statusWord))")

        // Byte 2 (0x0a = 10) might be brightness or power level
        if byte2 > 0 {
            let percentage = (Int(byte2) * 100) / 255
            print("  Possible Brightness/Power: \(byte2) (\(percentage)%)")
        }

        // Byte 3 (0x02) might be mode or state
        print("  Mode/State: 0x\(String(format: "%02x", byte3))")
        switch byte3 {
            case 0x01:
                print("  Status: Possibly OFF")
            case 0x02:
                print("  Status: Possibly ON/Active")
            case 0x03:
                print("  Status: Possibly in Scene/Effect mode")
            default:
                print("  Status: Unknown state")
        }

        // Byte 4 (0x00) might be additional flags or reserved
        if byte4 != 0 {
            print("  Additional Flags: 0x\(String(format: "%02x", byte4))")
        }

        // Check if device name matches pattern
        print("  Device appears to be: Govee H6125 Smart LED Strip")
        print("  Capabilities: RGB color changing, app control, possibly music sync")
    }

    private func parseGenericManufacturerData(_ data: Data, companyId: UInt16) {
        print("  Company ID: 0x\(String(format: "%04x", companyId))")

        if !data.isEmpty {
            print("  Payload (\(data.count) bytes): \(data.map { String(format: "%02x", $0) }.joined(separator: " "))")

            // Check for common patterns
            if data.count >= 16 && data.count <= 25 {
                print("  Possible iBeacon-like format detected")
            }

            // Check for string data
            let printableBytes = data.filter { $0 >= 32 && $0 <= 126 }
            if printableBytes.count > data.count / 2 {
                let possibleString = String(data: Data(printableBytes), encoding: .ascii) ?? ""
                if !possibleString.isEmpty {
                    print("  Possible text content: \"\(possibleString)\"")
                }
            }
        }
    }

    private func hexdump(_ data: Data) -> String {
        var result = ""
        let bytesPerLine = 16

        for lineStart in stride(from: 0, to: data.count, by: bytesPerLine) {
            let lineEnd = min(lineStart + bytesPerLine, data.count)
            let lineData = data[lineStart ..< lineEnd]

            // Offset
            result += String(format: "%08x  ", lineStart)

            // Hex bytes
            var hexPart = ""
            for (index, byte) in lineData.enumerated() {
                hexPart += String(format: "%02x ", byte)
                // Add extra space after 8 bytes for readability
                if index == 7 {
                    hexPart += " "
                }
            }

            // Pad hex part to fixed width
            let hexWidth = 50  // 16 bytes * 3 chars + 1 extra space
            hexPart = hexPart.padding(toLength: hexWidth, withPad: " ", startingAt: 0)
            result += hexPart + "|"

            // ASCII representation
            for byte in lineData {
                if byte >= 32 && byte <= 126 {
                    result += String(Character(UnicodeScalar(byte)))
                }
                else {
                    result += "."
                }
            }
            result += "|\n"
        }

        return result
    }

    private func getSignalQuality(rssi: Int) -> (quality: String, distance: String) {
        switch rssi {
            case -30 ... (-1):
                return ("Excellent", "0-2m")
            case -50 ... (-31):
                return ("Very Good", "2-5m")
            case -60 ... (-51):
                return ("Good", "5-10m")
            case -70 ... (-61):
                return ("Fair", "10-15m")
            case -80 ... (-71):
                return ("Poor", "15-25m")
            case -90 ... (-81):
                return ("Very Poor", "25-35m")
            default:
                return ("Barely Detectable", "35m+")
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is powered on. Starting scan...")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
        else {
            print("Bluetooth state is \(central.state.rawValue)")
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let name = peripheral.name ?? "Unknown"
        let identifier = peripheral.identifier.uuidString

        print("\n--- Discovered Device ---")
        print("Name: \(name)")
        print("Identifier: \(identifier)")
        print("RSSI: \(RSSI) dBm")

        // Signal quality and estimated distance
        let (quality, distance) = getSignalQuality(rssi: RSSI.intValue)
        print("Signal Quality: \(quality), Estimated Distance: \(distance)")

        // Extract common advertisement data
        if let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            print("Local Name: \(localName)")
        }

        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            print("Manufacturer Data (\(manufacturerData.count) bytes):")
            print(hexdump(manufacturerData))

            // Decode and print manufacturer name
            let manufacturerName = getManufacturerName(from: manufacturerData) ?? "<Unknown>"
            print("Manufacturer: \(manufacturerName)")
        }

        if let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            print("Service UUIDs: \(serviceUUIDs.map { $0.uuidString }.joined(separator: ", "))")
        }

        if let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data] {
            for (uuid, data) in serviceData {
                print("Service Data (\(uuid.uuidString)): \(data.map { String(format: "%02x", $0) }.joined(separator: " "))")
            }
        }

        if let txPower = advertisementData[CBAdvertisementDataTxPowerLevelKey] as? NSNumber {
            print("TX Power Level: \(txPower) dBm")
        }

        if let isConnectable = advertisementData[CBAdvertisementDataIsConnectable] as? NSNumber {
            print("Is Connectable: \(isConnectable.boolValue ? "Yes" : "No")")
        }

        if let solicitedServices = advertisementData[CBAdvertisementDataSolicitedServiceUUIDsKey] as? [CBUUID] {
            print("Solicited Service UUIDs: \(solicitedServices.map { $0.uuidString }.joined(separator: ", "))")
        }

        if let overflowServices = advertisementData[CBAdvertisementDataOverflowServiceUUIDsKey] as? [CBUUID] {
            print("Overflow Service UUIDs: \(overflowServices.map { $0.uuidString }.joined(separator: ", "))")
        }

        // Show any other keys that might be present
        let knownKeys = Set([
            CBAdvertisementDataLocalNameKey,
            CBAdvertisementDataManufacturerDataKey,
            CBAdvertisementDataServiceUUIDsKey,
            CBAdvertisementDataServiceDataKey,
            CBAdvertisementDataTxPowerLevelKey,
            CBAdvertisementDataIsConnectable,
            CBAdvertisementDataSolicitedServiceUUIDsKey,
            CBAdvertisementDataOverflowServiceUUIDsKey
        ])

        let otherKeys = Set(advertisementData.keys).subtracting(knownKeys)
        if !otherKeys.isEmpty {
            print("Other Advertisement Data:")
            for key in otherKeys.sorted() {
                print("  \(key): \(advertisementData[key] ?? "nil")")
            }
        }

        print("------------------------")
    }

    func stop() {
        print("\nStopping scan.")
        centralManager.stopScan()
        exit(0)
    }
}

@main
struct BLEScanner: ParsableCommand {
    mutating func run() throws {
        let scanner = Scanner()

        // Set up SIGINT (Ctrl+C) handling using DispatchSource
        let signalSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
        signalSource.setEventHandler {
            scanner.stop()
        }
        signalSource.resume()

        // Ignore the default SIGINT behavior
        signal(SIGINT, SIG_IGN)

        RunLoop.main.run()
    }
}
