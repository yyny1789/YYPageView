//
//  ViewController.swift
//  新闻菜单
//
//  Created by Yangyang on 2022/10/19.
//

import UIKit

class ViewController: UIViewController {

    var tracks = [TrackEntity]()
    var unselectTracks = [TrackEntity]()
    var selectedTrack: TrackEntity?
    
    fileprivate var titles: [String] = []
    fileprivate var viewControllers = [UIViewController]()
    fileprivate var viewControllerDic = [Int: UIViewController]()
    
    fileprivate var pageView: YYPageView?
    fileprivate var layout: YYPageLayout = {
        var layout = YYPageLayout()
        layout.titleMargin = 22
        layout.sliderHeight = 44
        layout.lMargin = 16
        layout.rMargin = 50
        layout.scrollAnimateWhenClickTitle = false
        return layout
    }()
    
    var menuBgView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.image = UIImage(named: "menuBg")
        return view
    }()
    
    var menuBtn: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "menuBtn"), for: .normal)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }

    func fetchData() {
        let track1 = TrackEntity(id: 1, name: "关注", canSort: 0)
        let track2 = TrackEntity(id: 2, name: "头条", canSort: 0)
        let track3 = TrackEntity(id: 3, name: "新时代", canSort: 1)
        let track4 = TrackEntity(id: 4, name: "汽车", canSort: 1)
        let track5 = TrackEntity(id: 5, name: "财经", canSort: 1)
        let track6 = TrackEntity(id: 6, name: "房产", canSort: 1)
        let track7 = TrackEntity(id: 7, name: "股票", canSort: 1)
        let track8 = TrackEntity(id: 8, name: "历史", canSort: 1)
        let track9 = TrackEntity(id: 9, name: "家居", canSort: 1)
        let track10 = TrackEntity(id: 10, name: "独家", canSort: 1)
        let track11 = TrackEntity(id: 11, name: "游戏", canSort: 1)
        let track12 = TrackEntity(id: 12, name: "健康", canSort: 1)
        tracks = [track1, track2, track3, track4, track5, track6, track7, track8, track9, track10, track11, track12]
        
        let track13 = TrackEntity(id: 13, name: "娱乐", canSort: 1)
        let track14 = TrackEntity(id: 14, name: "影视", canSort: 1)
        let track15 = TrackEntity(id: 15, name: "体育", canSort: 1)
        unselectTracks = [track13, track14, track15]
        
        configSubView()
    }
    
    fileprivate func configSubView() {
        view.backgroundColor = UIColor.white
        
        if tracks.isEmpty {
            return
        }
        
        configViewControllersAndTitles()
        
        let frame = CGRect(x: 0, y: LayoutConstants.navBarHeight, width: view.frame.size.width, height: view.frame.size.height - LayoutConstants.navBarHeight)

        let pageView = YYPageView(frame, viewControllers: self.viewControllers, titles: self.titles, parentViewController: self, layout: self.layout, index: 0)
        pageView.delegate = self
        self.pageView = pageView
        self.view.addSubview(pageView)
        
        menuBgView.frame = CGRect(x:view.frame.size.width - 67, y: 0, width: 82, height: 44)
        menuBtn.frame = CGRect(x: view.frame.size.width - 31, y: 11, width: 20, height: 20)
        menuBtn.addTarget(self, action: #selector(menuBtnAction), for: .touchUpInside)
        pageView.pageTitleView.addSubview(menuBgView)
        pageView.pageTitleView.addSubview(menuBtn)
    }
    
    func configViewControllersAndTitles() {
        titles.removeAll()
        viewControllers.removeAll()
        
        for track in tracks {
            titles.append(track.name)
            let key = track.id
            
            if let vc = viewControllerDic[key] {
                viewControllers.append(vc)
            } else {
                let vc = TestViewController()
                vc.title = track.name
                vc.track = track
                viewControllerDic[key] = vc
                viewControllers.append(vc)
            }
        }
    }
    
    @objc func menuBtnAction() {
        let vc = TrackManagerController(tracks, unselectTracks: unselectTracks)
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        self.present(vc, animated: true) {
            
        }
    }

}

// MARK: - 实现需要的协议
// MARK: YYPageViewDelegate
extension ViewController: YYPageViewDelegate {
    
    func didMoveToPage(_ page: Int) {
        selectedTrack = tracks[page]
    }
    
}

// MARK: TrackManagerControllerDelegate
extension ViewController: TrackManagerControllerDelegate {

    func trackManagerClosed(_ tracks: [TrackEntity], unselectTracks: [TrackEntity], hadUpdateData: Bool, selectIndex: Int?) {
        if hadUpdateData {
            self.tracks = tracks
            self.unselectTracks = unselectTracks
            // 向服务器更新数据
//            self.updateTrackData()
            
            // 布局页面
            configViewControllersAndTitles()
            
            var willSelectIndex = 0
            
            if let selectIndex = selectIndex { // 有新栏目
                self.selectedTrack = tracks[selectIndex]
                willSelectIndex = selectIndex
            } else { // 没有新栏目
                if let oldData = self.selectedTrack { // 有旧栏目
                    if let index = tracks.firstIndex(where: { item in // 找到旧栏目的位置
                        return item.id == oldData.id
                    }) {
                        willSelectIndex = index
                    }
                }
            }
            pageView?.updateData(viewControllers, titles: titles, index: willSelectIndex)
        } else {
            if let selectIndex = selectIndex, let oldData = self.selectedTrack, tracks[selectIndex].id != oldData.id { // 新栏目和旧栏目不同
                self.selectedTrack = tracks[selectIndex]
                pageView?.scrollToIndex(selectIndex, animated: false)
            }
        }
    }
    
}
