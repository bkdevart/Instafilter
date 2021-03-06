//
//  ContentView.swift
//  Instafilter
//
//  Created by Brandon Knox on 5/14/21.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ErrorAlert: Identifiable {
    var id: String { errorMessage }
    let errorMessage: String
}

enum SliderChosen {
    case intensity
    case radius
    case scale
}

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 0.5
    @State private var filterScale = 0.5
    
    @State private var showingFilterSheet = false
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    
    @State var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State var filterDisplayName = "Sepia Tone"
    let context = CIContext()
    
    @State private var errorAlert: ErrorAlert?
    
    private var slider = SliderChosen.intensity
    
    var body: some View {
        let intensity = Binding<Double>(
            get: {
                self.filterIntensity
            },
            set: {
                self.filterIntensity = $0
                self.applyProcessing(slider: .intensity)
            }
        )
        
        let radius = Binding<Double>(
            get: {
                self.filterRadius
            },
            set: {
                self.filterRadius = $0
                self.applyProcessing(slider: .radius)
            }
        )
        
        let scale = Binding<Double>(
            get: {
                self.filterScale
            },
            set: {
                self.filterScale = $0
                self.applyProcessing(slider: .scale)
            }
        )
        
        return NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary)
                    
                    if image != nil {
                        image?
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    self.showingImagePicker = true
                }
                
                // Experiment with having more than one slider, to control each of the input keys you care about. For example, you might have one for radius and one for intensity.
                HStack {
                    Text("Intensity")
                    Slider(value: intensity)
                }
                .padding(.vertical)
                
                HStack {
                    Text("Radius")
                    Slider(value: radius)
                }
                .padding(.vertical)
                
                HStack {
                    Text("Scale")
                    Slider(value: scale)
                }
                .padding(.vertical)
                
                HStack {
                    Button("\(filterDisplayName)") {
                        self.showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save") {
                        
                        guard let processedImage = self.processedImage else {
                            errorAlert = ErrorAlert(errorMessage: "Please select an image to filter")
                            return
                        }
                        
                        let imageSaver = ImageSaver()
                        
                        imageSaver.successHandler = {
                            print("Success!")
                        }
                        
                        imageSaver.errorHandler = {
                            print("Oops: \($0.localizedDescription)")
                        }
                        
                        imageSaver.writeToPhotoAlbum(image: processedImage)
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationBarTitle("Instafilter")
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
            .actionSheet(isPresented: $showingFilterSheet) {
                ActionSheet(title: Text("Select a filter"), buttons: [
                    .default(Text("Crystallize")) {
                        filterDisplayName = "Crystallize"
                        self.setFilter(CIFilter.crystallize())
                    },
                    .default(Text("Edges")) {
                        filterDisplayName = "Edges"
                        self.setFilter(CIFilter.edges())
                    },
                    .default(Text("Gaussian Blur")) {
                        filterDisplayName = "Guassian Blur"
                        self.setFilter(CIFilter.gaussianBlur())
                    },
                    .default(Text("Pixellate")) {
                        filterDisplayName = "Pixellate"
                        self.setFilter(CIFilter.pixellate())
                    },
                    .default(Text("Sepia Tone")) {
                        filterDisplayName = "Sepia Tone"
                        self.setFilter(CIFilter.sepiaTone())
                    },
                    .default(Text("Unsharp Mask")) {
                        filterDisplayName = "Unsharp Mask"
                        self.setFilter(CIFilter.unsharpMask())
                    },
                    .default(Text("Vignette")) {
                        filterDisplayName = "Vignette"
                        self.setFilter(CIFilter.vignette())
                    },
                    .cancel()
                ])
            }
            .alert(item: $errorAlert) { alert in
                        Alert(title: Text("Error"),
                              message: Text(alert.errorMessage),
                              dismissButton: .cancel(Text("OK")))
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing(slider: .intensity)
    }
    
    func applyProcessing(slider: SliderChosen) {
        let inputKeys = currentFilter.inputKeys
        print("\(inputKeys)")
        
        switch slider {
        case .intensity:
            if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        case .radius:
            if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterRadius * 200, forKey: kCIInputRadiusKey) }
        case .scale:
            if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterScale * 50, forKey: kCIInputScaleKey) }
        }
        guard let outputImage = currentFilter.outputImage else { return }
    
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
        
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
