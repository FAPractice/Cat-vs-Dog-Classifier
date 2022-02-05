//
//  ContentView.swift
//  Shared
//
//  Created by Harsh Chaturvedi on 02/03/21.
//

import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State var inputImage: UIImage?
    @State var text = "Choose Image"
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
        classify()
    }
    func classify(){
        let model = CatVsDog()
        if let classifyImage = inputImage {
            if let classifyPixelBuffer = classifyImage.toCVPixelBuffer(){
                do {
                    text = "Classifying"
                    let prediction = try model.prediction(input: CatVsDogInput(image: classifyPixelBuffer))
                    text = prediction.classLabel
                } catch {
                    text = "Something went wrong"
                }
            }
        }
    }
    var body: some View {
        VStack {
            Text("🐱 Cat or Dog 🐶")
                .font(.title)
                .bold()
                .foregroundColor(showingImagePicker ? .gray: .primary)
            Button(action: {
                self.showingImagePicker = true
            }) {
                ZStack {
                    if let safeImage = image {
                        safeImage
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 0.0))
                            .padding()
                            .padding(.top)
                            .padding(.bottom)
                            .aspectRatio(contentMode: .fit)
                            .shadow(color: showingImagePicker ? .gray : Color.black.opacity(0.24), radius: 20, x:0.0,y:8)
                        RoundedRectangle(cornerRadius: 0.0)
                            .padding()
                            .padding(.top)
                            .padding(.bottom)
                            .foregroundColor(Color.black.opacity(0))
                    } else {
                        RoundedRectangle(cornerRadius: 25.0)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(showingImagePicker ? .gray: .red)
                            .shadow(color: showingImagePicker ? .gray : .red, radius: 20, x:0.0,y:12.0)
                            .padding()
                            .padding(.top)
                            .padding(.bottom)
                    }
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.white)
                        .shadow(color: .white, radius: 20, x: 0.0, y: 12 )
                }
                .frame(maxWidth: .infinity)
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
            if let val = image != nil {
                Text(text)
                    .font(val ? .title : .title3)
                    .foregroundColor(val ? .black : .gray)
                    .padding()
            }
        }
        .animation(.easeIn)
        
        .padding()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
import UIKit

extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            return nil
        }
        
        if let pixelBuffer = pixelBuffer {
            CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
            
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
            
            context?.translateBy(x: 0, y: self.size.height)
            context?.scaleBy(x: 1.0, y: -1.0)
            
            UIGraphicsPushContext(context!)
            self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
            UIGraphicsPopContext()
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            
            return pixelBuffer
        }
        
        return nil
    }
}
