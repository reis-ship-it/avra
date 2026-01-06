import Flutter
import FirebaseCore
import UIKit
import GoogleMaps
import CoreBluetooth
import CoreML

final class SpotsBleInbox {
  struct InboxMessage {
    let senderId: String
    let data: Data
    let receivedAtMs: Int64
  }

  private struct PartialKey: Hashable {
    let senderId: String
    let msgId: UInt32
  }

  private struct PartialMessage {
    let senderId: String
    let msgId: UInt32
    let totalLen: Int
    var nextOffset: Int
    var buffer: Data
    var lastUpdatedMs: Int64
  }

  static let shared = SpotsBleInbox()

  private var queue: [InboxMessage] = []
  private var partial: [PartialKey: PartialMessage] = [:]
  private var seenMsgIds: [String: Int64] = [:] // senderId:msgId -> expiresAtMs
  private let defaults = UserDefaults.standard
  private let defaultsKey = "spots_ble_inbox_v1"

  private init() {
    load()
  }

  @discardableResult
  func addFrame(senderId: String, msgId: UInt32, totalLen: Int, offset: Int, chunk: Data) -> Bool {
    cleanupPartials()
    let key = PartialKey(senderId: senderId, msgId: msgId)
    var pm = partial[key] ?? PartialMessage(
      senderId: senderId,
      msgId: msgId,
      totalLen: totalLen,
      nextOffset: 0,
      buffer: Data(count: totalLen),
      lastUpdatedMs: Int64(Date().timeIntervalSince1970 * 1000)
    )

    guard pm.totalLen == totalLen else {
      // Reset if sizes mismatch
      pm = PartialMessage(
        senderId: senderId,
        msgId: msgId,
        totalLen: totalLen,
        nextOffset: 0,
        buffer: Data(count: totalLen),
        lastUpdatedMs: Int64(Date().timeIntervalSince1970 * 1000)
      )
      partial[key] = pm
      return false
    }

    guard offset == pm.nextOffset else {
      // Require sequential writes for MVP simplicity.
      partial[key] = pm
      return false
    }

    let end = min(offset + chunk.count, totalLen)
    let toCopy = end - offset
    if toCopy > 0 {
      pm.buffer.replaceSubrange(offset..<end, with: chunk.prefix(toCopy))
      pm.nextOffset = end
      pm.lastUpdatedMs = Int64(Date().timeIntervalSince1970 * 1000)
    }

    if pm.nextOffset >= totalLen {
      let nowMs = Int64(Date().timeIntervalSince1970 * 1000)
      cleanupSeen(nowMs: nowMs)
      let seenKey = "\(senderId):\(msgId)"
      let isDup = (seenMsgIds[seenKey] ?? 0) > nowMs
      seenMsgIds[seenKey] = nowMs + 10 * 60 * 1000
      if !isDup {
        queue.append(InboxMessage(senderId: senderId, data: pm.buffer, receivedAtMs: nowMs))
      }
      partial.removeValue(forKey: key)
      persist()
      return true
    } else {
      partial[key] = pm
      return false
    }
  }

  func drain(max: Int = 50) -> [InboxMessage] {
    if queue.isEmpty { return [] }
    let count = min(max, queue.count)
    let out = Array(queue.prefix(count))
    queue.removeFirst(count)
    if !out.isEmpty { persist() }
    return out
  }

  func clear() {
    queue.removeAll()
    partial.removeAll()
    defaults.removeObject(forKey: defaultsKey)
  }

  private func cleanupPartials() {
    let nowMs = Int64(Date().timeIntervalSince1970 * 1000)
    partial = partial.filter { (_, pm) in
      (nowMs - pm.lastUpdatedMs) < 60_000
    }
  }

  private func cleanupSeen(nowMs: Int64) {
    seenMsgIds = seenMsgIds.filter { (_, exp) in exp > nowMs }
  }

  private func load() {
    guard let arr = defaults.array(forKey: defaultsKey) as? [[String: Any]] else { return }
    var loaded: [InboxMessage] = []
    for item in arr {
      guard
        let senderId = item["senderId"] as? String,
        let receivedAtMs = item["receivedAtMs"] as? Int64,
        let dataB64 = item["dataB64"] as? String,
        let data = Data(base64Encoded: dataB64)
      else { continue }
      loaded.append(InboxMessage(senderId: senderId, data: data, receivedAtMs: receivedAtMs))
    }
    self.queue = loaded
  }

  private func persist() {
    // Cap persisted messages.
    let capped = queue.suffix(25)
    let arr: [[String: Any]] = capped.map { msg in
      [
        "senderId": msg.senderId,
        "receivedAtMs": msg.receivedAtMs,
        "dataB64": msg.data.base64EncodedString(),
      ]
    }
    defaults.set(arr, forKey: defaultsKey)
  }
}

final class SpotsBleAckStore {
  struct Ack {
    let senderId: String
    let msgId: UInt32
    let ackedAtMs: Int64
  }

  static let shared = SpotsBleAckStore()

  private let defaults = UserDefaults.standard
  private let defaultsKey = "spots_ble_ack_v1"
  private var acks: [Ack] = []

  private init() {
    load()
  }

  func addAck(senderId: String, msgId: UInt32) {
    let nowMs = Int64(Date().timeIntervalSince1970 * 1000)
    acks.append(Ack(senderId: senderId, msgId: msgId, ackedAtMs: nowMs))
    if acks.count > 50 {
      acks.removeFirst(acks.count - 50)
    }
    persist()
  }

  func snapshotPayload() -> Data {
    let arr: [[String: Any]] = acks.map { ack in
      [
        "sender_id": ack.senderId,
        "msg_id": Int(ack.msgId),
        "acked_at_ms": ack.ackedAtMs,
      ]
    }
    let root: [String: Any] = [
      "v": 1,
      "acks": arr,
    ]
    return (try? JSONSerialization.data(withJSONObject: root, options: [])) ?? Data()
  }

  private func load() {
    guard let arr = defaults.array(forKey: defaultsKey) as? [[String: Any]] else { return }
    var loaded: [Ack] = []
    for item in arr {
      guard
        let senderId = item["sender_id"] as? String,
        let msgId = item["msg_id"] as? Int,
        let ackedAtMs = item["acked_at_ms"] as? Int64
      else { continue }
      loaded.append(Ack(senderId: senderId, msgId: UInt32(msgId), ackedAtMs: ackedAtMs))
    }
    self.acks = loaded
  }

  private func persist() {
    let arr: [[String: Any]] = acks.map { ack in
      [
        "sender_id": ack.senderId,
        "msg_id": Int(ack.msgId),
        "acked_at_ms": ack.ackedAtMs,
      ]
    }
    defaults.set(arr, forKey: defaultsKey)
  }
}

final class SpotsBlePeripheral: NSObject, CBPeripheralManagerDelegate {
  private let serviceUuid = CBUUID(string: "0000FF00-0000-1000-8000-00805F9B34FB")
  private let readCharacteristicUuid = CBUUID(string: "0000FF01-0000-1000-8000-00805F9B34FB")
  private let writeCharacteristicUuid = CBUUID(string: "0000FF02-0000-1000-8000-00805F9B34FB")

  private var peripheralManager: CBPeripheralManager?
  private var readCharacteristic: CBMutableCharacteristic?
  private var writeCharacteristic: CBMutableCharacteristic?

  private var isAdvertisingRequested: Bool = false
  private var vibePayload: Data = Data()
  private var preKeyPayload: Data = Data()
  private var serviceDataFrameV1: Data = Data()
  private var readStateByCentral: [UUID: (streamId: UInt8, offset: Int)] = [:]

  private let magic: [UInt8] = [0x53, 0x50, 0x54, 0x53] // "SPTS"
  private let version: UInt8 = 1
  private let maxChunkData: Int = 180

  private let msgMagic: [UInt8] = [0x53, 0x50, 0x54, 0x4D] // "SPTM"
  private let msgVersionV1: UInt8 = 1
  private let msgVersionV2: UInt8 = 2
  private let msgSenderIdLen: Int = 36
  private let msgHeaderLenV1: Int = 20
  private var msgHeaderLenV2: Int { 20 + msgSenderIdLen }

  func start(payload: Data) {
    self.vibePayload = payload
    isAdvertisingRequested = true

    if peripheralManager == nil {
      peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [
        CBPeripheralManagerOptionRestoreIdentifierKey: "spots_ble_peripheral",
      ])
      return
    }

    startIfReady()
  }

  func stop() {
    isAdvertisingRequested = false
    peripheralManager?.stopAdvertising()
    peripheralManager?.removeAllServices()
    readCharacteristic = nil
    writeCharacteristic = nil
    readStateByCentral.removeAll()
  }

  func updatePayload(_ payload: Data) {
    self.vibePayload = payload
  }

  func updatePreKeyPayload(_ payload: Data) {
    self.preKeyPayload = payload
  }

  func updateServiceDataFrameV1(_ frame: Data) {
    self.serviceDataFrameV1 = frame
    // Service Data changes require restarting advertising to take effect.
    if isAdvertisingRequested {
      peripheralManager?.stopAdvertising()
      startIfReady()
    }
  }

  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    startIfReady()
  }

  func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
    guard request.characteristic.uuid == readCharacteristicUuid else {
      peripheral.respond(to: request, withResult: .attributeNotFound)
      return
    }

    let state = readStateByCentral[request.central.identifier]
    let streamId = state?.streamId ?? 0
    let requestedOffset = state?.offset ?? request.offset

    let payload: Data
    switch streamId {
    case 0:
      payload = vibePayload
    case 1:
      payload = preKeyPayload
    case 2:
      payload = SpotsBleAckStore.shared.snapshotPayload()
    default:
      payload = Data()
    }

    let totalLen = payload.count
    let safeOffset = max(0, min(requestedOffset, totalLen))
    let remaining = totalLen - safeOffset
    let chunkLen = min(remaining, maxChunkData)

    // Read frame header (16 bytes, LE):
    // magic(4) + version(1) + streamId(1) + totalLen(u32) + offset(u32) + chunkLen(u16)
    var frame = Data()
    frame.append(contentsOf: magic)
    frame.append(version)
    frame.append(streamId)

    func appendU32LE(_ v: Int) {
      let u = UInt32(v)
      frame.append(UInt8(u & 0xFF))
      frame.append(UInt8((u >> 8) & 0xFF))
      frame.append(UInt8((u >> 16) & 0xFF))
      frame.append(UInt8((u >> 24) & 0xFF))
    }
    func appendU16LE(_ v: Int) {
      let u = UInt16(v)
      frame.append(UInt8(u & 0xFF))
      frame.append(UInt8((u >> 8) & 0xFF))
    }

    appendU32LE(totalLen)
    appendU32LE(safeOffset)
    appendU16LE(chunkLen)

    if chunkLen > 0 {
      frame.append(payload.subdata(in: safeOffset..<(safeOffset + chunkLen)))
    }

    request.value = frame
    peripheral.respond(to: request, withResult: .success)
  }

  func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
    for request in requests {
      if request.characteristic.uuid == writeCharacteristicUuid {
        if let value = request.value {
          let bytes = [UInt8](value)

          // Control frame (10 bytes): "SPTS" + version + streamId + offset(u32 LE)
          if bytes.count >= 10,
             bytes[0] == magic[0],
             bytes[1] == magic[1],
             bytes[2] == magic[2],
             bytes[3] == magic[3],
             bytes[4] == version {
            let streamId = bytes[5]
            let offset = Int(UInt32(bytes[6])
                             | (UInt32(bytes[7]) << 8)
                             | (UInt32(bytes[8]) << 16)
                             | (UInt32(bytes[9]) << 24))
            readStateByCentral[request.central.identifier] = (streamId: streamId, offset: offset)
          }

          // Message frame (20 bytes header): "SPTM" + version + reserved + msgId + totalLen + offset + chunkLen
          if bytes.count >= msgHeaderLenV1,
             bytes[0] == msgMagic[0],
             bytes[1] == msgMagic[1],
             bytes[2] == msgMagic[2],
             bytes[3] == msgMagic[3],
             (bytes[4] == msgVersionV1 || bytes[4] == msgVersionV2) {
            func u32LE(_ i: Int) -> UInt32 {
              return UInt32(bytes[i])
                | (UInt32(bytes[i + 1]) << 8)
                | (UInt32(bytes[i + 2]) << 16)
                | (UInt32(bytes[i + 3]) << 24)
            }
            func u16LE(_ i: Int) -> UInt16 {
              return UInt16(bytes[i]) | (UInt16(bytes[i + 1]) << 8)
            }

            let msgId = u32LE(6)
            let totalLen = Int(u32LE(10))
            let offset = Int(u32LE(14))
            let chunkLen = Int(u16LE(18))

            let version = bytes[4]
            let headerLen = (version == msgVersionV2) ? msgHeaderLenV2 : msgHeaderLenV1
            let senderId: String
            if version == msgVersionV2, bytes.count >= headerLen {
              let idData = value.subdata(in: msgHeaderLenV1..<headerLen)
              senderId = String(data: idData, encoding: .ascii)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            } else {
              senderId = request.central.identifier.uuidString
            }

            if totalLen > 0,
               chunkLen >= 0,
               bytes.count >= headerLen + chunkLen {
              let chunk = value.subdata(in: headerLen..<(headerLen + chunkLen))
              let completed = SpotsBleInbox.shared.addFrame(
                senderId: senderId,
                msgId: msgId,
                totalLen: totalLen,
                offset: offset,
                chunk: chunk
              )
              if completed {
                SpotsBleAckStore.shared.addAck(senderId: senderId, msgId: msgId)
              }
            }
          }
        }
      }
      peripheral.respond(to: request, withResult: .success)
    }
  }

  private func startIfReady() {
    guard isAdvertisingRequested else { return }
    guard let pm = peripheralManager else { return }
    guard pm.state == .poweredOn else { return }

    // Ensure service exists
    if readCharacteristic == nil || writeCharacteristic == nil {
      guard let service = makeService() else { return }
      pm.removeAllServices()
      pm.add(service)
    }

    // Start advertising service UUID (connectable) and optional Service Data.
    var adv: [String: Any] = [
      CBAdvertisementDataServiceUUIDsKey: [serviceUuid],
    ]
    if !serviceDataFrameV1.isEmpty {
      adv[CBAdvertisementDataServiceDataKey] = [
        serviceUuid: serviceDataFrameV1,
      ]
    }
    pm.startAdvertising(adv)
  }

  private func makeService() -> CBMutableService? {
    let readChar = CBMutableCharacteristic(
      type: readCharacteristicUuid,
      properties: [.read],
      value: nil,
      permissions: [.readable]
    )

    let writeChar = CBMutableCharacteristic(
      type: writeCharacteristicUuid,
      properties: [.write, .writeWithoutResponse],
      value: nil,
      permissions: [.writeable]
    )

    let service = CBMutableService(type: serviceUuid, primary: true)
    service.characteristics = [readChar, writeChar]

    self.readCharacteristic = readChar
    self.writeCharacteristic = writeChar

    return service
  }
}

final class SpotsLocalLlmStreamHandler: NSObject, FlutterStreamHandler {
  private var sink: FlutterEventSink?

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    return nil
  }

  func emitToken(_ text: String) {
    sink?([
      "type": "token",
      "text": text,
    ])
  }

  func emitDone() {
    sink?([
      "type": "done",
    ])
  }

  func emitError(_ message: String) {
    sink?([
      "type": "error",
      "message": message,
    ])
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let blePeripheral = SpotsBlePeripheral()
  private let localLlmStreamHandler = SpotsLocalLlmStreamHandler()
  private var localLlmModel: MLModel?
  private var localLlmModelDir: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }
    
    // Initialize Google Maps SDK
    // Get API key from Info.plist
    if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
       let plist = NSDictionary(contentsOfFile: path),
       let apiKey = plist["GMSApiKey"] as? String,
       !apiKey.isEmpty && apiKey != "YOUR_IOS_GOOGLE_MAPS_API_KEY" {
      GMSServices.provideAPIKey(apiKey)
    }
    
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let inboxChannel = FlutterMethodChannel(
        name: "avra/ble_inbox",
        binaryMessenger: controller.binaryMessenger
      )

      inboxChannel.setMethodCallHandler { call, result in
        switch call.method {
        case "pollMessages":
          let args = call.arguments as? [String: Any]
          let maxMessages = args?["maxMessages"] as? Int ?? 50
          let drained = SpotsBleInbox.shared.drain(max: maxMessages)
          let mapped: [[String: Any]] = drained.map { msg in
            [
              "senderId": msg.senderId,
              "data": FlutterStandardTypedData(bytes: msg.data),
              "receivedAtMs": msg.receivedAtMs,
            ]
          }
          result(mapped)
        case "clearMessages":
          SpotsBleInbox.shared.clear()
          result(true)
        default:
          result(FlutterMethodNotImplemented)
        }
      }

      let channel = FlutterMethodChannel(
        name: "avra/ble_peripheral",
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { [weak self] call, result in
        guard let self = self else {
          result(false)
          return
        }

        switch call.method {
        case "startPeripheral":
          guard
            let args = call.arguments as? [String: Any],
            let typed = args["payload"] as? FlutterStandardTypedData
          else {
            result(false)
            return
          }
          self.blePeripheral.start(payload: typed.data)
          result(true)

        case "stopPeripheral":
          self.blePeripheral.stop()
          result(true)

        case "updatePayload":
          guard
            let args = call.arguments as? [String: Any],
            let typed = args["payload"] as? FlutterStandardTypedData
          else {
            result(false)
            return
          }
          self.blePeripheral.updatePayload(typed.data)
          result(true)

        case "updatePreKeyPayload":
          guard
            let args = call.arguments as? [String: Any],
            let typed = args["payload"] as? FlutterStandardTypedData
          else {
            result(false)
            return
          }
          self.blePeripheral.updatePreKeyPayload(typed.data)
          result(true)

        case "updateServiceDataFrameV1":
          guard
            let args = call.arguments as? [String: Any],
            let typed = args["frame"] as? FlutterStandardTypedData
          else {
            result(false)
            return
          }
          self.blePeripheral.updateServiceDataFrameV1(typed.data)
          result(true)

        default:
          result(FlutterMethodNotImplemented)
        }
      }

      let capsChannel = FlutterMethodChannel(
        name: "avra/device_capabilities",
        binaryMessenger: controller.binaryMessenger
      )

      capsChannel.setMethodCallHandler { call, result in
        switch call.method {
        case "getCapabilities":
          let memBytes = ProcessInfo.processInfo.physicalMemory
          let totalRamMb = Int(memBytes / (1024 * 1024))

          var freeDiskMb: Int? = nil
          var totalDiskMb: Int? = nil
          do {
            let attrs = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let free = attrs[.systemFreeSize] as? NSNumber {
              freeDiskMb = Int(truncating: free) / (1024 * 1024)
            }
            if let total = attrs[.systemSize] as? NSNumber {
              totalDiskMb = Int(truncating: total) / (1024 * 1024)
            }
          } catch {
            // Ignore.
          }

          let payload: [String: Any] = [
            "platform": "ios",
            "deviceModel": UIDevice.current.model,
            "osVersion": Int(ProcessInfo.processInfo.operatingSystemVersion.majorVersion),
            "totalRamMb": totalRamMb,
            "freeDiskMb": freeDiskMb as Any,
            "totalDiskMb": totalDiskMb as Any,
            "cpuCores": ProcessInfo.processInfo.processorCount,
            "isLowPowerMode": ProcessInfo.processInfo.isLowPowerModeEnabled,
          ]
          result(payload)
        default:
          result(FlutterMethodNotImplemented)
        }
      }

      let localLlmChannel = FlutterMethodChannel(
        name: "avra/local_llm",
        binaryMessenger: controller.binaryMessenger
      )
      let localLlmStreamChannel = FlutterEventChannel(
        name: "avra/local_llm_stream",
        binaryMessenger: controller.binaryMessenger
      )
      localLlmStreamChannel.setStreamHandler(localLlmStreamHandler)

      localLlmChannel.setMethodCallHandler { [weak self] call, result in
        guard let self = self else {
          result(false)
          return
        }

        switch call.method {
        case "loadModel":
          let args = call.arguments as? [String: Any]
          let modelDir = args?["model_dir"] as? String ?? ""
          if modelDir.isEmpty {
            result(false)
            return
          }
          // Try to locate a compiled CoreML model (.mlmodelc) inside the directory.
          // The conversion pipeline should place it in the pack root.
          do {
            let rootUrl = URL(fileURLWithPath: modelDir)
            let entries = try FileManager.default.contentsOfDirectory(
              at: rootUrl,
              includingPropertiesForKeys: nil,
              options: [.skipsHiddenFiles]
            )
            let mlmodelc = entries.first(where: { $0.pathExtension == "mlmodelc" })
            if let mlmodelc = mlmodelc {
              self.localLlmModel = try MLModel(contentsOf: mlmodelc)
              self.localLlmModelDir = modelDir
              result(true)
            } else {
              self.localLlmModel = nil
              self.localLlmModelDir = nil
              result(false)
            }
          } catch {
            self.localLlmModel = nil
            self.localLlmModelDir = nil
            result(false)
          }

        case "generate":
          let args = call.arguments as? [String: Any]
          let modelDir = args?["model_dir"] as? String ?? ""
          if modelDir.isEmpty {
            result(FlutterError(code: "no_model", message: "Missing model_dir", details: nil))
            return
          }
          if self.localLlmModel == nil || self.localLlmModelDir != modelDir {
            // Require explicit loadModel call first for performance and clarity.
            result(FlutterError(code: "not_ready", message: "Local LLM not loaded", details: nil))
            return
          }

          // MVP placeholder: CoreML Llama runner is wired via this channel,
          // but requires a standardized CoreML pack (conversion pipeline).
          // For now we return an explicit error so the Dart layer can fall back to cloud when online.
          result(FlutterError(code: "not_ready", message: "Local LLM not yet active on iOS", details: nil))

        case "startStream":
          let args = call.arguments as? [String: Any]
          let modelDir = args?["model_dir"] as? String ?? ""
          if modelDir.isEmpty {
            self.localLlmStreamHandler.emitError("Missing model_dir")
            self.localLlmStreamHandler.emitDone()
            result(false)
            return
          }
          if self.localLlmModel == nil || self.localLlmModelDir != modelDir {
            self.localLlmStreamHandler.emitError("Local LLM not loaded")
            self.localLlmStreamHandler.emitDone()
            result(true)
            return
          }

          self.localLlmStreamHandler.emitError("Local LLM not yet active on iOS")
          self.localLlmStreamHandler.emitDone()
          result(true)

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
