//
//  ProductsCollectionViewCell.swift
//  ShoppingApp
//
//  Created by Bartu Gençcan on 30.10.2022.
//

import UIKit
import Cosmos
import Lottie

class ProductsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var price: Double? {
        didSet {
            priceLabel.text = "\(price ?? 0) $"
        }
    }
    
    var rating: Double? {
        didSet {
            cosmosView.rating = rating ?? 0
        }
    }
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        layer.locations = [0.0, 1.0]
        return layer
    }()
    
    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8.0
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.textColor = .white
        label.numberOfLines = .zero
        return label
    }()
    
    private lazy var cosmosView: CosmosView = {
        let view = CosmosView()
        view.settings.updateOnTouch = false
        view.settings.starSize = 15
        view.settings.fillMode = .precise
        return view
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12.0)
        label.textColor = .white
        label.numberOfLines = .zero
        return label
    }()
    
    // MARK: - Inşt
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layout()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    
    // MARK: - Layout
    
    private func layout() {
        
        self.addSubview(self.imageView)
        
        self.imageView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        self.imageView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.imageView.snp.leading).offset(8.0)
            make.bottom.equalTo(self.imageView.snp.bottom).offset(-24.0)
        }
        
        self.imageView.addSubview(self.cosmosView)
        self.cosmosView.snp.makeConstraints { make in
            make.leading.equalTo(self.imageView.snp.leading).offset(8.0)
            make.bottom.equalTo(self.imageView.snp.bottom).offset(-8.0)
        }
        
        self.imageView.addSubview(self.priceLabel)
        self.priceLabel.snp.makeConstraints { make in
            make.trailing.equalTo(self.imageView.snp.trailing).offset(-8.0)
            make.bottom.equalTo(self.imageView.snp.bottom).offset(-8.0)
        }
        
        self.imageView.layer.insertSublayer(self.gradientLayer, at: .zero)
        
        
    }
}
