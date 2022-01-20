//
//  Model.swift
//  FindPictureFlickr
//
//  Created by Rita on 14.01.2022.
//

import Foundation

struct ApiModel: Decodable {
    let photos: Photos
}

struct Photos: Decodable {
    let photo: [Photo]
}

struct Photo: Decodable {
    let id: String?
    let owner: String?
    let secret: String?
    let server: String?
    let title: String?
    
}
