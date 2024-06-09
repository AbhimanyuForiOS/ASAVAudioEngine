//
//  RecordViewModel.swift
//  AudioRecorderAbhimanyuDaspan
//
//  Created by Abhi on 05/06/24.
//

import Foundation
import Combine


@MainActor
class RecordViewModel: ObservableObject {
    
    
    @Published var startTime =  Date()
    var pausedDate:Date?
    var resumedDate:Date?
    @Published var timerString = "00:00.00"
    
    @Published var timer = Timer.publish(every: 1, on: .main, in: .common)
    private var timerSubscription: Cancellable?
    
    @Published var timerVisuliser = Timer.publish(every: 0.025, on: .main, in: .common)
    private var timerVisuliserSubscription: Cancellable?
    @Published var isVisulising = false

    
    
    private var subscribers: [AnyCancellable] = [AnyCancellable]()
    
    @Published var isRecorderHaveAnyIssue:Bool = false
    @Published var messageRecorderFault:String = ""
    
    private var recorder:Recorder
    
    @Published var state: RecordingState = .stopped

    init() {
        recorder = Recorder()
        
        recorder.$state.sink { [weak self] state in
            self?.state = state
        }.store(in: &subscribers)
    }
    
    // MARK: Recording controls functions
    func recordingStarted() {
        do {
            try  recorder.startRecording()
            startTime = Date()
            self.startTimer()
            
        } catch {
            isRecorderHaveAnyIssue = true
            messageRecorderFault = error.localizedDescription
        }
    }
    func recordingResumed() {
        do {
            try  recorder.resumeRecording()
            resumedDate = Date()
        } catch {
            isRecorderHaveAnyIssue = true
            messageRecorderFault = error.localizedDescription
        }
    }
    
    func recordingStoped() {
        recorder.stopRecording()
        timerString = "00:00"
        self.stopTimer()
    
    }
    func recordingPaused() {
        pausedDate = Date()
        recorder.pauseRecording()
    }
    
    // Timer Related functions
    func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
        timerSubscription = timer.connect()
        
        timerVisuliser = Timer.publish(every: 0.25, on: .main, in: .common)
        timerVisuliserSubscription = timerVisuliser.connect()
    }
    
    func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
        
        timerVisuliserSubscription?.cancel()
        timerVisuliserSubscription = nil
    }
    
    /// logic for bg Sync and resume/paused
    func setTimeString() {
        if let pausedDate = pausedDate,
           let resumededDate = resumedDate {
            // user paused some where so calulate diff of it and then show final diffrence time on label
            let pausedTimeInterval = resumededDate.timeIntervalSince(pausedDate)
            startTime =  startTime.addingTimeInterval(pausedTimeInterval)
            self.pausedDate = nil
            self.resumedDate = nil
        }
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: startTime, to: Date())
        guard let hours = components.hour,
                let minutes = components.minute,
                let seconds = components.second else {
            return
        }
        if hours == 4 {
            recordingStoped()
        } else {
            //update label
            timerString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
}


