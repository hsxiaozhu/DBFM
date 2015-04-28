//
//  EkoButton.swift
//  DBFM
//
//  Created by 大可立青 on 15/4/24.
//  Copyright (c) 2015年 大可立青. All rights reserved.
//

import UIKit

class EkoButton: UIButton {

    var isPlay:Bool = true
    let imgPlay:UIImage = UIImage(named: "play")!
    let imgPause:UIImage = UIImage(named: "pause")!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: "onClick", forControlEvents: UIControlEvents.TouchUpInside)
    }
    func onClick(){
        isPlay = !isPlay
        if isPlay{
            self.setImage(imgPause, forState: UIControlState.Normal)
        }else{
            self.setImage(imgPlay, forState: UIControlState.Normal)
        }
    }
    
    func onPlay(){
        self.isPlay = true
        self.setImage(imgPause, forState: UIControlState.Normal)
    }

}
