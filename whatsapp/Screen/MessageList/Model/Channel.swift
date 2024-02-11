//
//  Channel.swift
//  whatsapp
//
//  Created by 김수아 on 1/21/24.
//

import Foundation
import WANetworkAPI

struct Channel: Equatable, Identifiable{
    let id: String
    let isActiveUser: Bool
    let senderProfileURL: URL?
    let senderName: String
    let lastMessage: String
    let lastMessageSentAt: Date
    let unreadMessageCount: Int
}
