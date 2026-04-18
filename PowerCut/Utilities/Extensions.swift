//
//  Extensions.swift
//  PowerCut
//
//  Useful extensions
//

import Foundation
import AVFoundation
import Combine

extension AVPlayer {
    func periodicTimePublisher(interval: CMTime = CMTime(seconds: 0.1, preferredTimescale: 600)) -> AnyPublisher<CMTime, Never> {
        let subject = PassthroughSubject<CMTime, Never>()
        
        addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            subject.send(time)
        }
        
        return subject.eraseToAnyPublisher()
    }
}

extension CMTime {
    var displayString: String {
        let seconds = CMTimeGetSeconds(self)
        return TimeFormatter.format(seconds: seconds)
    }
}
