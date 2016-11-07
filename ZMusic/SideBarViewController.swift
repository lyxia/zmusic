//
//  SideBarViewController.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/22.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import ZMusicUIFrame

class SideBarViewController: UIViewController {
    
    init() {
        super.init(nibName: "SideBarViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var disposeBag: DisposeBag!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!

    private var reuseCell: UITableViewCell?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
    }
    
    func configUI() {
        settingBtn.updatePosition(withStyle: .ImageLeftTitle, spacing: 15)
        tableView.backgroundColor = UIColor.clear
        
        tableView.register(UINib(nibName: "SystemCellValue1", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        disposeBag = DisposeBag()
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, SystemCellValue1Model>>()
        let items = Observable.just([
            SectionModel(model: "First section", items: [
                SystemCellValue1Model(imageName:"musicsidebar_icon_messageCenter", text:"消息中心", detailText:nil),
                SystemCellValue1Model(imageName:"musicsidebar_icon_vipcenter", text:"会员中心", detailText:nil),
                SystemCellValue1Model(imageName:"musicsidebar_icon_netpack", text:"流量包月", detailText:"听歌免流量"),
                SystemCellValue1Model(imageName:"musicsidebar_icon_clock", text:"定时关闭", detailText:nil),
                SystemCellValue1Model(imageName:"musicsidebar_icon_audioeffect", text:"蝰蛇效果", detailText:nil),
                SystemCellValue1Model(imageName:"musicsidebar_icon_listen", text:"听歌识曲", detailText:nil),
                SystemCellValue1Model(imageName:"musicsidebar_icon_listen", text:"启动问候音", detailText:"经典版")
                ]),
            SectionModel(model: "Second section", items: [
                SystemCellValue1Model(imageName:"musicsidebar_icon_onlywifi", text:"仅wifi联网", detailText:nil),
                SystemCellValue1Model(imageName:"musicsidebar_icon_notificationLyric", text:"通知栏歌词", detailText:nil)
                ])
            ])
        dataSource.configureCell = {(dataSource, tv, indexPath, element) in
            let cell = tv.dequeueReusableCell(withIdentifier: "cell")!
            cell.textLabel?.text = element.text
            cell.detailTextLabel?.text = element.detailText
            cell.imageView?.image = UIImage(named: element.imageName)
            if indexPath.section == 1 {
                cell.accessoryView = UISwitch()
                cell.selectionStyle = .none
            }
            return cell
        }
        items.bindTo(tableView.rx.items(dataSource:dataSource)).addDisposableTo(disposeBag)
        tableView.rx.setDelegate(self).addDisposableTo(disposeBag)
    }
    
    @IBAction func skinBtnHandler(_ sender: UIButton) {
        let skinCenterVC = SkinCenterNavgationController(presentingVC: self)
        self.present(skinCenterVC, animated: true, completion: nil)
    }
}

extension SideBarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.bounds.maxX, height: 15)))
        if let dataSource = tableView.dataSource {
            if dataSource.numberOfSections!(in: tableView) - 1 == section {
                let line = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.bounds.maxX, height: 1)))
                line.backgroundColor = UIColor.white.withAlphaComponent(0.18)
                view.addSubview(line)
            }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
