//
//  ViewController.swift
//  indexView
//
//  Created by i-Techsys.com on 17/3/13.
//  Copyright © 2017年 i-Techsys. All rights reserved.
//

import UIKit
/** cell循环利用的ID */
private let KSettingCellID = "KSettingCellID"

class ViewController: UIViewController {
    fileprivate lazy var dataArr = [MGCarGroup]()
    // MARK: - 懒加载属性

    public lazy var tableView: UITableView = { [unowned self] in
        let y:CGFloat = (UIScreen.main.bounds.height == 812 || UIScreen.main.bounds.height == 896)  ? 88 : 64
        let tb = UITableView(frame: CGRect(x: 0, y: y, width: MGScreenW, height: MGScreenH))
        tb.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        tb.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tb.dataSource = self
        tb.delegate = self
        tb.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: KSettingCellID)
        if #available(iOS 11.0, *) {
           tb.contentInsetAdjustmentBehavior = .never
        }else {
            self.automaticallyAdjustsScrollViewInsets = false;
        }
        return tb
    }()
    fileprivate lazy var indexView: MGIndexView =  MGIndexView(frame: nil, delegate: self)
    // MARK: - 属性
    fileprivate lazy var tipLetterlabel: UILabel = {
        let tipLetterlabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        tipLetterlabel.center = self.view.center
        tipLetterlabel.textColor = UIColor.white
        tipLetterlabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        tipLetterlabel.font = UIFont.systemFont(ofSize: 28)
        tipLetterlabel.textAlignment = .center
        tipLetterlabel.isHidden = true
        self.view.addSubview(tipLetterlabel)
        return tipLetterlabel
    }()
    var letters = [String]()
    
    
    /** 记录右边边TableView是否滚动到的位置的Y坐标 */
    fileprivate lazy var lastOffsetY: CGFloat = 0
    /** 记录tableView是否向下滚动 */
    fileprivate lazy var  isScrollDown: Bool = true
    /** 改变数据 */
    fileprivate lazy var  isChange: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        loadData()
        indexView.selectedScaleAnimation = true
        view.addSubview(indexView)
        view.bringSubviewToFront(indexView)
        
        scrollViewDidScroll(tableView)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "更改数据", style: .plain
            , target: self, action: #selector(ViewController.changeData))
    }
    
    @objc fileprivate func changeData() {
        dataArr.removeAll()
        letters.removeAll()
        
        isChange = !isChange
        
        tableView.setContentOffset(.zero, animated: false)
        
        if isChange {
            loadData1()
        }else {
            loadData()
        }
    }
    
    fileprivate func loadData1() {
        // 初始化
        // 1.获得plist的全路径
        guard let path = Bundle.main.path(forResource: "cars_total.plist", ofType: nil)  else { return }
        
        // 2.加载数组
        guard let arr = NSArray(contentsOfFile: path) as? [[String : Any]] else { return }
        
        // 3.将dictArray里面的所有字典转成模型对象,放到新的数组中
        for dict in arr {
            dataArr.append(MGCarGroup(dict: dict))
        }
        
        dataArr.removeLast()
        dataArr.removeLast()
        dataArr.removeFirst()
        
        for group in dataArr {
            letters.append(group.title)
        }
        tableView.reloadData()
        indexView.reloadSectionIndexTitles()
    }
    
    fileprivate func loadData() {
        // 初始化
        // 1.获得plist的全路径
        guard let path = Bundle.main.path(forResource: "cars_total.plist", ofType: nil)  else { return }
        
        // 2.加载数组
        guard let arr = NSArray(contentsOfFile: path) as? [[String : Any]] else { return }
        
        // 3.将dictArray里面的所有字典转成模型对象,放到新的数组中
        for dict in arr {
            dataArr.append(MGCarGroup(dict: dict))
        }
        
        for group in dataArr {
            letters.append(group.title)
        }
        tableView.reloadData()
        indexView.reloadSectionIndexTitles()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - 数据源
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let group = self.dataArr[section]
        return group.carArrs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: KSettingCellID, for: indexPath)
        
        // 这个判断selected，设置子试图颜色状态
        let bgView = UIView()
        bgView.backgroundColor = UIColor.brown.withAlphaComponent(0.7) // 蓝色太难看了，设置为棕色
        cell.selectedBackgroundView = bgView
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        // 设置数据
        let group = self.dataArr[indexPath.section]
        let model = group.carArrs[indexPath.row]
        cell.textLabel?.text = model.name
        cell.imageView?.image = UIImage(named: model.icon)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let group = self.dataArr[section];
        return group.title
    }
    
    // MARK：- - =============== 以下方法用来滚动 滚动  滚动 =================
    // 头部即将消失
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if tableView.isDragging && !isScrollDown {
            indexView.scrollViewSelectButtonTitleColor(section: section);
        }
    }
    
    // 头部完全消失
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {//
        if  tableView.isDragging && isScrollDown {
            indexView.scrollViewSelectButtonTitleColor(section: section+1);
        }
    }
}

// MARK: - 数据源和代理
extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.isScrollDown = (lastOffsetY < scrollView.contentOffset.y);
        lastOffsetY = scrollView.contentOffset.y
    }
}

// MARK: - MGIndexViewDelegate
extension ViewController: MGIndexViewDelegate {
    func indexView(_ indexView: MGIndexView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)
        // 弹出首字母提示
        showLetter(title: title)
        return index
    }
    
    fileprivate func showLetter(title: String) {
        self.tipLetterlabel.isHidden = false
        self.tipLetterlabel.text = title
    }
    
    func indexView(_ indexView: MGIndexView, cancelTouch: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.8) {
            self.tipLetterlabel.isHidden = true
        }
    }
    
    func indexViewSectionIndexTitles(for indexView: MGIndexView) -> [String]? {
        return letters
    }
}


