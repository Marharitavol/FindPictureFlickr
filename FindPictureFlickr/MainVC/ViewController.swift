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
    var pictureUrl = ""
    var saveModels = [SaveModel]()
    let realmManager = RealmManager()
    let realmModel = RealmModel()
    
    
    let networkManager = NetworkManager()
    let searchBar = UISearchBar()
    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        setupScreen()
        
        realmManager.fetchHistory { [weak self] (array) in
            array?.forEach({ [weak self] (realmModel) in
                guard let url = URL(string: realmModel.urlImage) else { return }
                self?.networkManager.downloadImage(url: url) { [weak self] (image) in
                    let saveModel = SaveModel(savedImage: image ?? UIImage(), savedText: realmModel.title, urlImage: realmModel.urlImage)
                    self?.saveModels.insert(saveModel, at: 0)
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            })
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func setupScreen() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifierCell)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(37)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return saveModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifierCell) as! TableViewCell
        let imageModel = saveModels[indexPath.row]
        
        cell.nameLabel.text = imageModel.savedText
        cell.foundedImage.image = imageModel.savedImage
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            let realmModel = RealmModel(title: saveModels[indexPath.row].savedText, urlImage: saveModels[indexPath.row].urlImage)
            saveModels.remove(at: indexPath.row)
            
            realmManager.deletePicture(realmModel)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
    func showError() {
        
        let alert = UIAlertController(title: nil, message: "Image not found", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
        
    }

    
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchApi()
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
        searchBar.text = ""
        
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
        
        networkManager.fetchData(url: searchUrl) { (photo, error)  in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.showError()
                    self.activityIndicatorView.isHidden = true
                    self.activityIndicatorView.stopAnimating()
                }
                return }
            guard let firstElement = photo.first else { return }
            self.pictureUrl = "https://live.staticflickr.com/\(firstElement.server!)/\(firstElement.id!)_\(firstElement.secret!).jpg"
            
            self.realmManager.saveHistory(RealmModel(title: self.text, urlImage: self.pictureUrl))
            
            let url = URL(string: self.pictureUrl)!
            self.networkManager.downloadImage(url: url) { image in
                let saveModel = SaveModel(savedImage: image ?? UIImage(), savedText: self.text, urlImage: self.pictureUrl)
                self.saveModels.insert(saveModel, at: 0)
                DispatchQueue.main.async {
                    self.activityIndicatorView.isHidden = true
                    self.activityIndicatorView.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        }
    }
}
