//
//  ViewController.swift
//  FindPictureFlickr
//
//  Created by Rita on 13.01.2022.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    var text = ""
    var searchUrl = ""
    var photo = [Photo]()
    var saveModel = [SaveModel]()
    
    let networkManager = NetworkManager()
    let searchBar = UISearchBar()
    
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        
        setupTableView()
        searchApi()
//        json()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifierCell)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.trailing.leading.bottom.equalToSuperview()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifierCell) as! TableViewCell
        cell.nameLabel.text = searchBar.text
        
        let imageModel = photo[indexPath.row]
        let urlString = "https://live.staticflickr.com/\(imageModel.server!)/\(imageModel.id!)_\(imageModel.secret!).jpg"
        let url = URL(string: urlString)!

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchApi()
    }
    
    func searchApi() {
        
        text = searchBar.text!.lowercased()
        let base = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
        let apiKey = "&api_key=b4ef8a0cd0da6dfa19aa2bef0d151bba"
        let format = "&format=json&nojsoncallback=1"
        let formattedText = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let textToSearch = "&text=\(formattedText)"
        let sort = "&sort=relevance"
        
        searchUrl = base + apiKey + textToSearch + sort + format;
        print("\(searchUrl)")
        
        networkManager.fetchData(url: searchUrl) { (photo) in
            guard let firstElement = photo.first else { return }
            self.photo.append(firstElement)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
