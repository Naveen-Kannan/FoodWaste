import SwiftUI
import AVFoundation
import Combine

extension Color {
    static let Beige = Color(red: 1.0, green: 0.96, blue: 0.86)
    static let dustyRose = Color(red: 0.86, green: 0.63, blue: 0.63)
    static let mutedPink = Color(red: 0.91, green: 0.67, blue: 0.67)
    static let sageGreen = Color(red: 0.69, green: 0.73, blue: 0.54)
    static let softCoral = Color(red: 0.94, green: 0.50, blue: 0.50)
    static let teal = Color(red: 0.00, green: 0.50, blue: 0.50)
    static let turquoise = Color(red: 0.25, green: 0.88, blue: 0.82)
    static let lightBrown = Color(red: 0.65, green: 0.50, blue: 0.39)
    static let taupe = Color(red: 0.40, green: 0.40, blue: 0.40)
    static let navyBlue = Color(red: 0.00, green: 0.00, blue: 0.50)
    static let warmGrey = Color(red: 0.50, green: 0.50, blue: 0.50)
    static let burntSienna = Color(red: 0.91, green: 0.45, blue: 0.32)
    static let terracotta = Color(red: 0.89, green: 0.45, blue: 0.36)
}

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
    @State private var selectedItem: FoodItem? = nil
    @State private var showingConfirmation = false
    @State private var itemToDelete: FoodItem?
    @State private var isDeleting = false
    @State private var showingEditItemSheet = false // If you want a separate state for editing
    @State private var confirmationMessage: String = ""
    @State private var actionToConfirm: (() -> Void)?
    @State private var editingItem: FoodItem?
    @State private var showingConfirmationDialog = false
    @State private var showingDeleteConfirmation = false
    @State private var isLoading = false // State to control the loading screen appearance
    
    
    init() {
        // Set navigation bar background color
        UINavigationBar.appearance().backgroundColor = UIColor(Color.sageGreen)
        UINavigationBar.appearance().barTintColor = UIColor(Color.sageGreen) // For the bar background
        UINavigationBar.appearance().isTranslucent = false // Optional: Based on your design needs
        
        // Set navigation bar title color
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.Beige)]
        
        // Set navigation bar large title color (if you're using large titles)
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.Beige)]
        
        // Customize the bottom tab bar background and item colors
        UITabBar.appearance().backgroundColor = UIColor(Color.sageGreen) // Example background color for tab bar
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.Beige.opacity(0.8)) // Example unselected item color
        UITabBar.appearance().tintColor = UIColor(Color.dustyRose) // Example selected item color
    }
    var sortedFoodItems: [FoodItem] {
        foodItems.sorted { $0.daysUntilExpiration < $1.daysUntilExpiration }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            homeScreen
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                        .foregroundColor(.Beige.opacity(0.7))
                        .background(Color.sageGreen)
                }
                .tag(0)
            
            inventoryScreen // Updated Inventory Screen with Image Pop-up
                .tabItem {
                    Image(systemName: "leaf.fill")
                    Text("Inventory")
                        .foregroundColor(.Beige.opacity(0.7))
                        .background(Color.sageGreen)
                }
                .tag(1)
            
            Color.gray
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Analytics")
                        .foregroundColor(.Beige.opacity(0.7))
                        .background(Color.sageGreen)
                }
                .tag(2)
            
            ChatView() //chat window
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                        .foregroundColor(.Beige)
                        .background(Color.sageGreen)
                }
                .tag(3)
        }
        .accentColor(Color.Beige.opacity(2.0)) // This should change the selected tab item color

        .overlay(
            VStack {
                Spacer()
                if selectedTab == 0 { // Check if the home screen tab is selected
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddItemSheet = true
                        }) {
                            Text("Add")
                                .font(.headline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .foregroundColor(.Beige)
                                .background(Color.sageGreen)
                                .cornerRadius(20)
                                .shadow(radius: 2)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 70) // Adjust padding as needed
                    }
                }
            }
        )
        
        .sheet(isPresented: $showingAddItemSheet) {
            AddItemSheet(isPresented: $showingAddItemSheet, foodItems: $foodItems, pastPhotos: $pastPhotos)
        }
    }
    
    
    // MARK: Home Screen View
    var homeScreen: some View {
        GeometryReader { geometry in
            VStack {
                Spacer().frame(height: geometry.size.height * 0.05)
                
                Text("HodgePodge") // Your line of text
                    .font(.system(size: 56, weight: .medium, design: .default))
                    .foregroundColor(Color.sageGreen) // Set the text color to sageGreen
                    .background(Color.clear) // Ensure background is transparent
                    .padding(4) // Add some space below the text
                
                ZStack(alignment: .bottomTrailing) {
                    CameraView(image: $image, isCameraActive: $isCameraActive, pastPhotos: $pastPhotos)
                        .frame(width: geometry.size.width * 0.90, height: geometry.size.height * 0.60)
                        .cornerRadius(10)
                    Button("Library") {
                        showingPhotoLibrary = true
                    }
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .foregroundColor(.Beige)
                    .cornerRadius(8)
                    .sheet(isPresented: $showingPhotoLibrary) {
                        PhotoLibrarySheet(isPresented: $showingPhotoLibrary, pastPhotos: $pastPhotos)
                    }
                }
                
                // HStack for camera buttons
                HStack(spacing: 20) { // Adjust spacing as needed
                    // For Items
                    Button(action: {
                        isCameraActive.toggle()
                    }) {
                        Image(systemName: "camera")
                            .font(.largeTitle)
                            .padding()
                            .background(Color.sageGreen)
                            .foregroundColor(Color.Beige)
                            .clipShape(Circle())
                    }
                    
                    // For expiration date
                    Button(action: {
                        isCameraActive.toggle()
                    }) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.largeTitle)
                            .padding()
                            .background(Color.sageGreen)
                            .foregroundColor(.Beige)
                            .clipShape(Circle())
                    }
                    
                    // For barcode
                    Button(action: {
                        isCameraActive.toggle()
                    }) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.largeTitle)
                            .padding()
                            .background(Color.sageGreen)
                            .foregroundColor(.Beige)
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.Beige)
        }
    }
    
    
    // MARK: Inventory Screen View with Top Tabs
    var inventoryScreen: some View {
        ZStack {
            Color.Beige.edgesIgnoringSafeArea(.top)
            
            ScrollView {
                
                VStack {
                    // Top tabs for labels with centered alignment above the respective elements
                    HStack {
                        Text("Image")
                            .font(.headline)
                            .foregroundColor(Color.sageGreen) // Text color
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Color.clear) // Background color
                        
                        
                        Text("Item")
                            .font(.headline)
                            .foregroundColor(Color.sageGreen) // Text color
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Color.clear) // Background color
                        
                        
                        Text("Quantity")
                            .font(.headline)
                            .foregroundColor(Color.sageGreen) // Text color
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Color.clear) // Background color
                        
                        
                        Text("Expires")
                            .font(.headline)
                            .foregroundColor(Color.sageGreen) // Text color
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Color.clear) // Background color
                        
                    }
                    .padding(.vertical, 8) // Padding for top and bottom of the text
                  // Apply background here for full width
                    .padding(.horizontal, 8)
                    
                    Divider()
                    
                    // Displaying each item in a row format aligned under the headers
                    ForEach(sortedFoodItems) { item in
                        HStack {
                            item.image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .cornerRadius(10)
                                .padding(.leading)
                                .onTapGesture {
                                    self.selectedItem = item // Set the selectedItem for the overlay
                                }
                            
                            Text(item.itemName)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("\(item.quantity)") // Display the quantity
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("\(item.daysUntilExpiration) days")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        //.padding(.vertical, 4)
                        .background((item.daysUntilExpiration <= 3 && item.daysUntilExpiration > 0) ? Color.dustyRose : Color.clear) // Highlight row if expiring in <= 3 days
                        .background(item.daysUntilExpiration <= 0 ? Color.red.opacity(0.8) : Color.clear) // Highlight row darker if already expired
                        .onLongPressGesture {
                            self.itemToDelete = item
                            self.showingDeleteConfirmation = true
                        }
                        Divider()
                    }
                }
                
            }
            .padding(.horizontal)
            
            // Overlay for enlarged image and additional details
            if let selectedItem = selectedItem {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        self.selectedItem = nil // Dismiss overlay
                    }
                
                VStack(spacing: 16) {
                    selectedItem.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.height * 0.4)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                    
                    VStack {
                        Text("Purchased: \(selectedItem.purchaseDate.formatted(date: .long, time: .omitted))")
                            .foregroundColor(.Beige.opacity(0.7))
                            .font(.headline)
                        
                        Text("Expires: \(selectedItem.expirationDate.formatted(date: .long, time: .omitted))")
                            .foregroundColor(.Beige.opacity(0.7))
                            .font(.headline)
                    }
                    .padding()
                    .background(Color.sageGreen.opacity(0.7))
                    .cornerRadius(10)
                }
                .padding()
                .transition(.scale)
                .onTapGesture {
                    self.selectedItem = nil // Also dismiss overlay when tapped
                }
            }
        }
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Delete Item"),
                message: Text("Are you sure you want to delete this item?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let itemToDelete = self.itemToDelete, let index = foodItems.firstIndex(of: itemToDelete) {
                        foodItems.remove(at: index)
                        self.itemToDelete = nil // Reset to nil after deletion
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    struct Message: Identifiable {
        let id = UUID()
        let text: String
        let isUserMessage: Bool // Determine if the message is from the user
    }
    
    struct ChatView: View {
        @State private var messages: [Message] = []
        @State private var inputText: String = ""
        
        var body: some View {
            VStack {
                ScrollView {
                    ScrollViewReader { scrollView in
                        VStack {
                            ForEach(messages) { message in
                                ChatBubble(isUserMessage: message.isUserMessage, text: message.text)
                                    .id(message.id) // Ensure you add this
                            }
                        }
                        .onAppear {
                            scrollView.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                .background(Color.Beige) // Set the ScrollView background to Beige
                
                
                
                HStack {
                    TextField("Type a message", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(minHeight: CGFloat(30))
                    
                    Button(action: {
                        sendMessage()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding(5)
                            .foregroundColor(Color.sageGreen) // Set the arrow icon color to sageGreen
                    }
                }
                .padding()
                
            }
            .background(Color.Beige.edgesIgnoringSafeArea(.all)) // Set the entire ChatView background to Beige
            .navigationBarTitle("Chat", displayMode: .inline)
        }
        
        private func sendMessage() {
            
            
            let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedText.isEmpty else { return }
            
            let message = Message(text: trimmedText, isUserMessage: true)
            messages.append(message)
            inputText = "" // Clear input field
        }
    }
    
    struct ChatBubble: View {
        let isUserMessage: Bool
        let text: String
        
        var body: some View {
            HStack {
                if isUserMessage { Spacer() }
                Text(text)
                    .padding()
                    .foregroundColor(isUserMessage ? .white : .black)
                    .background(isUserMessage ? Color.sageGreen : Color.Beige)
                    .cornerRadius(15)
                if !isUserMessage { Spacer() }
            }
        }
    }
    
    
    
    
    // MARK: - FoodItem Model
    struct FoodItem: Identifiable, Equatable {
        var id = UUID()
        var itemName: String
        var purchaseDate: Date
        var expirationDate: Date
        var image: Image = Image(systemName: "photo")
        var quantity: String // New quantity property
        
        var daysUntilExpiration: Int {
            let calendar = Calendar.current
            let startOfDayForNow = calendar.startOfDay(for: Date())
            let startOfDayForExpiration = calendar.startOfDay(for: expirationDate)
            let components = calendar.dateComponents([.day], from: startOfDayForNow, to: startOfDayForExpiration)
            return components.day ?? 0 // Returns 0 if for some reason it can't calculate
        }
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
                    .background(self.selectedIndex == index ? Color.sageGreen : Color.clear) // Highlight the background instead of border
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
        @State private var newItemQuantity: String = "" // State for new item quantity
        
        
        var body: some View {
            NavigationView {
                Form {
                    TextField("Item Name", text: $newItemName)
                        .focused($isItemNameFocused)
                        .onAppear {
                            self.isItemNameFocused = true
                        }
                    
                    TextField("Quantity", text: $newItemQuantity) // New TextField for quantity
                    
                    
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
                                .background(Color.sageGreen)
                                .foregroundColor(.Beige)
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
                                image: selectedImage ?? Image(systemName: "photo"),
                                quantity: newItemQuantity
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
        @Binding var pastPhotos: [Image] // Assuming this is your array of photos

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
                    .onDelete(perform: deletePhoto) // Enables swipe-to-delete functionality
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

        func deletePhoto(at offsets: IndexSet) {
            pastPhotos.remove(atOffsets: offsets) // Removes the photo at the swipe-to-delete action
        }
    }

    
    // MARK: - Preview Provider
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
