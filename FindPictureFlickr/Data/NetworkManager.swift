//
//  NetworkManager.swift
//  FindPictureFlickr
//
//  Created by Rita on 14.01.2022.
//

import UIKit

class NetworkManager {

    func fetchData(url: String, completion: @escaping (_ answer: [Photo], _ error: String?) -> ()) {

        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
                completion([Photo](), error.localizedDescription)
                return
            }
            guard let data = data else { return }

            do {
                let json = try JSONDecoder().decode(ApiModel.self, from: data)
                let photos = json.photos.photo
                completion(photos, nil)
            } catch let error {
                print("error json \(error)")
                completion([Photo](), error.localizedDescription)
            }

        }.resume()
    }
    
    var imageCache = NSCache<NSString, UIImage>()
    func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
        } else {
            let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 10)
            let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                
                guard error == nil,
                    data != nil,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let `self` = self else {
                        return
                }
                
                guard let image = UIImage(data: data!) else { return }
                self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            dataTask.resume()
        }
    }
}
