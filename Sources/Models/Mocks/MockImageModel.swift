//
//  MockImageModel.swift
//  ZoomImageView
//
//  Created by amolonus on 26/03/2025.
//
import Foundation

struct MockImageModel {
    var url: URL
}

extension MockImageModel {
    static let landscapeImage: URL = URL(string: "https://images.unsplash.com/photo-1731877908315-7f1aa7095d3d?q=80&w=3936&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D.jpg")!
    static let portraitImage: URL = URL(string: "https://images.unsplash.com/photo-1740609500215-dec1bf128af8?q=80&w=3998&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D.jpg")!
}
