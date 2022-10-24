//
//  YYPageLayout.swift
//  新闻菜单
//
//  Created by 杨洋 on 2022/8/31.
//

import UIKit

struct YYPageLayout {
    /* pageView背景颜色 */
    var titleViewBgColor: UIColor = .white
    
    /* 标题颜色 */
    var titleColor: UIColor = UIColor.darkGray
    /* 标题选中颜色 */
    var titleSelectColor: UIColor = UIColor.black
    
    /* 标题字号 */
    var titleFont: UIFont = UIFont.systemFont(ofSize: 16)
    
    /* 标题缩放倍率 */
    var scale: Double = 1.12 //18/16
    
    /* 整个pageTitleView的高 */
    var sliderHeight: CGFloat = 50.0
        
    /* 标题直接的间隔（标题距离下一个标题的间隔）*/
    var titleMargin: CGFloat = 10.0
    
    /* 距离最左边和最右边的距离 */
    var lMargin: CGFloat = 16.0
    /* 距离最右边的距离 */
    var rMargin: CGFloat = 16.0
    
    /* 点击标题切换页面是否有动画 */
    var scrollAnimateWhenClickTitle: Bool = true
}
