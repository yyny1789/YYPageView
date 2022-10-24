//
//  YYPageTitleView.swift
//  新闻菜单
//
//  Created by 杨洋 on 2022/8/31.
//

import UIKit

protocol YYPageTitleViewDelegate: AnyObject {
    func didSelectTitleAt(_ index: Int)
}

class YYPageTitleView: UIView {

    weak var delegate: YYPageTitleViewDelegate?
    
    fileprivate var titles: [String] = []
    fileprivate var selectIndex = 0
    fileprivate var scrollView = UIScrollView()
    fileprivate var layout = YYPageLayout()
    fileprivate var textWidths: [CGFloat] = []
    fileprivate var buttons: [UIButton] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    init(_ frame: CGRect, titles: [String], layout: YYPageLayout, index: Int) {
        super.init(frame: frame)
        self.titles = titles
        self.layout = layout
        self.selectIndex = index
        configSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func configSubViews() {
        backgroundColor = layout.titleViewBgColor
        addSubview(scrollView)
//        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.frame = bounds
        scrollView.showsHorizontalScrollIndicator = false
                
        setupButtonsLayout()
    }

    fileprivate func setupButtonsLayout() {
        guard !titles.isEmpty else { return }
    
        // 将所有的宽度计算出来放入数组
        for title in titles {
            if title.count == 0 {
                textWidths.append(60)
                continue
            }
            let textW = title.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 8), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: layout.titleFont], context: nil).size.width
            textWidths.append(textW)
        }
        
        // 按钮布局
        var upX: CGFloat = layout.lMargin
        let subH = bounds.height
        for index in 0..<titles.count {
            let subW = textWidths[index]
            let buttonRect = CGRect(x: upX, y: 0, width: subW, height: subH)
            let button = UIButton(type: .custom)
            button.frame = buttonRect
            button.tag = index
            button.setTitle(titles[index], for: .normal)
            button.addTarget(self, action: #selector(titleSelectIndex(_:)), for: .touchUpInside)
            button.titleLabel?.font = layout.titleFont
            button.setTitleColor(layout.titleColor, for: .normal)
            scrollView.addSubview(button)
            buttons.append(button)
            
            upX = button.frame.origin.x + subW + layout.titleMargin
        }
        
        // 计算scrollView的contentSize
        // 最后多加了一个 layout.titleMargin， 这里要减去
        let contenSizeW = upX - layout.titleMargin + layout.lMargin + layout.rMargin
        scrollView.contentSize = CGSize(width: contenSizeW, height: subH)
        let btn = buttons[selectIndex]
        btn.transform = CGAffineTransform(scaleX: self.layout.scale, y: self.layout.scale)
        btn.setTitleColor(layout.titleSelectColor, for: .normal)
        self.setupSlierScrollToCenter(offsetX: self.scrollView.contentOffset.x, index: selectIndex, animated: false)
    }
    
    @objc fileprivate func titleSelectIndex(_ btn: UIButton)  {
        delegate?.didSelectTitleAt(btn.tag)
    }
    
    func updateData(_ titles: [String], index: Int) {
        if titles.isEmpty {
            return
        }
        for btn in buttons {
            btn.removeFromSuperview()
        }
        buttons.removeAll()
        textWidths.removeAll()
        
        self.titles = titles
        self.selectIndex = index
        setupButtonsLayout()
    }
    
    func scrollToIndex(_ index: Int) {
//        debugPrint("-----YYPageTitleView scrollToIndex:\(index)")
        let lastSelectBtn = buttons[selectIndex]
        let selectBtn = buttons[index]
        
        UIView.animate(withDuration: 0.25) {
            lastSelectBtn.transform = CGAffineTransform.identity
            lastSelectBtn.setTitleColor(self.layout.titleColor, for: .normal)
            
            selectBtn.transform = CGAffineTransform(scaleX: self.layout.scale, y: self.layout.scale)
            selectBtn.setTitleColor(self.layout.titleSelectColor, for: .normal)
        } completion: { _ in
            self.selectIndex = index
            self.setupSlierScrollToCenter(offsetX: self.scrollView.contentOffset.x, index: index, animated: true)
        }
    }
    
    fileprivate func setupSlierScrollToCenter(offsetX: CGFloat, index: Int, animated: Bool)  {
        if scrollView.contentSize.width <= scrollView.frame.size.width {
            return
        }
        let currentButton = buttons[index]
        let btnCenterX = currentButton.center.x
        var scrollX = btnCenterX - scrollView.bounds.width * 0.5
        if scrollX < 0 {
            scrollX = 0
        }
        if scrollX > scrollView.contentSize.width - scrollView.bounds.width {
            scrollX = scrollView.contentSize.width - scrollView.bounds.width
        }
        scrollView.setContentOffset(CGPoint(x: scrollX, y: 0), animated: animated)
    }
    
}
