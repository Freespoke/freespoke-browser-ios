// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

enum HapticFeedback {
    
    // MARK: Notification
    
    enum Notification {
        typealias FeedbackType = UINotificationFeedbackGenerator.FeedbackType
        
        static func generate(_ notification: FeedbackType) {
            let feedbackGenerator = UINotificationFeedbackGenerator()
            
            feedbackGenerator.prepare()
            feedbackGenerator.notificationOccurred(notification)
        }
    }
    
    // MARK: Impact
    
    enum Impact {
        typealias FeedbackStyle = UIImpactFeedbackGenerator.FeedbackStyle
        
        static func generate(_ impact: FeedbackStyle) {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: impact)
            
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
        
        static func generate(_ impact: FeedbackStyle, intensity: CGFloat) {
            let clampedIntensity = intensity.clamped(to: 0...1)
            let feedbackGenerator = UIImpactFeedbackGenerator(style: impact)
            
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred(intensity: clampedIntensity)
        }
    }
    
    // MARK: Selection
    
    enum Selection {
        static func generate() {
            let feedbackGenerator = UISelectionFeedbackGenerator()
            
            feedbackGenerator.prepare()
            feedbackGenerator.selectionChanged()
        }
    }
}
