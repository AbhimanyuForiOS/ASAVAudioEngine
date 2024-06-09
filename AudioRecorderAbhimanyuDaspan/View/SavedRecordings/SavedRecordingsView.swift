//
//  SavedRecordingsView.swift
//  AudioRecorderAbhimanyuDaspan
//
//  Created by Abhi on 05/06/24.
//

import SwiftUI

struct SavedRecordingsView: View {
    @StateObject var viewModel:SavedRecordingsViewModel
    var body: some View {
        ZStack {
            self.setDarkBlueBackground()
            if viewModel.recordings.isEmpty  {
                Text("Saved Recordings will Apear here")
            }else {
                List(viewModel.recordings) { savedRecording in
                    HStack {
                        Text(" \(savedRecording.fileName)")
                            .padding()
                        Button {
                            viewModel.playRecording(recordingSelected: savedRecording)
                        } label: {
                            Text(savedRecording.plyaPausedTitle)
                                .padding()
                                .foregroundStyle(.pink)
                                .border(.white, width: 1)
                        }
                    }
                  
                }
            }
        }
        .onAppear(perform: {
            viewModel.recordings = viewModel.fetchAllRecordings()
        })
    }
}

#Preview {
    SavedRecordingsView(viewModel: SavedRecordingsViewModel())
}
