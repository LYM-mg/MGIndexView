//
//  MGIndexView.swift
//  indexView
//
//  Created by i-Techsys.com on 17/3/13.
//  Copyright © 2017年 i-Techsys. All rights reserved.
//

import UIKit

let MGScreenBounds = UIScreen.main.bounds
let MGScreenW      = UIScreen.main.bounds.size.width
let MGScreenH      = UIScreen.main.bounds.size.height

open class MGIndexView: UIView {
    // MARK: - 接口属性： UIColor.orange
    @objc public var selectTitleColor: UIColor = UIColor.orange { // 选中颜色
        didSet {
            selectColor = selectTitleColor
        }
    }
    @objc public  var normalTitleColor: UIColor = UIColor.gray {  // 正常颜色
        didSet {
            normalColor = normalTitleColor
        }
    }
    
    @objc public  var selectedScaleAnimation: Bool = false  // 默认false，选中的标题不需要放大
    @objc open weak var delegate: MGIndexViewDelegate?   // 代理
    
    // MARK: - Public Method
    @objc public func scrollViewSelectButtonTitleColor(section: Int) {
        if section >= self.letterButtons.count { return }
        let btn = self.letterButtons[section]
        UIView.animate(withDuration: 1.5) {
            self.selectedButton.setTitleColor(.gray, for: .normal)
            self.selectedButton = btn
            self.selectedButton.setTitleColor(.orange, for: .normal)
        }
        
        if self.selectedScaleAnimation {
            self.mg_ScaleSelectedBtn(btn: btn)
        }
    }
    
    // 刷新数据
    @objc public  func reloadSectionIndexTitles() {
        if delegate != nil && (delegate?.responds(to: #selector(MGIndexViewDelegate.indexViewSectionIndexTitles(for:))))! {
            self.letters = delegate!.indexViewSectionIndexTitles(for: self)!
        }
    }
    
    // MARK: - 私有属性
    fileprivate var selectColor: UIColor = UIColor.orange
    fileprivate lazy var normalColor: UIColor = UIColor.gray
    fileprivate lazy var letterButtons: [UIButton] = [UIButton]()
    fileprivate lazy var selectedButton: UIButton = UIButton() // 当前选中的按钮
    @objc open var letters: [String] = [String]() {     // 右边显示的文字数组
        didSet {
            setUpUI()
        }
    }
    
    @objc public class func indexView(delegate: MGIndexViewDelegate?) -> MGIndexView{
        return MGIndexView(delegate: delegate,frame: .zero)
    }
    
    // MARK: - 系统方法
    @objc public convenience init(delegate: MGIndexViewDelegate?,frame: CGRect) {
        self.init()
        self.delegate = delegate
    }
    
    @objc public convenience init(delegate: MGIndexViewDelegate?) {
        self.init()
        self.delegate = delegate
    }
    
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        self.frame = CGRect(x: MGScreenW - 18, y: 0, width: 18, height: MGScreenH)
    }
    
    deinit {
        debugPrint("MGIndexView--deinit")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - 触摸方法
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesMoved(touches, with: event)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        // 获取当前的触摸点
        let curP = touch.location(in: self)
        for btn in letterButtons {
            let btnP = self.convert(curP, to: btn) // 把btn的转化为坐标
            
            // 判断当前点是否点在按钮上
            if btn.point(inside: btnP, with: event) {
                guard let i = letterButtons.index(of: btn) else { return }
                let letter = btn.currentTitle ?? ""
                if delegate != nil && (delegate?.responds(to: #selector(MGIndexViewDelegate.indexView(_:sectionForSectionIndexTitle:at:))))! {
                    let _ = delegate?.indexView(self, sectionForSectionIndexTitle: letter, at: i)
                }
                selectedButton = btn
                btn.setTitleColor(selectColor, for: .normal)
                if selectedScaleAnimation {
                    mg_ScaleSelectedBtn(btn: btn)
                }
            }else {
                btn.setTitleColor(normalColor, for: .normal)
                btn.layer.transform = CATransform3DIdentity
            }
        }
    }
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if delegate != nil && (delegate?.responds(to: #selector(MGIndexViewDelegate.indexView(_:cancelTouch:with:))))! {
            let _ = delegate?.indexView!(self, cancelTouch: touches, with: event)
        }
        selectedButton.setTitleColor(selectColor, for: .normal)
    }
}

// MARK: - 设置UI
extension MGIndexView {
    fileprivate func setUpUI() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        letterButtons.removeAll()
        
        let h = 18
        let x = 0
        for (i,letter) in letters.enumerated() {
            let y = i*(h)
            let btn = UIButton(frame: CGRect(x: x, y: y, width: Int(self.frame.size.width), height: h))
            btn.setTitle(letter, for: .normal)
            btn.setTitleColor(normalColor, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            btn.titleLabel?.textAlignment = .center
            //            btn.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
            btn.isUserInteractionEnabled = false
            addSubview(btn)
            letterButtons.append(btn)
            
            if i == 0 {
                btn.setTitleColor(selectColor, for: .normal)
                if letter == "🔍" {
                    btn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
                }else {
                    btn.setTitleColor(selectColor, for: .normal)
                }
                selectedButton = btn
            }
        }
        
        layoutIfNeeded()
        self.frame.size.height = CGFloat((letterButtons.count) * (h))
        self.center = CGPoint(x: MGScreenW-10, y: MGScreenH*0.5)
    }
}

// MARK: - Private 封装方法
extension MGIndexView {
    fileprivate func mg_ScaleSelectedBtn(btn: UIButton) {
        btn.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
        UIView.animate(withDuration: 1.0) {
            btn.layer.transform = CATransform3DIdentity
        }
    }
}


// MARK: - 协议
@objc public protocol MGIndexViewDelegate: NSObjectProtocol {
    // 手指触摸的时候调用
    @objc func indexView(_ indexView: MGIndexView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    // 返回数据源
    @objc func indexViewSectionIndexTitles(for indexView: MGIndexView) -> [String]?
    // 手指离开的时候调用
    @objc optional func indexView(_ indexView: MGIndexView, cancelTouch: Set<UITouch>, with event: UIEvent?)
}
