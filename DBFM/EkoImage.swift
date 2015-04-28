
import UIKit

class EkoImage: UIImageView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //设置圆角
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.width/2
        
        //设置边框
        self.layer.borderWidth = 4
        self.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1).CGColor
        
    }
    
    func onRotation(){
        //动画实例关键字
        var animation = CABasicAnimation(keyPath: "transform.rotation")
        //初始值
        animation.fromValue = 0
        //结束值
        animation.toValue = M_PI * 2
        //动画执行时间
        animation.duration = 20
        //动画重复次数
        animation.repeatCount = 10000
        self.layer.addAnimation(animation, forKey: nil)
    }

}
