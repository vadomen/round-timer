import Foundation
import CoreBluetooth
import Combine

class HeartRateManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var heartRate: Int = 0
    @Published var connectionState: ConnectionState = .disconnected
    
    enum ConnectionState {
        case disconnected
        case scanning
        case connecting
        case connected
    }
    
    private var centralManager: CBCentralManager!
    private var hrPeripheral: CBPeripheral?
    
    // Heart Rate Service and Characteristic UUIDs
    private let hrServiceUUID = CBUUID(string: "180D")
    private let hrMeasurementCharacteristicUUID = CBUUID(string: "2A37")
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: [hrServiceUUID], options: nil)
        connectionState = .scanning
    }
    
    func stopScanning() {
        centralManager.stopScan()
        if connectionState == .scanning {
            connectionState = .disconnected
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            connectionState = .disconnected
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        hrPeripheral = peripheral
        hrPeripheral?.delegate = self
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
        connectionState = .connecting
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionState = .connected
        peripheral.discoverServices([hrServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectionState = .disconnected
        heartRate = 0
        startScanning() // Re-scan on disconnect
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([hrMeasurementCharacteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == hrMeasurementCharacteristicUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic.uuid == hrMeasurementCharacteristicUUID,
              let data = characteristic.value else { return }
        
        let heartRateValue = decodeHeartRate(from: data)
        DispatchQueue.main.async {
            self.heartRate = heartRateValue
        }
    }
    
    private func decodeHeartRate(from data: Data) -> Int {
        var buffer = [UInt8](repeating: 0, count: data.count)
        data.copyBytes(to: &buffer, count: data.count)
        
        var offset = 0
        let flags = buffer[offset]
        offset += 1
        
        let isUInt16 = (flags & 0x01) != 0
        
        var bpm: Int = 0
        if isUInt16 {
            bpm = Int(buffer[offset]) | (Int(buffer[offset + 1]) << 8)
        } else {
            bpm = Int(buffer[offset])
        }
        
        return bpm
    }
}
