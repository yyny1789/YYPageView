//
//  YYPageView.swift
//  新闻菜单
//
//  Created by 杨洋 on 2022/8/31.
//

import UIKit

@objc public protocol YYPageViewDelegate: AnyObject {
    @objc optional func didMoveToPage(_ page: Int)
}

class YYPageView: UIView {

    fileprivate var titles: [String] = []
    fileprivate var viewControllers: [UIViewController] = []
    fileprivate var currentViewController: UIViewController?
    fileprivate var selectIndex = 0 {
        didSet {
            if selectIndex != oldValue {
//                debugPrint("-----delegate?.didMoveToPage")
                delegate?.didMoveToPage?(selectIndex)
            }
        }
    }
    fileprivate var scrollView = UIScrollView()
    fileprivate var layout = YYPageLayout()
    var pageTitleView = YYPageTitleView()
    
    weak var delegate: YYPageViewDelegate?
    var currentIndex: Int {
        return selectIndex
    }
    
    init(_ frame: CGRect, viewControllers: [UIViewController], titles: [String], parentViewController: UIViewController, layout: YYPageLayout, index: Int) {
        super.init(frame: frame)
        if viewControllers.count != titles.count {
            return
        }
        if viewControllers.isEmpty {
            return
        }
        self.viewControllers = viewControllers
        self.titles = titles
        self.currentViewController = parentViewController
        self.layout = layout
        self.selectIndex = index > titles.count ? 0 : index
        
        configSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func configSubViews() {
        backgroundColor = UIColor.white
        let titleViewFrame = CGRect(x: 0, y: 0, width: bounds.width, height: layout.sliderHeight)
        pageTitleView = YYPageTitleView(titleViewFrame, titles: titles, layout: layout, index: selectIndex)
        pageTitleView.delegate = self 
        addSubview(pageTitleView)
        
        addSubview(scrollView)
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.frame = CGRect(x: 0, y: layout.sliderHeight, width: bounds.width, height: bounds.height - layout.sliderHeight)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: (CGFloat)(viewControllers.count) * self.bounds.width, height: scrollView.bounds.height)
        
        createViewController(selectIndex)
        scrollView.setContentOffset(CGPoint(x: (CGFloat)(selectIndex) * scrollView.bounds.width, y: 0), animated: false)
    }
    
    fileprivate func createViewController(_ index: Int)  {
        guard !viewControllers.isEmpty else { return }
        let vc = viewControllers[index]
        guard let currentViewController = currentViewController else { return }
        if currentViewController.children.contains(vc) {
            return
        }
        let viewControllerY: CGFloat = 0
        vc.view.frame = CGRect(x: scrollView.bounds.width * CGFloat(index), y: viewControllerY, width: scrollView.bounds.width, height: scrollView.bounds.height)
        scrollView.addSubview(vc.view)
        currentViewController.addChild(vc)
        vc.automaticallyAdjustsScrollViewInsets = false
    }
    
    func scrollToIndex(_ index: Int, animated: Bool) {
        createViewController(index)
        let offset = CGPoint(x: (CGFloat)(index) * scrollView.bounds.width, y: 0)
        scrollView.setContentOffset(offset, animated: animated)
        selectIndex = index
        pageTitleView.scrollToIndex(index)
    }
    
    func updateData(_ viewControllers: [UIViewController], titles: [String], index: Int) {
        if viewControllers.count != titles.count {
            return
        }
        if viewControllers.isEmpty {
            return
        }
        for vc in self.viewControllers {
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
        self.viewControllers = viewControllers
        self.titles = titles
        self.selectIndex = index > titles.count ? 0 : index
        
        pageTitleView.updateData(titles, index: index)
        
        scrollView.contentSize = CGSize(width: (CGFloat)(viewControllers.count) * self.bounds.width, height: scrollView.bounds.height)
        createViewController(selectIndex)
        scrollView.setContentOffset(CGPoint(x: (CGFloat)(selectIndex) * scrollView.bounds.width, y: 0), animated: false)
    }
    
}

extension YYPageView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        debugPrint("-----scrollViewDidScroll")
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        debugPrint("-----scrollViewWillBeginDragging")
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//        debugPrint("-----scrollViewWillBeginDecelerating")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        debugPrint("-----scrollViewDidEndDecelerating offset:\(scrollView.contentOffset)")
        selectIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        createViewController(selectIndex)
        pageTitleView.scrollToIndex(selectIndex)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        debugPrint("-----scrollViewDidEndScrollingAnimation")
    }

}

extension YYPageView: YYPageTitleViewDelegate {
    
    func didSelectTitleAt(_ index: Int) {
//        debugPrint("-----didSelectTitleAt \(index)")
        
        scrollToIndex(index, animated: layout.scrollAnimateWhenClickTitle)
    }
    
}
