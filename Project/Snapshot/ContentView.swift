//
//  ContentView.swift
//  Snapshot
//
//  Created by Gustavo Araujo Santos on 10/16/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var model = DataModel()
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                if let image = model.viewfinderImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .task {
                await model.camera.start()
            }
            .navigationBarHidden(true)
            .ignoresSafeArea()
            .statusBar(hidden: true)
        }
    }
}

#Preview {
    ContentView()
}
