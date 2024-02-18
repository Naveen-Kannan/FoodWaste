import SwiftUI
import AVFoundation
import Combine

// MARK: - ContentView
struct ContentView: View {
    @State private var selectedTab = 0
    @State private var image: Image? = nil
    @State private var foodItems: [FoodItem] = []
    @State private var showingAddItemSheet = false
    @State private var showingPhotoLibrary = false
    @State private var isCameraActive = false
    @State private var pastPhotos: [Image] = []
    @State private var showingEnlargedImage: Image? = nil

    
    var body: some View {
        TabView(selection: $selectedTab) {
            homeScreen
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            inventoryScreen // Updated Inventory Screen with Image Pop-up
                .tabItem {
                    Image(systemName: "leaf.fill")
                    Text("Inventory")
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
                    Image(systemName: "arrow.triangle.2.circlepath")
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
    
    // MARK: Home Screen View
    var homeScreen: some View {
        GeometryReader { geometry in
            VStack {
                Spacer().frame(height: geometry.size.height * 0.05)
                ZStack(alignment: .bottomTrailing) {
                    CameraView(image: $image, isCameraActive: $isCameraActive, pastPhotos: $pastPhotos)
                        .frame(width: geometry.size.width * 0.90, height: geometry.size.height * 0.60)
                        .cornerRadius(10)
                    Button("Library") {
                        showingPhotoLibrary = true
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .sheet(isPresented: $showingPhotoLibrary) {
                        PhotoLibrarySheet(isPresented: $showingPhotoLibrary, pastPhotos: $pastPhotos)
                    }
                }
                Button("Add Food Item") {
                    showingAddItemSheet = true
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .sheet(isPresented: $showingAddItemSheet) {
                    AddItemSheet(isPresented: $showingAddItemSheet, foodItems: $foodItems, pastPhotos: $pastPhotos)
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
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }
    
    // MARK: Inventory Screen View with Top Tabs
    var inventoryScreen: some View {
        ZStack {
            ScrollView {
                VStack {
                    // Top tabs for labels with centered alignment above the respective elements
                    HStack {
                        Text("Image")
                            .font(.headline)
                            .frame(width: 80, alignment: .center)

                        Text("Item")
                            .font(.headline)
                            .frame(minWidth: 100, alignment: .center)

                        Text("Purchase Date")
                            .font(.headline)
                            .frame(minWidth: 120, alignment: .center)

                        Text("Expiration Date")
                            .font(.headline)
                            .frame(minWidth: 120, alignment: .center)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)

                    Divider()

                    // Displaying each item in a row format aligned under the headers
                    ForEach(foodItems) { item in
                        HStack {
                            item.image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .cornerRadius(10)
                                .padding(.leading)
                                .onTapGesture {
                                    self.showingEnlargedImage = item.image
                                }

                            Text(item.itemName)
                                .frame(minWidth: 100, alignment: .center)

                            Text(item.purchaseDate, style: .date)
                                .frame(minWidth: 120, alignment: .center)

                            Text(item.expirationDate, style: .date)
                                .frame(minWidth: 120, alignment: .center)
                        }
                        .padding(.vertical, 4)
                        Divider()
                    }
                }
            }
            .padding(.horizontal)

            // Overlay for enlarged image
            if let enlargedImage = showingEnlargedImage {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        self.showingEnlargedImage = nil
                    }

                enlargedImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.height * 0.7)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding()
                    .transition(.scale)
                    .onTapGesture {
                        self.showingEnlargedImage = nil
                    }
            }
        }
    }
}

    // MARK: - FoodItem Model
    struct FoodItem: Identifiable {
        var id = UUID()
        var itemName: String
        var purchaseDate: Date
        var expirationDate: Date
        var image: Image = Image(systemName: "photo")
    }
    
    // MARK: - Camera View
    struct CameraView: UIViewControllerRepresentable {
        @Binding var image: Image?
        @Binding var isCameraActive: Bool
        @Binding var pastPhotos: [Image]
        
        func makeUIViewController(context: Context) -> UIViewController {
            let viewController = CameraViewController()
            viewController.imageHandler = { uiImage in
                let newImage = Image(uiImage: uiImage)
                self.image = newImage
                self.pastPhotos.append(newImage)
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
    
    class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
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
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let imageData = photo.fileDataRepresentation(),
                  let uiImage = UIImage(data: imageData) else { return }
            imageHandler?(uiImage)
        }
    }
    
    // MARK: - Image Picker View
    struct ImagePicker: View {
        @Binding var selectedImage: Image?
        @Binding var isPresented: Bool
        var pastPhotos: [Image]
        @State private var selectedIndex: Int? = nil
        @State private var showConfirmation = false
        
        var body: some View {
            List {
                ForEach(pastPhotos.indices, id: \.self) { index in
                    HStack {
                        pastPhotos[index]
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .cornerRadius(10)
                        Spacer() // Ensures the tap gesture covers the entire row
                    }
                    .padding(.vertical, 4)
                    .background(self.selectedIndex == index ? Color.blue.opacity(0.2) : Color.clear) // Highlight the background instead of border
                    .cornerRadius(10)
                    .contentShape(Rectangle()) // Makes the entire row tappable
                    .onTapGesture {
                        self.selectedIndex = index
                        self.selectedImage = pastPhotos[index]
                        self.showConfirmation = true
                    }
                }
            }
            .alert(isPresented: $showConfirmation) {
                Alert(
                    title: Text("Image Selected"),
                    message: Text("Do you want to use this image?"),
                    primaryButton: .default(Text("Yes")) {
                        self.isPresented = false // Close the sheet
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    
    // MARK: - Collapsible Calendar View
    struct CollapsibleCalendarView: View {
        @Binding var selectedDate: Date
        @Binding var isExpanded: Bool
        let label: String
        
        var body: some View {
            VStack {
                Button(action: {
                    withAnimation(.easeInOut) {
                        self.isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(label)
                        Spacer()
                        Text(Formatter.dateFormatter.string(from: selectedDate))
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                }
                .padding()
                
                if isExpanded {
                    DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .frame(maxHeight: 400)
                        .transition(.opacity)
                        .padding()
                }
            }
        }
        
        private struct Formatter {
            static let dateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                return formatter
            }()
        }
    }
    // MARK: - Add Item Sheet View
    struct AddItemSheet: View {
        @Binding var isPresented: Bool
        @Binding var foodItems: [FoodItem]
        @Binding var pastPhotos: [Image]
        @State private var newItemName: String = ""
        @State private var newItemPurchaseDate = Date()
        @State private var newItemExpirationDate = Date()
        @State private var selectedImage: Image? = nil
        @State private var showingImagePicker = false
        @State private var isPurchaseDateCalendarExpanded = false
        @State private var isExpirationDateCalendarExpanded = false
        @FocusState private var isItemNameFocused: Bool
        
        var body: some View {
            NavigationView {
                Form {
                    TextField("Item Name", text: $newItemName)
                        .focused($isItemNameFocused)
                        .onAppear {
                            self.isItemNameFocused = true
                        }
                    
                    if let selectedImage = selectedImage {
                        selectedImage
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .cornerRadius(10)
                    }
                    
                    Button("Select Image") {
                        showingImagePicker = true
                    }
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(selectedImage: $selectedImage, isPresented: $showingImagePicker, pastPhotos: pastPhotos)
                    }
                    
                    // Collapsible Purchase Date Section with "Today" Button and Hours
                    VStack {
                        HStack {
                            Text("Purchase Date")
                                .font(.headline)
                            Spacer()
                            if !isPurchaseDateCalendarExpanded {
                                Button("Today") {
                                    newItemPurchaseDate = Date()
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                isPurchaseDateCalendarExpanded.toggle()
                            }
                        }
                        
                        if isPurchaseDateCalendarExpanded {
                            DatePicker(
                                "Select Purchase Date",
                                selection: $newItemPurchaseDate,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                        }
                    }
                    .padding(.vertical)
                    
                    // Collapsible Expiration Date Section with Hours
                    VStack {
                        HStack {
                            Text("Expiration Date")
                                .font(.headline)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                isExpirationDateCalendarExpanded.toggle()
                            }
                        }
                        
                        if isExpirationDateCalendarExpanded {
                            DatePicker(
                                "Select Expiration Date",
                                selection: $newItemExpirationDate,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                        }
                    }
                    .padding(.vertical)
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
                            let newItem = FoodItem(
                                itemName: newItemName,
                                purchaseDate: newItemPurchaseDate,
                                expirationDate: newItemExpirationDate,
                                image: selectedImage ?? Image(systemName: "photo")
                            )
                            foodItems.append(newItem)
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Photo Library Sheet View
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
    }
    
// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
