//
//  ContentView.swift
//  ZoomImageViewSample
//
//  Created by Ronaldo Avalos on 26/03/25.
//

import SwiftUI
import ZoomImageView

struct ContentView: View {
    
    @State var imageNum: Int = 1
    @State var imageExample: UIImage = UIImage(named: "photo 1")!
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white,.black.secondary)
                Spacer()
                Text("Image")
                Spacer()
                Button {
                    withAnimation {
                        imageNum += 1
                        imageExample = UIImage(named:"photo \(imageNum)")!
                    }
                    if imageNum == 3 {
                        imageNum = 0
                    }
                } label: {
                    Image(systemName: "photo.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white,.black.secondary)
                }
            }.padding(.horizontal)
            
            GeometryReader { proxy in
                ZoomImageView(image: imageExample)
                    .maximumZoomScale(5.0)
                    .minimumZoomScale(0.7)
                    .doubleTapZoomScale(2.5)
                    .frame(width: proxy.size.width,height: proxy.size.height)
            }
            .background(.gray.opacity(0.2))

          
    
            HStack {
                ForEach(0...10,id: \.self) {_ in
                    filter()
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func filter() -> some View {
        VStack(spacing:0) {
            Image(uiImage:imageExample)
                .resizable()
                .scaledToFill()
            
        }
        .frame(width: 70,height: 90)
        .clipped()
        .overlay(alignment:.bottom) {
            ZStack {
                Rectangle().fill(Color.orange)
                    .frame(height: 15)
                Text("Filter")
                    .font(.caption)
                    .foregroundStyle(.white)
            }
            
        }
    }
}

#Preview {
    ContentView()
}
