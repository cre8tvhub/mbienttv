
import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - Data Models
struct BlogPost: Identifiable, Decodable {
    let id: String
    let title: String
    let excerpt: String
    let firstPublishedDate: String
    let slug: String
    let coverMedia: CoverMedia?
    
    struct CoverMedia: Decodable {
        let image: ImageDetails?
        
        struct ImageDetails: Decodable {
            let url: String
        }
    }
}

struct BlogResponse: Decodable {
    let posts: [BlogPost]
    let metaData: MetaData
    
    struct MetaData: Decodable {
        let count: Int
        let offset: Int
        let total: Int
    }
}

// MARK: - QR Code Popup
struct QRCodePopup: View {
    let url: String
    @Binding var isPresented: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Text("Scan QR Code")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Image(uiImage: generateQRCode(from: url))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 600, height: 600)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Text("Press Menu button to dismiss")
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            .padding(40)
        }
        .focusable()
        .focused($isFocused)
        .onAppear { isFocused = true }
        .onExitCommand(perform: dismiss)
        .onMoveCommand { _ in dismiss() }
        .onPlayPauseCommand(perform: dismiss)
        .highPriorityGesture(
            TapGesture()
                .onEnded { _ in
                    dismiss()
                }
        )
    }
    
    private func dismiss() {
        isPresented = false
    }
    
    private func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = string.data(using: .ascii)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 20, y: 20)
            let scaledImage = outputImage.transformed(by: transform)
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

// MARK: - Card Button Style
struct CardButtonStyle: ButtonStyle {
    @Environment(\.isFocused) private var isFocused
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : isFocused ? 1.05 : 1.0)
            .brightness(isFocused ? 0.2 : 0)
            //.shadow(color: isFocused ? .white : .clear, radius: isFocused ? 10 : 0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.2), value: isFocused)

    }
}

// MARK: - Post Card View
struct PostCard: View {
    let post: BlogPost
    let action: () -> Void
    
    var imageUrl: URL? {
        guard let urlString = post.coverMedia?.image?.url else { return nil }
        return URL(string: urlString)
    }
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: post.firstPublishedDate) {
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: date)
        }
        return ""
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(post.title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(Color.secondary.opacity(0))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(CardButtonStyle())
    }
}


// MARK: - Blog Grid View
struct BlogGridView: View {
    @StateObject private var settingsManager = SettingsManager()
    @State private var posts: [BlogPost] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State private var selectedPostURL: String?
    @State private var showQRCode = false
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 40), count: 4)
    private let accountId = "42a8ecb0-909f-4eab-9a67-1c8efc7860cd"
    private let siteId = "3a8afbcc-7433-431f-8fef-50a3152e5db6"

    var body: some View {
        ZStack {
            ScrollView {
                if isLoading {
                    ProgressView()
                        .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 40) {
                        ForEach(posts) { post in
                            PostCard(post: post) {
                                selectedPostURL = "https://www.mindlab.news/post/\(post.slug)"
                                showQRCode = true
                            }
                        }
                    }
                    .padding(40)
                }
            }
            
            if showQRCode, let url = selectedPostURL {
                QRCodePopup(url: url, isPresented: $showQRCode)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: showQRCode)
        .task {
            await fetchPosts()
        }
    }
    
    private func fetchPosts() async {
            isLoading = true
            
            guard var urlComponents = URLComponents(string: "https://www.wixapis.com/v3/posts") else {
                return
            }
            
            urlComponents.queryItems = [
                URLQueryItem(name: "paging.limit", value: "36"),
                URLQueryItem(name: "sort", value: "PUBLISHED_DATE_DESC")
            ]
            
            guard let url = urlComponents.url else { return }
            
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Bearer \(settingsManager.settings.authorizationCode)", forHTTPHeaderField: "Authorization")
            request.addValue(accountId, forHTTPHeaderField: "wix-account-id")
            request.addValue(siteId, forHTTPHeaderField: "wix-site-id")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(BlogResponse.self, from: data)
            posts = response.posts
        } catch {
            self.error = error
            print("Error fetching posts: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}
