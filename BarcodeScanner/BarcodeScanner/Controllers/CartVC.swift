//
//  CartVC.swift
//  BarcodeScanner
//
//  Created by Brian Gomes on 20/10/2020.
//

import UIKit
import Kingfisher

class CartVC: UIViewController {

    @IBOutlet weak var ItemsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ItemsTableView.dataSource = self
        ItemsTableView.delegate = self
        ItemsTableView.register(UINib(nibName: "ItemsCell", bundle: nil), forCellReuseIdentifier: "itemsCell")
    }
    
    @IBAction func PayNowClicked(_ sender: Any) {
        
    }
}

extension CartVC:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.arrProductData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemsCell", for: indexPath) as! ItemsCell
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let data = appDelegate.arrProductData[indexPath.row]
        
        cell.productNameLbl.text = data["product_name"] as? String ?? ""
        if let arrStores = data["stores"] as? [[String:Any]], arrStores.count > 0{
            cell.productPriceLbl.text = arrStores[0]["store_price"] as? String ?? ""
        }
        
        if let arrImage = data["images"] as? [String], arrImage.count > 0 {
            if let url = URL(string: arrImage[0]){
                cell.productImage.kf.setImage(with: url)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

