//
//  ChannelViewController.swift
//  DBFM
//
//  Created by 大可立青 on 15/4/23.
//  Copyright (c) 2015年 大可立青. All rights reserved.
//

import UIKit
import QuartzCore

protocol ChannelProtocol{
    func onChangeChannel(channel_id:String)
}

class ChannelViewController: UIViewController,UITableViewDelegate {

    
    @IBOutlet weak var channelTable: UITableView!
    
    //声明代理
    var delegate:ChannelProtocol?
    
    //定义一个变量，接收频道数据
    var channelData:[JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.alpha = 0.8
    }
    
    //设置频道列表数据行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelData.count
    }
    
    //配置频道列表单元格
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = channelTable.dequeueReusableCellWithIdentifier("channel", forIndexPath: indexPath) as! UITableViewCell
        //获取cell数据
        let rowData:JSON = self.channelData[indexPath.row] as JSON
        //设置标题
        cell.textLabel?.text = rowData["name"].string
        return cell
    }
    
    //选中具体频道
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //获取行数据
        let rowData:JSON = self.channelData[indexPath.row] as JSON
        //获取channel_id
        let channel_id:String = rowData["channel_id"].stringValue
        //反向传递channel_id
        delegate?.onChangeChannel(channel_id)
        //关闭当前界面
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    
}
