// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Speech
import AVFoundation

protocol VoiceServiceDelegate: AnyObject {
    func speechRecognizedToText(text: String)
}

class VoiceService: NSObject {
    weak var delegate: VoiceServiceDelegate?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var currentText = ""
    private var restartTimer: Timer?
    
    var isRunning: Bool {
        return audioEngine.isRunning
    }
    
    func checkPermissions(completion: @escaping((_ granted: Bool) -> Void)) {
        self.requestMicrophoneAuthorization(completion: { micAccessGranted in
            guard micAccessGranted else {
                completion(false)
                return
            }
            
            self.requestSpeechRecognizerAuthorization(completion: { speechRecognitionGranted in
                guard speechRecognitionGranted else {
                    completion(false)
                    return
                }
                completion(true)
            })
        })
    }
    
    private func requestMicrophoneAuthorization(completion: @escaping((_ micAccessGranted: Bool) -> Void)) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            completion(true)
        case .denied:
            let alertTitle = "Speech Recognition Access"
            let alertMessage = "To allow access to Speech Recognition, please visit your device's Settings App."
            let btnOpenSettingsTitle = "Allow Access in Settings App"
            
            UIUtils.displayOpenSettingsAlert(title: alertTitle,
                                             message: alertMessage,
                                             btnOpenSettingsTitle: btnOpenSettingsTitle,
                                             openSettingsButtonCompletion: {
                print("DEBUG: Here could be sent logger event for voiceOpenAppSettingsMicAccess")
            })
            print("DEBUG: requestMicrophoneAuthorization denied!!!")
            completion(false)
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ granted in
                completion(granted)
            })
        @unknown default:
            completion(false)
        }
    }
    
    private func requestSpeechRecognizerAuthorization(completion: @escaping((_ speechRecognitionGranted: Bool) -> Void)) {
        SFSpeechRecognizer.requestAuthorization({ authStatus in
            switch authStatus {
            case .authorized:
                completion(true)
            case .denied:
                let alertTitle = "Speech Recognition Access"
                let alertMessage = "To allow access to Speech Recognition, please visit your device's Settings App."
                let btnOpenSettingsTitle = "Allow Access in Settings App"
                
                UIUtils.displayOpenSettingsAlert(title: alertTitle,
                                                 message: alertMessage,
                                                 btnOpenSettingsTitle: btnOpenSettingsTitle,
                                                 openSettingsButtonCompletion: {
                    print("DEBUG: Here could be sent logger event for voiceOpenAppSettingsSpeechRecognAccess")
                })
                print("DEBUG: requestSpeechRecognizerAuthorization denied!!!")
                completion(false)
            case .restricted:
                let alertTitle = "Speech Recognition Access"
                let alertMessage = "Speech recognition restricted on this device"
                
                UIUtils.showOkAlertInNewWindow(title: alertTitle, message: alertMessage)
                print("DEBUG: Here could be sent logger event for speechRecognitionRestrictedOnThisDevice")
                print("DEBUG: requestSpeechRecognizerAuthorization restricted!!!")
                completion(false)
            case .notDetermined:
                completion(false)
            @unknown default:
                completion(false)
            }
        })
    }
    
    func startListening(with initialText: String = "") {
        currentText = initialText
        
        // Clear all previous session data and cancel task
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // Create instance of audio session to record voice
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(
                AVAudioSession.Category.playAndRecord,
                mode: AVAudioSession.Mode.measurement,
                options: AVAudioSession.CategoryOptions.defaultToSpeaker
            )
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error: \(error.localizedDescription)")
        }
        
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        self.recognitionTask = speechRecognizer?.recognitionTask(
            with: recognitionRequest,
            resultHandler: { [weak self] result, error in
                guard let self = self else { return }
                var isFinal = false
                if let result = result {
                    var newText = result.bestTranscription.formattedString
                    if !self.currentText.isEmpty && newText.first?.isUppercase == true {
                        newText = newText.prefix(1).lowercased() + newText.dropFirst()
                    }
                    self.delegate?.speechRecognizedToText(text: self.currentText + newText)
                    isFinal = result.isFinal
                }
                
                if error != nil || isFinal {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                }
            })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)  // Ensure any existing taps are removed
        inputNode.installTap(onBus: 0,
                             bufferSize: 1_024,
                             format: recordingFormat,
                             block: { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        })
        
        self.audioEngine.prepare()
        
        do {
            try self.audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error: \(error.localizedDescription)")
        }
    }
    
    func stopRecognition() {
        self.audioEngine.stop()
        self.recognitionRequest?.endAudio()
        self.recognitionRequest = nil
        
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)  // Ensure the tap is removed when stopping recognition
    }
    
    func restartListening(with text: String) {
        stopRecognition()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: { [weak self] in
            guard let self = self else { return }
            self.startListening(with: text)
        })
    }
    
    func updateCurrentText(_ text: String) {
        currentText = text
        resetRestartTimer()
    }
    
    private func resetRestartTimer() {
        restartTimer?.invalidate()
        restartTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.restartListening(with: self.currentText)
        }
    }
}
