//
//  ColorBackedImageView.swift
//  Registration
//
//  Created by Xinyuan_Wang on 2023/8/20.
//

import UIKit

class ColorBackedImageView: UIView {
    
    lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        NSLayoutConstraint.activate([
            self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.imageView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -20),
            self.imageView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -20)
        ])
    }
    
    var image: UIImage? {
        set {
            imageView.image = newValue
            imageView.layer.cornerRadius = imageView.bounds.size.width / 2.0
            imageView.layer.masksToBounds = true
            bringSubviewToFront(imageView)
        }
        get {
            imageView.image
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
