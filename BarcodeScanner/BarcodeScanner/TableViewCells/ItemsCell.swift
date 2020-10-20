//
//  ItemsCell.swift
//  BarcodeScanner
//
//  Created by Brian Gomes on 20/10/2020.
//

import UIKit

class ItemsCell: UITableViewCell {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productNameLbl: UILabel!
    @IBOutlet weak var productPriceLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func closeButton(_ sender: UIButton) {
        
    }
    
}
