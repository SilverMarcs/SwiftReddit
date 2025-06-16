import Foundation

/// Media types for lightweight post display
enum LightweightMediaType: Hashable {
    case none
    case text
    case image(url: String)
    case gif(url: String)
    case video(url: String?)
    case youtube(url: String)
    case link(url: String)
    
    var hasVisualMedia: Bool {
        switch self {
        case .image, .gif, .video:
            return true
        default:
            return false
        }
    }
    
    var mediaURL: String? {
        switch self {
        case .image(let url), .gif(let url), .youtube(let url), .link(let url):
            return url
        case .video(let url):
            return url
        default:
            return nil
        }
    }
    
    var isVideo: Bool {
        if case .video = self {
            return true
        }
        return false
    }
    
    var isImage: Bool {
        if case .image = self {
            return true
        }
        return false
    }
    
    var isGif: Bool {
        if case .gif = self {
            return true
        }
        return false
    }
}
