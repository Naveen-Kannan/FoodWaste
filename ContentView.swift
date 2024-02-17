import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isCameraPresented = false
    @State private var image: Image? = nil
    @State private var foodItems: [FoodItem] = []
    @State private var newItemName: String = ""
    @State private var newItemDate: String = ""
    @State private var newItemExpirationDate: String = ""

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
                        image?
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.90, height: geometry.size.height * 0.80)
                            .cornerRadius(10)
                        Button(action: {
                            isCameraPresented = true
                        }) {
                            Image(systemName: "camera")
                                .font(.largeTitle)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                }
                Spacer() // Add a spacer to fill the remaining space
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .sheet(isPresented: $isCameraPresented) {
                ImagePicker(sourceType: .camera, selectedImage: $image)
            }
        }
    }

    var rawInventoryScreen: some View {
        VStack {
            TextField("Item Name", text: $newItemName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            TextField("Date", text: $newItemDate)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            TextField("Expiration Date", text: $newItemExpirationDate)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Add Food Item") {
                let newItem = FoodItem(itemName: newItemName, date: newItemDate, expirationDate: newItemExpirationDate)
                foodItems.append(newItem)
                newItemName = ""
                newItemDate = ""
                newItemExpirationDate = ""
                hideKeyboard()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)

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
            .toolbar {
                EditButton()
            }
        }
        .onTapGesture {
            hideKeyboard()
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

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: Image?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = Image(uiImage: image)
            }

            picker.dismiss(animated: true)
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct FoodItem: Identifiable {
    var id = UUID()
    var itemName: String
    var date: String
    var expirationDate: String
}
