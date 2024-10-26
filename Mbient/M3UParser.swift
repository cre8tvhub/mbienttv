import SwiftUI


class M3UParser: ObservableObject {
    @Published var streams: [StreamInfo] = []
    
    func fetchAndParseM3U(url: String) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching M3U file: \(error)")
                return
            }
            
            guard let data = data, let content = String(data: data, encoding: .utf8) else {
                print("Invalid data")
                return
            }
            
            self.parseM3UContent(content)
        }.resume()
    }
    
    private func parseM3UContent(_ content: String) {
        let lines = content.components(separatedBy: .newlines)
        var currentTitle = ""
        var currentLogo = ""
        
        DispatchQueue.main.async {
            self.streams.removeAll()
        }
        
        for line in lines {
            if line.starts(with: "#EXTINF:") {
                let components = line.components(separatedBy: ",")
                if components.count > 1 {
                    currentTitle = components[1].trimmingCharacters(in: .whitespaces)
                }
                
                if let logoRange = line.range(of: "tvg-logo=\""),
                   let endRange = line.range(of: "\"", range: logoRange.upperBound..<line.endIndex) {
                    currentLogo = String(line[logoRange.upperBound..<endRange.lowerBound])
                    // Remove query parameters from the logo URL
                    if let urlComponents = URLComponents(string: currentLogo) {
                        currentLogo = urlComponents.url?.absoluteString ?? currentLogo
                    }
                }
                
                // Check if logo is empty and generate fallback URL
                print ("Title: " + currentTitle + " Logo: " + currentLogo)
                if currentLogo.isEmpty && !currentTitle.isEmpty {
                    // Replace spaces with underscores and add .png extension
                    let formattedTitle = currentTitle.replacingOccurrences(of: " ", with: "_")
                    currentLogo = "http://192.168.128.177:8069/\(formattedTitle).png"
                    print ("Logo Revised: " + currentLogo)
                }
            } else if line.hasPrefix("http") {
                let streamLink = line.trimmingCharacters(in: .whitespaces)
                let stream = StreamInfo.channel(streamLink: streamLink, title: currentTitle, logo: currentLogo)
                DispatchQueue.main.async {
                    self.streams.append(stream)
                }
                currentTitle = ""
                currentLogo = ""
            }
        }
    }
}

enum StreamInfo: Identifiable {
    case channel(streamLink: String, title: String, logo: String)
    
    var id: String {
        switch self {
        case .channel(let streamLink, _, _):
            return streamLink
        }
    }
}
