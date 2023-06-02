//
//  FeedItem.swift
//  ProperDependencyInjection
//
//  Created by Tixsee on 6/2/23.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
