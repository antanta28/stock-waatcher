//
//  HapticsManager.swift
//  StockApp
//
//  Created by Kirill Fedin on 08.01.2022.
//

import Foundation
import UIKit

final class HapticsManager {
    /// Singletone
    static let shared = HapticsManager()
    private init() {}
    
    // MARK: - Public
    public func vibrateForSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    /// Play haptic for given type interaction
    /// - Parameter type: Type to vibrate
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
