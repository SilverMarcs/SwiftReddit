import Foundation
import SwiftUI

@Observable class VoteActionViewModel {
    var likes: Bool?
    var upsCount: Int {
        didSet {
            formattedUpsCount = upsCount.formatted
        }
    }
    var formattedUpsCount: String
    
    @ObservationIgnored private let id: String
    @ObservationIgnored private let targetType: VoteTargetType

    init<T: Votable>(item: T, targetType: VoteTargetType) {
        self.likes = item.likes
        self.upsCount = item.ups
        self.formattedUpsCount = item.ups.formatted
        self.id = item.fullname
        self.targetType = targetType
    }

    func vote(action: RedditAPI.VoteAction) {
        hapticFeedback()
        let initialLikes = likes
        let initialUpsCount = upsCount
        
        // Optimistically update the UI
        switch action {
        case .up:
            withAnimation {
                likes = (likes == true) ? nil : true
                upsCount += (likes == true) ? (initialLikes == nil ? 1 : -1) : -1
            }
        case .down:
            withAnimation {
                likes = (likes == false) ? nil : false
                upsCount += (likes == false) ? (initialLikes == nil ? -1 : 1) : 1
            }
        case .none:
            break
        }
        
        Task {
            let success: Bool?
            switch targetType {
            case .post:
                success = await RedditAPI.vote(action, id: id)
            case .comment:
                success = await RedditAPI.voteComment(action, id: id)
            }
            if success != true {
                likes = initialLikes
                upsCount = initialUpsCount
            }
        }
    }

    private func hapticFeedback() {
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
        #endif
    }
}

protocol Votable {
    var likes: Bool? { get }
    var ups: Int { get }
    var fullname: String { get }
}

enum VoteTargetType {
    case post
    case comment
}
