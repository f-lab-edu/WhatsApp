//
//  ChannelListService.swift
//  whatsapp
//
//  Created by 김수아 on 2/4/24.
//

import Foundation
import WANetworkAPI
import WAFoundation

protocol ChannelListServiceable{
    func requestChannels() async throws -> [Channel]
}

struct ChannelListService: ChannelListServiceable{
    func requestChannels() async throws -> [Channel] {
        let channelRequest = NetworkAPI.Channel.GetAll.Request()
        let channels: [NetworkAPI.Channel.GetAll.Response] = try await NetworkAPI.Channel.request(.getAll(channelRequest))
        let extraInfos = try await channels.asyncMap{ (channel) -> ExtraInfo in
            let userResponse: NetworkAPI.User.GetAll.Response? = try await { [channel] in
                let request = NetworkAPI.User.GetAll.Request(perPage: 1, inChannel: channel.id)
                let responses: [NetworkAPI.User.GetAll.Response] = try await NetworkAPI.User.request(.getAll(request))
                return responses.first
            }()
            let unreadMessageResponse = { [channel] (userId: String) in
                let request = NetworkAPI.User.GetUnreadMessages.Request(userId: userId, channel_id: channel.id)
                let response: NetworkAPI.User.GetUnreadMessages.Response = try await NetworkAPI.User.request(.getUnreadMessages(request))
                return response
            }
            let statusResponse = { (userId: String) in
                let request = NetworkAPI.User.GetStatus.Request(userId: userId)
                let response: NetworkAPI.User.GetStatus.Response = try await NetworkAPI.User.request(.getStatus(request))
                return response
            }
            let lastPostResponse = try await { [channel] in
                let request = NetworkAPI.Post.GetForChannel.Request(channelId: channel.id, perPage: 1)
                let response: NetworkAPI.Post.GetForChannel.Response = try await NetworkAPI.Post.request(.getForChannel(request))
                return response.order.first.compactMap{ [response] in response.posts[$0] }
            }()
    
            return (
                try await UserDefault.user.map{ try await unreadMessageResponse($0.id) },
                userResponse,
                try await userResponse.map{ try await statusResponse($0.id) },
                lastPostResponse
            )
        }
        return channels.enumerated().map{ (index, channel) in
            let (unreadMessage, sender, senderStatus, lastPost) = extraInfos[index]
            return Channel(
                id: channel.id,
                isActiveUser: senderStatus?.status == .online,
                senderProfileURL: sender.compactMap{ URL(string: "http://118.67.134.127:8065/api/v4/users/\($0.id)/image") },
                senderName: sender?.username ?? "",
                lastMessage: lastPost?.message ?? "",
                lastMessageSentAt: Date.init(timeIntervalSince1970: TimeInterval(channel.lastPostedAt / 1_000)),
                unreadMessageCount: unreadMessage?.messageCount ?? 0
            )
        }
    }
    
    // MARK: - Private
    private typealias ExtraInfo = (
        NetworkAPI.User.GetUnreadMessages.Response?,
        NetworkAPI.User.GetAll.Response?,
        NetworkAPI.User.GetStatus.Response?,
        NetworkAPI.Post.GetForChannel.Response.Post?
    )
}
