//
//  DymanicQRCodeManager.swift
//  DynamicQRCode
//
//

import Foundation
import UIKit

public class DymanicQRCodeManager {
    private static let shared: DymanicQRCodeManager = DymanicQRCodeManager()
    private var helper: QRCodeHelper!
    
    private var qrCodeString: ((String?) -> Void)?
    private var qrCodeImageView: UIImageView!
    
    public static func getInstance() -> DymanicQRCodeManager {
        return shared
    }
    
    public func initialize(applicationContext: UIApplication, hostName: String = "") {
        self.helper = QRCodeHelper(applicationContext: applicationContext, hostName: hostName)
        setupObservers()
    }
    
    public func isInitialized() -> Bool {
        return self.helper.isInitialized()
    }
    
    public func getRefreshInterval() -> Int {
        return self.helper.getRefreshInterval()
    }

    private final func setupObservers() {
        self.helper.qrCodeImage { [weak self] image in
            guard let blockSelf = self,
                  let image: UIImage = image else {
                return
            }
            blockSelf.qrCodeImageView.image = image
        }

        self.helper.qrCodeString { [weak self] qrCodeStringRepresentation in
            guard let blockSelf = self,
                  let qrCodeStringRepresentation: String = qrCodeStringRepresentation,
                  !qrCodeStringRepresentation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return
            }
            blockSelf.qrCodeString?(qrCodeStringRepresentation)
        }
    }
    
    public func generateDynamicQR(qrTicket: [String: Any], qrCodeImageView: UIImageView, refreshInterval: Int) {
        self.qrCodeImageView = qrCodeImageView
        self.helper.generateDynamicQR(qrTicket: qrTicket, refreshInterval: refreshInterval)
    }
    
    public func stopDynamicQRCodeGeneration() {
        self.helper.stopDynamicQRCodeGeneration()
    }
    
    public func qrCodeString(action: @escaping (String?) -> Void) {
        self.qrCodeString = action
    }
}
