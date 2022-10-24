//
//  TestViewController.swift
//  新闻菜单
//
//  Created by Yangyang on 2022/10/19.
//

import UIKit

class TestViewController: UIViewController {

    var track: TrackEntity?
    
    var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.red
        
        titleLabel.text = title
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: view.frame.size.width / 2, y: 100)
        self.view.addSubview(titleLabel)
    }


}
