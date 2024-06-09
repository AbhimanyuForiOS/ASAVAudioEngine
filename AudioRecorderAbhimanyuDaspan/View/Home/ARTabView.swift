//
//  ARTabView.swift
//  AudioRecorderAbhimanyuDaspan
//
//  Created by Abhi on 05/06/24.
//

import SwiftUI

struct ARTabView: View {
    @State public var selectedIndex = 0
    
    var body: some View {
        
        TabView(selection: $selectedIndex) {
            
            NavigationStack.init {
                RecordView(viewModel: RecordViewModel())
                    .navigationTitle("Record Audio")
                    .navigationBarTitleTextColor(.white)
            }
            .tabItem {
                Text("Record")
                    .foregroundStyle(.white)
                Image(systemName: "waveform")
                    .foregroundStyle(.white)
            }
            .tag(1)
            
            NavigationStack.init {
                SavedRecordingsView(viewModel: SavedRecordingsViewModel())
                    .navigationTitle("Saved Recordings")
                    .navigationBarTitleTextColor(.white)
            }
            .tabItem {
                Text("Saved Recordings")
                    .foregroundStyle(.white)
                Image(systemName: "beats.headphones")
                    .foregroundStyle(.white)
            }
            .tag(2)
        }
        .tint(Color.white)
    }
}

#Preview {
    ARTabView()
}
