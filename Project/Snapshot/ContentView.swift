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
                ZStack {
                    if let image = model.viewfinderImage {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Button(action: {
                                model.camera.switchCaptureDevice()
                            }) {
                                Image(systemName: "arrow.triangle.2.circlepath.camera")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            .padding(.leading, 20)
                            
                            Spacer()
                            
                            Button(action: {
                                model.camera.takePhoto()
                            }) {
                                Image(systemName: "camera")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, 20)
                        }
                        .padding(.bottom, 30)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
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
