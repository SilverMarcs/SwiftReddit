//import SwiftUI
//
//struct LightweightPostView: View {
//    let post: LightweightPost
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            // Header
//            VStack(alignment: .leading, spacing: 4) {
//                Text(post.title)
//                    .font(.headline)
//                    .lineLimit(3)
//                
//                HStack {
//                    Text("r/\(post.subreddit)")
//                        .font(.caption)
//                        .foregroundColor(.blue)
//                    
//                    Text("•")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    
//                    Text("u/\(post.author)")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    
//                    Text("•")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    
//                    Text(timeAgoString(from: post.created))
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    
//                    Spacer()
//                    
//                    if post.isNSFW {
//                        Text("NSFW")
//                            .font(.caption2)
//                            .padding(.horizontal, 6)
//                            .padding(.vertical, 2)
//                            .background(Color.red)
//                            .foregroundColor(.white)
//                            .cornerRadius(4)
//                    }
//                    
//                    if post.stickied {
//                        Image(systemName: "pin.fill")
//                            .font(.caption)
//                            .foregroundColor(.green)
//                    }
//                    
//                    if post.locked {
//                        Image(systemName: "lock.fill")
//                            .font(.caption)
//                            .foregroundColor(.orange)
//                    }
//                }
//            }
//            
//            // Self text preview
//            if let selftext = post.selftext, !selftext.isEmpty {
//                Text(selftext)
//                    .font(.body)
//                    .lineLimit(3)
//                    .foregroundColor(.primary)
//            }
//            
//            // Media
//            LightweightMediaView(mediaType: post.mediaType, preview: post.preview)
//            
//            // Footer
//            HStack {
//                HStack(spacing: 4) {
//                    Image(systemName: "arrow.up")
//                        .font(.caption)
//                    Text("\(post.score)")
//                        .font(.caption)
//                    Image(systemName: "arrow.down")
//                        .font(.caption)
//                }
//                .foregroundColor(.secondary)
//                
//                Spacer()
//                
//                HStack(spacing: 4) {
//                    Image(systemName: "bubble.left")
//                        .font(.caption)
//                    Text("\(post.numComments)")
//                        .font(.caption)
//                }
//                .foregroundColor(.secondary)
//                
//                Spacer()
//                
//                HStack(spacing: 4) {
//                    Image(systemName: "square.and.arrow.up")
//                        .font(.caption)
//                    Text("Share")
//                        .font(.caption)
//                }
//                .foregroundColor(.secondary)
//            }
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(12)
//        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
//    }
//    
//    private func timeAgoString(from date: Date) -> String {
//        let now = Date()
//        let interval = now.timeIntervalSince(date)
//        
//        if interval < 60 {
//            return "now"
//        } else if interval < 3600 {
//            let minutes = Int(interval / 60)
//            return "\(minutes)m"
//        } else if interval < 86400 {
//            let hours = Int(interval / 3600)
//            return "\(hours)h"
//        } else {
//            let days = Int(interval / 86400)
//            return "\(days)d"
//        }
//    }
//}
