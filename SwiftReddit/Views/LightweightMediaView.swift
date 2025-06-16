import SwiftUI

struct LightweightMediaView: View {
    let mediaType: LightweightMediaType
    let preview: String?
    
    var body: some View {
        switch mediaType {
        case .none:
            EmptyView()
            
        case .text:
            EmptyView()
            
        case .image(let url):
            AsyncImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        ProgressView()
                    )
            }
            .frame(maxHeight: 400)
            .clipped()
            
        case .gif(let url):
            AsyncImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            ProgressView()
                            Text("Loading GIF...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            }
            .frame(maxHeight: 400)
            .clipped()
            
        case .video(let url):
            if let urlString = url {
                VStack {
                    Rectangle()
                        .fill(Color.black.opacity(0.8))
                        .frame(height: 200)
                        .overlay(
                            VStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                Text("Video")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            }
                        )
                    
                    Text("Video URL: \(urlString)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 100)
                    .overlay(
                        Text("Video unavailable")
                            .foregroundColor(.secondary)
                    )
            }
            
        case .youtube(let url):
            VStack {
                Rectangle()
                    .fill(Color.red.opacity(0.8))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "play.rectangle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            Text("YouTube Video")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    )
                
                Text("YouTube: \(url)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
        case .link(let url):
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "link")
                        .foregroundColor(.blue)
                    Text("External Link")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                Text(url)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
    }
}
