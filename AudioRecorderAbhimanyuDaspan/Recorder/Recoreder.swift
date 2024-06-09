import AVFoundation
// recording states  control enum
enum RecordingState {
    case recording, paused, stopped
}

class Recorder:ObservableObject {
    
    private var engine: AVAudioEngine!
    private var mixerNode: AVAudioMixerNode!
    @Published var state: RecordingState = .stopped
    
    var converter: AVAudioConverter!
    var compressedBuffer: AVAudioCompressedBuffer?
    
    // intruption handling
    fileprivate var isInterrupted = false

    
    
    init() {
        setupSession()
        setupEngine()
        
        // Handling interruption(calls or siri) and termination(app crash or force termination) cases of the App
        registerForNotifications()
    }
    
    // MARK: - Privates
    fileprivate func setupSession() {
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
        }
        catch {
            print("ERROR in setCategory :", error)
        }
        
        do {
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch {
            print("ERROR in setActive :", error)
        }
    }
    
    fileprivate func setupEngine() {
        engine = AVAudioEngine()
        mixerNode = AVAudioMixerNode()
        
        // Set volume to 0 to avoid audio feedback while recording.
        mixerNode.volume = 0
        
        engine.attach(mixerNode)
        
        makeConnections()
        
        // Prepare the engine in advance, in order for the system to allocate the necessary resources.
        engine.prepare()
    }
    
    fileprivate func makeConnections() {
        let inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        engine.connect(inputNode, to: mixerNode, format: inputFormat)
        
        let mainMixerNode = engine.mainMixerNode
        let mixerFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: inputFormat.sampleRate, channels: 1, interleaved: false)
        engine.connect(mixerNode, to: mainMixerNode, format: mixerFormat)
    }
    
    
    func startRecording() throws {
      let tapNode: AVAudioNode = mixerNode
      let format = tapNode.outputFormat(forBus: 0)
       
      let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      
      // AVAudioFile uses the Core Audio Format (CAF) to write to disk.
      // So we're using the caf file extension.
        let file = try AVAudioFile(forWriting: documentURL.appendingPathComponent("\(Date().timeIntervalSince1970).caf"), settings: format.settings)

      tapNode.installTap(onBus: 0, bufferSize: 4096, format: format, block: {
        (buffer, time) in
        try? file.write(from: buffer)
      })

      try engine.start()
      state = .recording
    }
    
    func resumeRecording() throws {
        try engine.start()
        state = .recording
    }
    
    func pauseRecording() {
        engine.pause()
        state = .paused
    }
    
    func stopRecording() {
        // Remove existing taps on nodes
        mixerNode.removeTap(onBus: 0)
        
        engine.stop()
        state = .stopped
    }
    
    
}

//MARK: For compressing Audio Output
extension Recorder {
    //MARK: Handling interruption(calls or siri) and termination(app crash or force termination) cases of the App
    fileprivate func registerForNotifications() {
        
        // register interruptionNotification
        NotificationCenter.default.addObserver(
        forName: AVAudioSession.interruptionNotification,
        object: nil,
        queue: nil
      )
      { [weak self] (notification) in
        guard let weakself = self else {
          return
        }

        let userInfo = notification.userInfo
        let interruptionTypeValue: UInt = userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt ?? 0
        let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeValue)!

        switch interruptionType {
        case .began:
          weakself.isInterrupted = true

          if weakself.state == .recording {
            weakself.pauseRecording()
          }
        case .ended:
          weakself.isInterrupted = false

          // Activate session again
          try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)

          //weakself.handleConfigurationChange()

          if weakself.state == .paused {
            try? weakself.resumeRecording()
          }
        @unknown default:
          break
        }
      }
        
        //register  mediaServicesWereResetNotification (App termination case)
        NotificationCenter.default.addObserver(
          forName: AVAudioSession.mediaServicesWereResetNotification,
          object: nil,
          queue: nil
        ) { [weak self] (notification) in
          guard let weakself = self else {
            return
          }

          weakself.setupSession()
          weakself.setupEngine()
        }
    }
    
}
