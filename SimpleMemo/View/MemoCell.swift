//
//  MemoCell.swift
//  EverMemo
//
//  Created by  李俊 on 15/8/5.
//  Copyright (c) 2015年  李俊. All rights reserved.
//

import UIKit
import SnapKit
import SMKit

private let deleteViewWidth: CGFloat = 60

class MemoCell: UICollectionViewCell, UIGestureRecognizerDelegate {

  var didSelectedMemoAction: ((_ memo: Memo) -> Void)?
  var deleteMemoAction: ((_ memo: Memo) -> Void)?
  var memo: Memo? {
    didSet {
      contentLabel.text = memo!.text
    }
  }

  fileprivate let scrollView = UIScrollView()
  fileprivate let deleteView = DeleteView()
  fileprivate let contentLabel: MemoLabel = {
    let label = MemoLabel()
    label.backgroundColor = .white
    label.numberOfLines = 0
    label.font = UIFont.systemFont(ofSize: 15)
    label.verticalAlignment = .top
    label.textColor = SMColor.content
    label.sizeToFit()
    return label
  }()
  fileprivate var getsureRecognizer: UIGestureRecognizer?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setUI()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    scrollView.contentSize = CGSize(width: contentView.width + deleteViewWidth, height: contentView.height)
    deleteView.frame = CGRect(x: contentView.width, y: 0, width: deleteViewWidth, height: contentView.height)
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc fileprivate func topLabel() {
    if let memo = memo {
      didSelectedMemoAction?(memo)
    }
  }

  @objc fileprivate func deleteMemo() {
    if let memo = memo {
      deleteMemoAction?(memo)
    }
  }

  override func prepareForReuse() {
    memo = nil
  }
}

// MARK: - UI
private extension MemoCell {

  func setUI() {
    backgroundColor = UIColor.white
    scrollView.bounces = false
    scrollView.delegate = self
    scrollView.showsHorizontalScrollIndicator = false
    contentView.addSubview(scrollView)

    scrollView.snp.makeConstraints { (maker) in
      maker.top.left.bottom.right.equalToSuperview()
    }

    getsureRecognizer = UITapGestureRecognizer(target: self, action: #selector(topLabel))
    getsureRecognizer?.delegate = self
    contentLabel.addGestureRecognizer(getsureRecognizer!)
    contentLabel.isUserInteractionEnabled = true
    scrollView.addSubview(contentLabel)
    contentLabel.snp.makeConstraints { (maker) in
      maker.top.equalTo(scrollView).offset(5)
      maker.left.equalTo(scrollView).offset(5)
      maker.bottom.equalTo(contentView).offset(-5)
      maker.right.lessThanOrEqualTo(contentView).offset(-5)
    }

    deleteView.backgroundColor = SMColor.backgroundGray
    deleteView.deleteBtn.addTarget(self, action: #selector(deleteMemo), for: .touchUpInside)
    scrollView.addSubview(deleteView)

    layer.shadowOffset = CGSize(width: 0, height: 1)
    layer.shadowOpacity = 0.2
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
  }
}

extension MemoCell: UIScrollViewDelegate {

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.isTracking {
      return
    }
    automateScroll(scrollView)
  }

  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if decelerate {
      return
    }
    automateScroll(scrollView)
  }

  func automateScroll(_ scrollView: UIScrollView) {
    let offsetX = scrollView.contentOffset.x
    let newX = offsetX < deleteViewWidth / 2 ? 0 : deleteViewWidth
    UIView.animate(withDuration: 0.1) {
      scrollView.contentOffset = CGPoint(x: newX, y: 0)
    }
  }
}

// MARK: - DeleteView
private class DeleteView: UIView {

  let deleteBtn = UIButton(type: .custom)

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .gray
    let image = UIImage(named: "ic_trash")?.withRenderingMode(.alwaysTemplate)
    deleteBtn.setImage(image, for: .normal)
    deleteBtn.backgroundColor = SMColor.red
    deleteBtn.layer.masksToBounds = true
    deleteBtn.tintColor = SMColor.backgroundGray
    addSubview(deleteBtn)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  fileprivate override func layoutSubviews() {
    super.layoutSubviews()
    let margin: CGFloat = 12
    let btnWidth = width - margin * 2
    let btnY = (height - btnWidth) / 2
    deleteBtn.frame = CGRect(x: margin, y: btnY, width: btnWidth, height: btnWidth)
    deleteBtn.layer.cornerRadius = deleteBtn.width / 2
  }

}
