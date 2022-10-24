//
//  TrackManagerController.swift
//  新闻菜单
//
//  Created by Yangyang on 2022/10/20.
//

import UIKit

protocol TrackManagerControllerDelegate: AnyObject {
    func trackManagerClosed(_ tracks: [TrackEntity], unselectTracks: [TrackEntity], hadUpdateData: Bool, selectIndex: Int?)
}

class TrackManagerController: UIViewController {
    
    enum State {
        case normal
        case edit
    }
    
    enum SectionType {
        case top
        case bottom
    }
    
    var state: State = .normal {
        didSet {
            if state != oldValue {
                collectionView.reloadData()
            }
        }
    }
    
    var closeBtn: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "menu_close"), for: .normal)
        view.touchAreaEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        return view
    }()
    
    var tipLabel: UILabel = {
        let view = UILabel()
        view.text = "所有栏目"
        view.textColor = UIColor.black
        view.font = FontConstants.mediumFont18
        view.textAlignment = .center
        return view
    }()
  
    // floor 向下取整
    static var collectionViewItemW: CGFloat = floor((LayoutConstants.screenWidth - 62) / CGFloat(4))
    static var collectionViewItemH: CGFloat = 36.0
    
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isUserInteractionEnabled = true
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    let contentViewW: CGFloat = LayoutConstants.screenWidth
    var contentViewH: CGFloat = 0
    var longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
    
    var sectionTypes: [SectionType] = [.top, .bottom]
    
    var originTracks = [TrackEntity]()
    var tracks = [TrackEntity]()
    var unselectTracks = [TrackEntity]()
    
    weak var delegate: TrackManagerControllerDelegate?

    convenience init(_ tracks: [TrackEntity], unselectTracks: [TrackEntity]) {
        self.init(nibName: nil, bundle: nil)
        self.originTracks = tracks
        self.tracks = tracks
        self.unselectTracks = unselectTracks
    } 

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        tipLabel.sizeToFit()
        tipLabel.centerY = LayoutConstants.statusBarHeight + 20
        tipLabel.centerX = contentViewW / 2
        view.addSubview(tipLabel)
        
        closeBtn.size = CGSize(width: 26, height: 26)
        closeBtn.centerY = tipLabel.centerY
        closeBtn.right = LayoutConstants.screenWidth - 16
        closeBtn.addTarget(self, action: #selector(self.closeAction), for: .touchUpInside)
        view.addSubview(closeBtn)
        
        contentViewH = LayoutConstants.screenHeight - LayoutConstants.navBarHeight
        let collectionViewY: CGFloat = LayoutConstants.navBarHeight
        collectionView.frame = CGRect(x: 0, y: collectionViewY, width: contentViewW, height: contentViewH - collectionViewY - LayoutConstants.adjustInsetForIPhoneX.bottom)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(InvestorTrackCell.self, forCellWithReuseIdentifier: InvestorTrackCell.cellIdentifier)
        collectionView.register(TrackSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackSectionHeaderView.cellIdentifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: UICollectionReusableView.cellIdentifier)
        view.addSubview(collectionView)
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture))
        longPressGesture.minimumPressDuration = 0.2
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func closeAction() {
        checkData()
    }
    
    // MARK: 长按编辑频道界面交互
    fileprivate var originalIndex: IndexPath?
    var detlaX: CGFloat = 0
    var detlaY: CGFloat = 0
    fileprivate var newcell = UIView()
    fileprivate var hasNewCell: Bool = false
    fileprivate var fixRect: CGRect?
    
    func cellSelectAtIndex(cell: InvestorTrackCell) {
        UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            cell.layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshot: UIImageView = UIImageView(image: image)
        snapshot.layer.shadowOffset = CGSize(width: 2, height: 2)
        snapshot.layer.shadowOpacity = 0.3
        snapshot.layer.shadowColor = UIColor.black.cgColor
        newcell = snapshot
        collectionView.addSubview(newcell)
        cell.isHidden = true
    }
    
    func isFixItem(indexPath: IndexPath) -> Bool {
        if tracks[indexPath.item].canSort == 0 { // 不能移动
            return true
        }
        return false
    }
    
    @objc func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        if let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)), selectedIndexPath.section == 0, state == .normal {
            state = .edit
        } else {
            changeState(gesture)
        }
    }
    
    func changeState(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizer.State.began:
            gestureBegan(gesture)
        case UIGestureRecognizer.State.changed:
            gestureChanged(gesture)
        case UIGestureRecognizer.State.ended:
            gestureEnded(gesture)
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    func gestureBegan(_ gesture: UIGestureRecognizer) {
        if let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)), selectedIndexPath.section == 0, !isFixItem(indexPath: selectedIndexPath) {
            originalIndex = selectedIndexPath
            
            if let cell = collectionView.cellForItem(at: selectedIndexPath), let cateCell = cell as? InvestorTrackCell {
                cellSelectAtIndex(cell: cateCell)
                let location = gesture.location(in: collectionView)
                detlaX = location.x - cateCell.center.x
                detlaY = location.y - cateCell.center.y
                newcell.center = CGPoint(x: location.x - detlaX, y: location.y - detlaY)
                hasNewCell = true
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        }
    }

    func gestureChanged(_ gesture: UIGestureRecognizer) {
        if !hasNewCell {
            gestureBegan(gesture)
        }
        let location = gesture.location(in: collectionView)
        let itemsCount = collectionView.numberOfItems(inSection: 0)
        let count = ceil(Double(itemsCount) / 4.0)
        
        let validHeight: CGFloat = CGFloat((count + 1) * 36 + count * 12)
        newcell.center = CGPoint(x: location.x - detlaX, y: location.y - detlaY)
        if let rect = fixRect {
            if location.y < validHeight {
                if location.x > rect.maxX || location.y > rect.maxY {
                    if let v = gesture.view {
                        collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: v))
                    }
                }
            }
        }
    }

    func gestureEnded(_ gesture: UIGestureRecognizer) {
        if let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)),
            selectedIndexPath.section == 0,
            selectedIndexPath.row < tracks.count,
            let cell = collectionView.cellForItem(at: selectedIndexPath),
            let cateCell = cell as? InvestorTrackCell,
            let original = originalIndex,
            let originalcell = collectionView.cellForItem(at: original),
            let oldCell = originalcell as? InvestorTrackCell,
           !isFixItem(indexPath: selectedIndexPath) {
            newcell.removeFromSuperview()
            oldCell.isHidden = false
            cateCell.isHidden = false
            collectionView.endInteractiveMovement()
        } else {
            newcell.removeFromSuperview()
            collectionView.endInteractiveMovement()
            collectionView.reloadData()
        }
    }
    
    func checkData(_ index: Int? = nil) {
        var hadUpdateData = false
        if originTracks.count != tracks.count {
            hadUpdateData = true
        } else {
            for i in 0..<originTracks.count {
                let originItem = originTracks[i]
                let item = tracks[i]
                if originItem.id != item.id {
                    hadUpdateData = true
                    break
                }
            }
        }
        
        dismiss(animated: true) {
            self.delegate?.trackManagerClosed(self.tracks, unselectTracks: self.unselectTracks, hadUpdateData: hadUpdateData, selectIndex: index)
        }
    }
    
}

extension TrackManagerController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionTypes.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sectionTypes[section] {
        case .top:
            return tracks.count
        case .bottom:
            return unselectTracks.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InvestorTrackCell.cellIdentifier, for: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? InvestorTrackCell else { return }
        
        let section = sectionTypes[indexPath.section]
        switch section {
        case .top:
            if tracks[indexPath.row].canSort == 0 {
                fixRect = cell.frame
            }
            cell.setData(tracks[indexPath.row], section: section, state: state)
        case .bottom:
            cell.setData(unselectTracks[indexPath.row], section: section, state: state)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackSectionHeaderView.cellIdentifier, for: indexPath)
            if let view = view as? TrackSectionHeaderView {
                view.delegate = self
                view.setData(sectionTypes[indexPath.section], state: state)
            }
            return view
        } else {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: UICollectionReusableView.cellIdentifier, for: indexPath)
            footerView.backgroundColor = UIColor.white
            return footerView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch sectionTypes[section] {
        case .top:
            let height: CGFloat = tracks.isEmpty ? 0 : 43
            return CGSize(width: collectionView.width, height: height)
        case .bottom:
            let height: CGFloat = unselectTracks.isEmpty ? 0 : 43
            return CGSize(width: collectionView.width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.width, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: TrackManagerController.collectionViewItemW, height: TrackManagerController.collectionViewItemH)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        switch sectionTypes[indexPath.section] {
        case .top:
            if state == .edit {
                let item = tracks[indexPath.row]
                if item.canSort == 1 {
                    let item = tracks.remove(at: indexPath.row)
                    unselectTracks.append(item)
                    collectionView.reloadData()
                }
            } else {
                self.checkData(indexPath.row)
            }
        case .bottom:
            let item = unselectTracks.remove(at: indexPath.row)
            tracks.append(item)
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        switch sectionTypes[indexPath.section] {
        case .top:
            return true
        default:
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        switch sectionTypes[sourceIndexPath.section] {
        case .top:
            let entity = tracks[sourceIndexPath.row]
            tracks.remove(at: sourceIndexPath.row)
            tracks.insert(entity, at: destinationIndexPath.row)
        default:
            return
        }
    }
    
}

extension TrackManagerController: TrackSectionHeaderViewDelegate {
    
    func editTrackAction(_ state: TrackManagerController.State) {
        self.state = state
    }
    
}

// MARK: - InvestorTrackCell
class InvestorTrackCell: UICollectionViewCell {

    var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.04)
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()

    var titleLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.adjustsFontSizeToFitWidth = true
        return view
    }()

    var iconImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(bgView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(iconImageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(_ data: TrackEntity, section: TrackManagerController.SectionType, state: TrackManagerController.State) {
        titleLabel.text = data.name
        titleLabel.textColor = UIColor.black.withAlphaComponent(0.85)
        if data.name.count >= 4 {
            titleLabel.font = FontConstants.regularFont12
        } else {
            titleLabel.font = FontConstants.regularFont14
        }
        
        iconImageView.isHidden = true
        
        switch section {
        case .top:
            if data.canSort == 0 {
                titleLabel.textColor = ColorConstants.color_9E9E9E
            } else {
                if state == .edit {
                    iconImageView.isHidden = false
                    iconImageView.image = UIImage(named: "menu_close2")
                }
            }
        case .bottom:
            iconImageView.isHidden = false
            iconImageView.image = UIImage(named: "menu_add")
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        titleLabel.frame = bgView.bounds
        iconImageView.frame = CGRect(x: width - 14, y: 2, width: 12, height: 12)
    }
    
}

// MARK: - TrackSectionHeaderView

protocol TrackSectionHeaderViewDelegate: AnyObject {
    func editTrackAction(_ state: TrackManagerController.State)
}

class TrackSectionHeaderView: UICollectionReusableView {
    
    weak var delegate: TrackSectionHeaderViewDelegate?
    var state: TrackManagerController.State = .normal
    
    var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.black.withAlphaComponent(0.85)
        view.font = FontConstants.mediumFont16
        return view
    }()
    
    var subTitleLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(hex: 0x9E9E9E)
        view.font = FontConstants.regularFont12
        return view
    }()
    
    var editBtn: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle("编辑", for: .normal)
        view.setTitleColor(UIColor(hex: 0x3662EC), for: .normal)
        view.titleLabel?.font = FontConstants.mediumFont14
        view.touchAreaEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(editBtn)
        
        editBtn.addTarget(self, action: #selector(self.editBtnAction), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func editBtnAction() {
        if state == .normal {
            delegate?.editTrackAction(.edit)
        } else {
            delegate?.editTrackAction(.normal)
        }
    }
    
    func setData(_ section: TrackManagerController.SectionType, state: TrackManagerController.State) {
        self.state = state
        switch section {
        case .top:
            titleLabel.text = "我的栏目"
            subTitleLabel.text = state == .edit ? "拖拽可改变顺序" : "点击进入栏目"
            editBtn.isHidden = false
            editBtn.setTitle(state == .edit ? "完成" : "编辑", for: .normal)
        case .bottom:
            titleLabel.text = "更多栏目"
            subTitleLabel.text = "点击添加栏目"
            editBtn.isHidden = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.sizeToFit()
        titleLabel.left = 16
        titleLabel.top = 20
        
        subTitleLabel.sizeToFit()
        subTitleLabel.width = 100
        subTitleLabel.left = titleLabel.right + 8
        subTitleLabel.centerY = titleLabel.centerY
        
        editBtn.sizeToFit()
        editBtn.right = width - 16
        editBtn.bottom = height
    }
    
}
