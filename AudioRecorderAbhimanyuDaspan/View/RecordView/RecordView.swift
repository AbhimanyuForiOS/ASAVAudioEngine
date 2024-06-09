//
//  RecordView.swift
//  AudioRecorderAbhimanyuDaspan
//
//  Created by Abhi on 05/06/24.
//

import SwiftUI

struct RecordView: View {
    
    @StateObject var viewModel:RecordViewModel
    
    var body: some View {
        ZStack {
            // Blue background for entire screen
            self.setDarkBlueBackground()
            // Recorder settings
            VStack {
                Text(viewModel.timerString)
                    .foregroundStyle(.white)
                    .font(Font.system(.largeTitle, design: .monospaced))
                    .background(.clear)
                    .padding()
                    .onReceive(viewModel.timer) { _ in
                        if viewModel.state == .recording {
                            viewModel.setTimeString()
                        }
                    }
                    .onReceive(viewModel.timerVisuliser, perform: { _ in
                        viewModel.isVisulising = true
                    })
                if viewModel.state == .recording {
                    //place a visuliser there
                    HStack(spacing: 1) {
                        ForEach(0 ..< 6) { item in
                            RoundedRectangle(cornerRadius: 2)
                                .frame(width: 3, height: .random(in: 4...45))
                                .foregroundColor(.white)
                        }
                        .animation(.easeInOut(duration: 0.01).repeatForever(autoreverses:  viewModel.isVisulising),
                                   value: true
                        )
                    }
                }
                
                HStack {
                    Button {
                        switch  viewModel.state {
                        case .stopped:
                            viewModel.recordingStarted()
                        case .recording:
                            viewModel.recordingPaused()
                        case .paused:
                            viewModel.recordingResumed()
                        }
                        
                    } label: {
                        switch  viewModel.state {
                        case .stopped:
                            Text("Start")
                                .padding()
                                .foregroundStyle(.white)
                                .border(.white, width: 1)
                        case .recording :
                            Text("Recording")
                                .padding()
                                .foregroundStyle(.white)
                                .border(.white, width: 1)
                        case .paused:
                            Text("Paused")
                                .padding()
                                .foregroundStyle(.white)
                                .border(.white, width: 1)
                        }
                    }
                    if viewModel.state != .stopped {
                        Button {
                            viewModel.recordingStoped()
                        } label: {
                            Text("Stop")
                                .padding()
                                .foregroundStyle(.white)
                                .border(.white, width: 1)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    RecordView(viewModel: RecordViewModel())
}

