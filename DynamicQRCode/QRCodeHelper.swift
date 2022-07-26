//
//  QRCodeHelper.swift
//  DynamicQRCode
//
//

import Foundation
import UIKit
import CommonCrypto

internal class QRCodeHelper {
    private var serverTime: Date?
    private var deviceTime: Date?
    private var timer: Timer!
    private var qrHash: String = ""
    private var token: String!
    private var interval: Int = 5
    private var serverTimeInt: Int!
    private var applicationContext: UIApplication!
    private var hostName: String!
    
    internal var qrCodeImage: ((UIImage?) -> Void)?
    internal var qrCodeString: ((String?) -> Void)?
    
    internal init() {}
    
    init(applicationContext: UIApplication, hostName: String = "") {
        self.applicationContext = applicationContext
        self.hostName = hostName
    }
    
    internal func isInitialized() -> Bool {
        return true
    }
    
    internal func generateDynamicQR(qrTicket: [String: Any], refreshInterval: Int) {
        self.interval = refreshInterval
        self.qrLogic(qrTicket: qrTicket)
        timer =  Timer.scheduledTimer(withTimeInterval: TimeInterval(self.interval), repeats: true, block: { [weak self] (t) in
            self?.qrLogic(qrTicket: qrTicket)
        })
    }
    
    private func qrLogic(qrTicket: [String: Any]) {
        let currentDeviceTime = Date()
        let timeDelta = currentDeviceTime.timeIntervalSince((Date()))
        
        // New Server Time
        let newServerTime = Date() + timeDelta
        
        // New Server Time in Seconds / 5.0 => 5 is QR Code Refresh Time in seconds
        let newServerTimeTimeWithRefreshValue = Int(floor((newServerTime.timeIntervalSince1970 / 5.0)))
        
        serverTimeInt = newServerTimeTimeWithRefreshValue
        
        // New Server Time String Format
        let newServerTimeString = "\(newServerTimeTimeWithRefreshValue)"
        // Secret
        let secret = "ABCC1234XXYZ"
        
        // SHA256 of the Data
        qrHash = newServerTimeString.hmac(key: secret)
        
        if let productNumber = qrTicket["productNumber"],
            let ticketNumber = qrTicket["ticketNumber"],
            let privateData = qrTicket["privateData"],
            let expiryTime = qrTicket["expiryTime"],
            let mediaType = qrTicket["mediaType"],
            let signature = qrTicket["signature"] {
            let qrCodeData = "\(productNumber)\(ticketNumber)\(privateData)\(expiryTime)\(mediaType)\(signature)\(qrHash)"
            let qrCode = QRCode(qrCodeData)
            // QR Code displayed in the Image View in the main thread
            self.qrCodeImage?(qrCode?.image)
            self.qrCodeString?(qrCode?.data.base64EncodedString())
        }
    }
    
    internal func qrCodeImage(action: @escaping (UIImage?) -> Void) {
        self.qrCodeImage = action
    }

    internal func qrCodeString(action: @escaping (String?) -> Void) {
        self.qrCodeString = action
    }
    
    internal func stopDynamicQRCodeGeneration() {
        self.timer.invalidate()
    }
    
    internal func getRefreshInterval() -> Int {
        return interval
    }
}

private extension String {
    func hmac(key: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key, key.count, self, self.count, &digest)
        let data = Data(bytes: digest, count: digest.count)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
}
