//
//  BasketViewController.swift
//  ShoppingApp
//
//  Created by Bartu Gençcan on 30.10.2022.
//

import UIKit
import Kingfisher
import FirebaseFirestore

class BasketViewController: UIViewController, AlertPresentable {
    
    private let db = Firestore.firestore()
    
    private let viewModel: BasketViewModel
    
    private lazy var tableView = UITableView()
    
    private lazy var buyButton: UIButton = {
        let button = UIButton()
        // button.addTarget(self, action: #selector(didTapFinishAuthButton(_:)), for: .touchUpInside)
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 16
        return button
    }()
    
    private var isAnyProductAddedToBasket: Bool = true
    
    // MARK: - Init
    init(viewModel: BasketViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        tableView.register(BasketTableViewCell.self, forCellReuseIdentifier: "basketCell")
        buyButtonLayout()
        setupTableViewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableViewDelegate(self, andDataSource: self)
        
        view.backgroundColor = .white
        
        title = "Basket"
        
        NotificationCenter().addObserver(self,
                                         selector: #selector(self.didAnyProductAddedToBasket),
                                         name: NSNotification.Name("didAnyProductAddedToBasket"),
                                         object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isAnyProductAddedToBasket = true
        fetchProducts()
        
    }
    
    // MARK: - Methods
    private func fetchProducts() {
        if isAnyProductAddedToBasket {
            isAnyProductAddedToBasket = false
            
        }
        viewModel.fetchProducts { error in
            if let error = error {
                self.showError(error)
            } else {
                let totalSum: Double = self.viewModel.products.map({$0.price ?? 0}).reduce(0, +)
                let doubleStr = String(format: "%.2f", totalSum)
                self.buyButton.setTitle("Buy \(doubleStr) $", for: .normal)
                self.tableView.reloadData()
                print("reloaded")
            }
        }
        
        
    }
    
    @objc private func didAnyProductAddedToBasket() {
        isAnyProductAddedToBasket = true
    }
    
    // MARK: - Layout
    private func setupTableViewLayout(){
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(buyButton.snp.top).offset(-16.0)
            make.trailing.equalTo(view.snp.trailing)
        }
        
        tableView.rowHeight = 250
    }
    
    private func buyButtonLayout(){
        view.addSubview(buyButton)
        
        buyButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-32.0)
            make.leading.equalTo(64.0)
            make.trailing.equalTo(-64.0)
        }
    }
    
    //MARK: - TableView Configuration
    func setTableViewDelegate(_ delegate: UITableViewDelegate, andDataSource dataSource: UITableViewDataSource){
        tableView.delegate = delegate
        tableView.dataSource = dataSource
    }
}

// MARK: - Tableview Delegate
extension BasketViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let id = viewModel.products[indexPath.row].id,
                  let uid = UserDefaults.standard.string(forKey: "uid") else {fatalError("Product not found.")}
            
            let docRef = db.collection("users").document(uid)
            docRef.updateData([
                "basket": FieldValue.arrayRemove(["\(id)"])
            ])
            
            
//            viewModel.products.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - Tableview DataSource
extension BasketViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "basketCell", for: indexPath) as? BasketTableViewCell else {
            fatalError("Basket Cell not found.")
        }
        
        guard let product = viewModel.productForIndexPath(indexPath) else {
            fatalError("Product not found.")
        }
        
        cell.productTitle = "\(product.title?.maxLength(length: 32) ?? "")..."
        cell.productPrice = product.price
        cell.productImageView.kf.setImage(with: URL(string: "\(product.image ?? "")")) { _ in
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        return cell
    }
}
