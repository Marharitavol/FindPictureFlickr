//
//  TableViewCell.swift
//  FindPictureFlickr
//
//  Created by Rita on 13.01.2022.
//

import UIKit
import SnapKit

class TableViewCell: UITableViewCell {

    static let identifierCell = String(describing: ViewController.self)
    
    let nameLabel = UILabel()
    var foundedImage = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: TableViewCell.identifierCell)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let screenWidth = UIScreen.main.bounds.width
        
        contentView.addSubview(nameLabel)
        nameLabel.text = "cat"
        nameLabel.textAlignment = .center
        nameLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(screenWidth / 4.5)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(foundedImage)
//        foundedImage.image = UIImage(named: "qwe")
        foundedImage.snp.makeConstraints { (make) in
            make.leading.bottom.top.equalToSuperview()
            make.width.equalTo(screenWidth / 2)
        }
    }
}
