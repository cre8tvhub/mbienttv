import SwiftUI
import AVKit
import Foundation

// MARK: - Content View
struct ContentView: View {
    @StateObject private var collectionManager = CollectionManager()
    @FocusState private var focusedLink: String?
    @State private var selectedChannel: TVChannel?
    @StateObject private var parser = M3UParser()
    @State private var selectedTab: TopMenu?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    func tabIcon(for menuItem: TopMenu) -> String {
        switch menuItem.name {
        case "Settings": return "gear"
        case "News": return "newspaper"
        default: return "text.alignleft"
        }
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                BlogGridView()
                    .tabItem {
                        Label("News", systemImage: "newspaper")
                    }
                    .tag(TopMenu(name: "News", url: "", order: 0))  // Add order parameter
                
                ForEach(collectionManager.menuItems) { tab in
                    if tab.name == "Settings" {
                        SettingsView()
                            .environmentObject(collectionManager)
                            .tabItem {
                                Label(tab.name, systemImage: tabIcon(for: tab))
                            }
                            .tag(tab)
                    } else {
                        VStack {
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 40) {
                                    ForEach(parser.streams) { stream in
                                        switch stream {
                                        case .channel(let streamLink, let title, let logo):
                                            VStack {
                                                ChannelView(StreamURL: streamLink,
                                                          StreamTitle: title,
                                                          StreamImage: logo,
                                                          isFocused: $focusedLink.wrappedValue == title)
                                                    .hoverEffect(.highlight)
                                                    .focusable(true)
                                                    .focused($focusedLink, equals: title)
                                                    .onTapGesture {
                                                        selectedChannel = TVChannel(title: title,
                                                                                 StreamURL: streamLink,
                                                                                 Image: logo)
                                                    }
                                                
                                                Text(title)
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .background(Color.clear)
                                                    .padding(.top, 10)
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.center)
                                            }
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                        .tabItem {
                            Label(tab.name, systemImage: tabIcon(for: tab))
                        }
                        .tag(tab)
                    }
                }
            }
            .onChange(of: selectedTab) {
                if let tab = selectedTab, tab.name != "Settings" && tab.name != "News" {
                    print("Loading M3U from URL: \(tab.url)")
                    parser.fetchAndParseM3U(url: tab.url)
                }
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedChannel != nil },
                set: { if !$0 { selectedChannel = nil } }
            )) {
                if let channel = selectedChannel {
                    ShowStream(tvChannel: channel)
                }
            }
        }
        .onAppear {
            if selectedTab == nil {
                selectedTab = TopMenu(name: "News", url: "", order: 0)  // Add order parameter
            }
            if let firstMenu = collectionManager.menuItems.first(where: { $0.name != "Settings" && $0.name != "News" }) {
                parser.fetchAndParseM3U(url: firstMenu.url)
            }
        }
    }
}

struct PostsView: View {
    var body: some View {
        VStack {
            Text("News Feed")
                .font(.title)
            // Add your posts view content here
        }
    }
}

// MARK: - Channel Models and Views
struct TVChannel: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let StreamURL: String
    let Image: String
    
    static func == (lhs: TVChannel, rhs: TVChannel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ChannelView: View {
    var StreamURL: String
    var StreamTitle: String
    var StreamImage: String
    var isFocused: Bool
    
    @State private var shouldShowVideo: Bool = false
    @State private var focusTimer: Timer?
    
    var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .aspectRatio(16/9, contentMode: .fill)
                .frame(width: 426, height: 240)
            
            if shouldShowVideo && isFocused {
                VideoPlayerView(StreamURL: StreamURL,
                              StreamTitle: StreamTitle,
                              StreamImage: StreamImage,
                              isFocused: isFocused)
                    .frame(width: 426, height: 240)
                    .hoverEffect(.highlight)
            } else {
                AsyncImage(url: URL(string: StreamImage)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fit)
                    case .failure:
                        Text(StreamTitle)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 426, height: 240)
            }
        }
        .onChange(of: isFocused) { oldValue, newValue in
            if newValue {
                // Start timer when focus is gained
                focusTimer?.invalidate()
                focusTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                    shouldShowVideo = true
                }
            } else {
                // Cancel timer and hide video when focus is lost
                focusTimer?.invalidate()
                focusTimer = nil
                shouldShowVideo = false
            }
        }
        .onDisappear {
            // Cleanup timer when view disappears
            focusTimer?.invalidate()
            focusTimer = nil
        }
    }
}

struct VideoPlayerView: View {
    var StreamURL: String
    var StreamTitle: String
    var StreamImage: String
    @State private var player: AVPlayer
    @State private var isPlaying = false
    var isFocused: Bool
    
    init(StreamURL: String, StreamTitle: String, StreamImage: String, isFocused: Bool) {
        self.StreamURL = StreamURL
        self.StreamTitle = StreamTitle
        self._player = State(initialValue: AVPlayer(url: URL(string: StreamURL)!))
        self.isFocused = isFocused
        self.StreamImage = StreamImage
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .aspectRatio(16/9, contentMode: .fill)
                .frame(width: 426, height: 240)
            
            if isFocused {
                
                VideoPlayer(player: player)
                    .onAppear {
                        print(StreamTitle + " Appeared")
                        player.play()
                        isPlaying = true
                    }
                    .onDisappear {
                        print(StreamTitle + " Disappeared")
                        if !isPlaying { return }
                        player.pause()
                        isPlaying = false
                    }
                    .onChange(of: isFocused) {
                        print(StreamTitle + " Focus Changed")
                        if isFocused {
                            player.play()
                            isPlaying = true
                        } else {
                            player.pause()
                            isPlaying = false
                        }
                    }
                    .frame(width: 426, height: 240)
                    .hoverEffect(.highlight)
            } else {
                
                AsyncImage(url: URL(string: StreamImage)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fit)
                    case .failure:
                        Text(StreamTitle)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 426, height: 240)
                .onAppear {
                print(StreamTitle + " Disappeared")
            }
            }
        }
    }
}

struct ShowStream: View {
    var tvChannel: TVChannel
    @State private var player: AVPlayer
    
    init(tvChannel: TVChannel) {
        self.tvChannel = tvChannel
        self._player = State(initialValue: AVPlayer(url: URL(string: tvChannel.StreamURL)!))
    }
    
    var body: some View {
        ZStack {
            VideoPlayer(player: player)
                .onAppear { player.play() }
                .onDisappear {
                    player.pause()
                    player.replaceCurrentItem(with: nil)
                }
                .edgesIgnoringSafeArea(.all)
        }
        .navigationBarBackButtonHidden(true)
    }
}
