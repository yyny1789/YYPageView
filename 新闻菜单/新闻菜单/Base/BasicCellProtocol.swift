//
//  ListTableViewCellProtocol.swift
//  Client
//
//  Created by paul on 15/12/8.
//  Copyright © 2015年 36Kr. All rights reserved.
//

import UIKit

protocol BasicCellProtocol {
    
}

extension BasicCellProtocol {
    
    static var cellIdentifier: String {
        return String(describing: self)
    }
    
    static var cellNib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
}

extension UITableViewCell: BasicCellProtocol {
    
}

extension UITableViewHeaderFooterView: BasicCellProtocol {

}

extension UICollectionReusableView: BasicCellProtocol {
    
}

extension UIView {
    
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
}
