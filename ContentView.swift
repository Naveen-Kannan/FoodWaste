import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer().frame(height: geometry.size.height * 0.05)
                HStack {
                    Spacer()
                    Text("Centered View")
                        .padding()
                        .frame(width: geometry.size.width * 0.90, height: geometry.size.height * 0.80)
                        .background(Color.blue.opacity(0.5))
                        .cornerRadius(10)
                    Spacer()
                }
                Spacer().frame(height: geometry.size.height * 0.03)
                
                // Red rectangle with aligned images and text
                HStack {
                    Spacer() // Add a spacer for the left border
                    VStack {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                        Spacer().frame(height: 6) // Adjust the space between this image and text
                        Text("Raw\nInventory")
                            .font(.system(size: 14))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack {
                        Image(systemName: "book.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                        Spacer().frame(height: 18) // Adjust the space between this image and text
                        Text("Recipes")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                        Spacer().frame(height: 10) // Adjust the space between this image and text
                        Text("Waste\nReduction")
                            .font(.system(size: 14))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack {
                        Image(systemName: "message.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                        Spacer().frame(height: 18) // Adjust the space between this image and text
                        Text("Chat")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    Spacer() // Add a spacer for the right border
                }
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.2)
                .background(Color.red)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// Preview {
//     ContentView()
// }
