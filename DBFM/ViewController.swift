//
//  ViewController.swift
//  DBFM
//
//  Created by 大可立青 on 15/4/22.
//  Copyright (c) 2015年 大可立青. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,HttpProtocol,ChannelProtocol {

    //歌曲封面
    @IBOutlet weak var songImage: EkoImage!
    //背景
    @IBOutlet weak var backgroundImage: UIImageView!
    //歌曲列表
    @IBOutlet weak var tv: UITableView!
    //播放时间
    @IBOutlet weak var playTime: UILabel!
    
    @IBOutlet weak var progress: UIImageView!
    //网络操作类实例
    var eHttp:HTTPController = HTTPController()
    
    //定义一个变量，接收频道的歌曲数据
    var songData:[JSON] = []
    
    //定义一个变量，接收频道数据
    var channelData:[JSON] = []
    
    //定义一个图片缓存的字典
    var imageCache = Dictionary<String,UIImage>()
    
    //定义一个音乐播放实例
    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController()
    //声明一个计时器
    var timer:NSTimer?
    
    @IBOutlet weak var btnPlay: EkoButton!
    @IBOutlet weak var btnPre: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    //当前在播放第几首
    var currIndex:Int = 0
    
    
    //播放顺序按钮
    @IBOutlet weak var btnOrder:OrderButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImage.addSubview(blurEffectView)
        
        songImage.onRotation()
        
        //设置歌曲列表的数据源和代理
        tv.dataSource = self
        tv.delegate = self
        
        //为网络操作类设置代理
        eHttp.delegate = self
        //获取频道数据
        eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
        //获取频道为0歌曲数据
        eHttp.onSearch("http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite")
        
        tv.backgroundColor = UIColor.clearColor()
        
        btnPlay.addTarget(self, action: "onPlay:", forControlEvents: UIControlEvents.TouchUpInside)
        btnPre.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnNext.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnOrder.addTarget(self, action: "onOrder:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //播放结束通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playFinish", name: MPMoviePlayerPlaybackDidFinishNotification, object: audioPlayer)
        
    }
    
    //歌曲是自然结束还是人为结束
    var isAutoFinish:Bool = true
    
    //人为结束的三种情况:1,点击上一首、下一首；2，选择了频道列表；3，点击了歌曲列表的某一行
    
    func playFinish(){
        if isAutoFinish{
            switch(btnOrder.order){
            case 1:
                //顺序播放
                currIndex++
                if currIndex > songData.count-1{
                    currIndex = 0
                }
                onSelectRow(currIndex)
            case 2:
                //随机播放
                currIndex = random() % songData.count
                onSelectRow(currIndex)
            case 3:
                //单曲循环
                onSelectRow(currIndex)
            default:
                "default"
            }
        }else{
            isAutoFinish = true
        }
    }
    
    //播放、暂停
    func onPlay(btn:EkoButton){
        if btn.isPlay{
            audioPlayer.play()
        }else{
            audioPlayer.pause()
        }
    }
    
    //上一首、下一首
    func onClick(btn:EkoButton){
        isAutoFinish = false
        if btn == btnNext{
            currIndex++
            if currIndex > songData.count-1{
                currIndex = 0
            }
        }else{
            currIndex--
            if currIndex < 0{
                currIndex = songData.count-1
            }
        }
        onSelectRow(currIndex)
    }
    
    //播放顺序
    func onOrder(btn:OrderButton){
        var message:String = ""
        switch(btn.order){
        case 1:
            message = "顺序播放"
        case 2:
            message = "随机播放"
        case 3:
            message = "单曲循环"
        default:
            message = "######"
        }
        self.view.makeToast(message: message, duration: 0.5, position: "center")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //设置歌曲列表数据行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songData.count
    }
    
    //配置歌曲列表单元格
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCellWithIdentifier("douban", forIndexPath: indexPath) as! UITableViewCell
        //设置cell背景透明
        cell.backgroundColor = UIColor.clearColor()
        //获取cell数据
        let rowData:JSON = songData[indexPath.row] as JSON
        //设置标题
        cell.textLabel?.text = rowData["title"].string
        cell.detailTextLabel?.text = rowData["artist"].string
        //设置缩略图
        cell.imageView?.image = UIImage(named: "thumb")
        //封面的网址
        let url = rowData["picture"].string
//        Alamofire.manager.request(Method.GET, url!).response { (_, _, data, error) -> Void in
//            //将图片数据赋予UIImage
//            let img = UIImage(data: data! as! NSData)
//            //设置封面的缩略图
//            cell.imageView?.image = img
//        }
        onGetCahceImage(url!, imageView: cell.imageView!)
        
        return cell
    }
    
    //选中了哪一首歌曲
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        isAutoFinish = false
        onSelectRow(indexPath.row)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    
    //选中了哪一行
    func onSelectRow(index:Int){
        //构建一个indexPath
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        //选中的效果
        tv.selectRowAtIndexPath(indexPath!, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        //获取选中行数据
        var rowData:JSON = songData[indexPath.row] as JSON
        //获取选中歌曲封面网络地址
        let imageUrl:String = rowData["picture"].string!
        //let audioUrl:String = rowData["url"].string!
        //设置封面及背景
        onSetImage(imageUrl)
        
        //获取音乐地址
        let url:String = rowData["url"].string!
        //播放歌曲
        onSetAudio(url)
    }
    
    func onSetImage(url:String){
//        Alamofire.manager.request(Method.GET, url).response { (_, _, data, error) -> Void in
//            //将获取的数据赋予UIImage
//            let image = UIImage(data: data! as! NSData)
//            self.songImage.image = image
//            self.backgroundImage.image = image
//        }
        onGetCahceImage(url, imageView: self.songImage)
        onGetCahceImage(url, imageView: self.backgroundImage)
    }
    
    //图片缓存策略方法
    func onGetCahceImage(url:String,imageView:UIImageView){
        //通过图片地址去缓存中取图片
        let image = self.imageCache[url] as UIImage?
        if image == nil{
            //如果缓存中没有这张图片，就通过网络获取
            Alamofire.manager.request(Method.GET, url).response({ (_, _, data, error) -> Void in
                //将获取的图像数据赋予UIImage
                let img = UIImage(data:data! as! NSData)
                imageView.image = img
                self.imageCache[url] = img
            })
        }else{
            //如果缓存中有，则直接使用
            imageView.image = image!
        }
    }
    
    func didRecieveResults(results: AnyObject) {
        //println("\(results)")
        let json = JSON(results)
        if let channels = json["channels"].array{
            self.channelData = channels
        }else if let songs = json["song"].array{
            
            isAutoFinish = false
            
            self.songData = songs
            self.tv.reloadData()
            //设置第一首歌的封面及背景
            onSelectRow(0)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //获取跳转目标
        var channelC:ChannelViewController = segue.destinationViewController as! ChannelViewController
        //设置代理
        channelC.delegate = self
        //传输频道数据
        channelC.channelData = self.channelData
    }
    
    //频道列表协议的回调方法
    func onChangeChannel(channel_id: String) {
        //拼凑频道列表歌曲数据的网络地址
        let url:String = "http://douban.fm/j/mine/playlist?type=n&channel=\(channel_id)&from=mainsite"
        eHttp.onSearch(url)
    }
    
    //播放音乐
    func onSetAudio(url:String){
        audioPlayer.stop()
        audioPlayer.contentURL = NSURL(string: url)
        audioPlayer.play()
        
        //解决上一首、下一首时播放（暂停）按钮的显示
        btnPlay.onPlay()
        
        timer?.invalidate()
        playTime.text = "00:00"
        timer=NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "onUpdateTime", userInfo: nil, repeats: true)
        
        isAutoFinish = true
    }
    
    //更新播放时间
    func onUpdateTime(){
        let c = audioPlayer.currentPlaybackTime
        if c>0.0{
            let all:Int = Int(c)
            //歌曲播放总时间
            let t = audioPlayer.duration
            //当前播放时间与总时间的百分比
            let p:CGFloat = CGFloat(c/t)
            //按百分比显示进度条的宽度
            progress.frame.size.width = view.frame.size.width * p
            
            //秒数
            let ss:Int = all%60 
            //分数
            let mm:Int = Int(all/60)
            var time:String = ""
            
            if mm<10{
                time = "0\(mm)"
            }else{
                time = "\(mm)"
            }
            
            if ss<10{
                time += ":0\(ss)"
            }else{
                time += ":\(ss)"
            }
            playTime.text = time
        }
    }


}

