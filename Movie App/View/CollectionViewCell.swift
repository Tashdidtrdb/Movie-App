//
//  CollectionViewCell.swift
//  Movie App
//
//  Created by BS198 on 28/1/22.
//

import UIKit
import SDWebImage

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(with movie: Movie) {
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imageView.sd_setImage(with: URL(string: movie.posterURL), placeholderImage: UIImage(named: "photo"))
    }
}

extension CollectionViewCell: ScrollViewDelegate {
    static let identifier = "CollectionViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}

@IBDesignable extension CollectionViewCell {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = (newValue > 0)
        }
    }
}
