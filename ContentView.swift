import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var image: Image? = nil
    @State private var foodItems: [FoodItem] = []
    @State private var showingAddItemSheet = false
    @State private var showingPhotoLibrary = false
    @State private var isCameraActive = false
    @State private var pastPhotos: [Image] = []

    var body: some View {
        TabView(selection: $selectedTab) {
            homeScreen
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)

            rawInventoryScreen
                .tabItem {
                    Image(systemName: "leaf.fill")
                    Text("Raw Inventory")
                }
                .tag(1)

            Color.red
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Recipes")
                }
                .tag(2)

            Color.gray
                .tabItem {
                    Image(systemName: "trash.fill")
                    Text("Waste Reduction")
                }
                .tag(3)

            Color.blue
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }
                .tag(4)
        }
    }

    var homeScreen: some View {
        GeometryReader { geometry in
            VStack {
                Spacer().frame(height: geometry.size.height * 0.05)
                HStack {
                    Spacer()
                    VStack {
                        CameraView(image: $image, isCameraActive: $isCameraActive)
                            .frame(width: geometry.size.width * 0.90, height: geometry.size.height * 0.60)
                            .cornerRadius(10)
                        Button("Library") {
                            showingPhotoLibrary = true
                        }
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .sheet(isPresented: $showingPhotoLibrary) {
                            PhotoLibrarySheet(isPresented: $showingPhotoLibrary, pastPhotos: $pastPhotos)
                        }
                        Button("Add Food Item") {
                            showingAddItemSheet = true
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .sheet(isPresented: $showingAddItemSheet) {
                            AddItemSheet(isPresented: $showingAddItemSheet, foodItems: $foodItems)
                        }
                        Button(action: {
                            isCameraActive.toggle()
                        }) {
                            Image(systemName: "camera")
                                .font(.largeTitle)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .padding(.top, 10)
                    }
                    Spacer()
                }
                Spacer() // Add a spacer to fill the remaining space
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }

    var rawInventoryScreen: some View {
        List {
            ForEach(foodItems) { item in
                VStack(alignment: .leading) {
                    Text(item.itemName)
                        .font(.headline)
                    Text(item.date)
                    Text(item.expirationDate)
                }
            }
            .onDelete(perform: deleteFoodItems)
        }
    }

    func deleteFoodItems(at offsets: IndexSet) {
        foodItems.remove(atOffsets: offsets)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AddItemSheet: View {
    @Binding var isPresented: Bool
    @Binding var foodItems: [FoodItem]
    @State private var newItemName: String = ""
    @State private var newItemDate: String = ""
    @State private var newItemExpirationDate: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Item Name", text: $newItemName)
                TextField("Date", text: $newItemDate)
                TextField("Expiration Date", text: $newItemExpirationDate)
            }
            .navigationTitle("Add Food Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newItem = FoodItem(itemName: newItemName, date: newItemDate, expirationDate: newItemExpirationDate)
                        foodItems.append(newItem)
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct PhotoLibrarySheet: View {
    @Binding var isPresented: Bool
    @Binding var pastPhotos: [Image]

    var body: some View {
        NavigationView {
            List {
                ForEach(pastPhotos.indices, id: \.self) { index in
                    pastPhotos[index]
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .cornerRadius(10)
                }
                .onDelete(perform: deletePastPhotos)
            }
            .navigationTitle("Photo Library")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }

    func deletePastPhotos(at offsets: IndexSet) {
        pastPhotos.remove(atOffsets: offsets)
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: Image?
    @Binding var isCameraActive: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = CameraViewController()
        viewController.imageHandler = { uiImage in
            self.image = Image(uiImage: uiImage)
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isCameraActive {
            (uiViewController as? CameraViewController)?.takePhoto()
            isCameraActive = false
        }
    }
}

class CameraViewController: UIViewController {
    var imageHandler: ((UIImage) -> Void)?
    private let captureSession = AVCaptureSession()
    private var capturePhotoOutput = AVCapturePhotoOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    private func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            captureSession.startRunning()
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)

            if captureSession.canAddOutput(capturePhotoOutput) {
                captureSession.addOutput(capturePhotoOutput)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        capturePhotoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: imageData) else { return }
        imageHandler?(uiImage)
    }
}

struct FoodItem: Identifiable {
    var id = UUID()
    var itemName: String
    var date: String
    var expirationDate: String
}
