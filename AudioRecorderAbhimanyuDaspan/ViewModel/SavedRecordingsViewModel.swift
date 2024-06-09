//
//  SavedRecordingsViewModel.swift
//  AudioRecorderAbhimanyuDaspan
//
//  Created by Abhi on 05/06/24.
//

import Foundation
import AVFoundation

@MainActor
class SavedRecordingsViewModel: ObservableObject {
    
    @Published var recordings:[SavedRecording] = [SavedRecording]()
    
    var audioPlayer:AVAudioPlayer!
    
    init() {
    }
    
    // MARk: Fetch All Recorded files
    func fetchAllRecordings() -> [SavedRecording] {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var files = [SavedRecording]()
        if let enumerator = FileManager.default.enumerator(at: documentURL, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        let savedRecording = SavedRecording(fileName: fileURL.lastPathComponent, filePath: fileURL)
                        files.append(savedRecording)
                    }
                } catch { print(error, fileURL) }
            }
            print(files)
        }
        files = files.sorted{ $0.fileName < $1.fileName}
        return files
    }
    func playRecording(recordingSelected:SavedRecording) {
        if audioPlayer != nil {
            audioPlayer.stop()
        }
        if recordingSelected.isPlaying == true {
            recordings.forEach { recording in
                recording.isPlaying = false
            }
        } else {
            recordings.forEach { recording in
                if recordingSelected.fileName != recording.fileName {
                    recording.isPlaying = false
                } else {
                    recording.isPlaying = true
                    preparePlayer(url: recording.filePath)
                    audioPlayer.play()
                }
            }
        }
      
        //update ui
        recordings = recordings
    }
    
    func preparePlayer(url:URL) {
          do {
              audioPlayer = try AVAudioPlayer(contentsOf: url)
              audioPlayer.prepareToPlay()
              audioPlayer.volume = 10.0
          } catch {
              audioPlayer = nil
          }
      }
}


class SavedRecording: Identifiable {
    var id = UUID()
    var fileName : String
    var filePath : URL
    var isPlaying:Bool = false {
        didSet {
            if isPlaying {
                plyaPausedTitle = "Pause"
                
            } else {
                plyaPausedTitle = "Play"
            }
        }
    }
    var plyaPausedTitle:String = "Play"
    
    init(id: UUID = UUID(), fileName: String, filePath: URL) {
        self.id = id
        self.fileName = fileName
        self.filePath = filePath
    }
    
}
