//
//  QMCameraPhotoTool.swift
//  QMEnglish
//
//  Created by xmly on 2022/3/19.
//

import UIKit

protocol QMClipperPhotoDelegate {
    func didFinishClippingPhoto(image:UIImage)
}

class QMClipperViewController: UIViewController {
    // 代理
    var delegate:QMClipperPhotoDelegate?
    var imgView:UIImageView?
    
    var img:UIImage?
    let scrollview = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    
    var maxScale:CGFloat = 3.0
    var minScale:CGFloat = 1.0
    
    // 截图大小
    var selectWidth:CGFloat = UIScreen.main.bounds.width
    var selectHeight:CGFloat = UIScreen.main.bounds.width
    
    // 框框线的宽度
    let lineWidth:CGFloat = 1.0
    
    private lazy var cameraButton: UIControl = {
        let btn = UIControl(frame: CGRect(x: (qm_screen_W-240*qm_iPad_scale)*3/7, y: qm_screen_H-30*qm_iPad_scale-42*qm_iPad_scale - qm_indicator_H, width: 120*qm_iPad_scale, height: 42*qm_iPad_scale))
        
        let image = UIImageView(frame: CGRect(x: 15*qm_iPad_scale, y: 12*qm_iPad_scale, width: 20*qm_iPad_scale, height: 18*qm_iPad_scale))
        image.image = UIImage(named: "icon_camera")
        btn.addSubview(image)
        
        let label = UILabel(frame: CGRect(x: (15+20+6)*qm_iPad_scale, y: 12*qm_iPad_scale, width: 64*qm_iPad_scale, height: 20*qm_iPad_scale))
        label.text = "重新拍照"
        label.textColor = UIColor(hexString: "#BDBDBD")
        label.font = UIFont.systemFont(ofSize: 16*qm_iPad_scale)
        btn.addSubview(label)
        btn.backgroundColor = UIColor(hexString: "#F7F8FB")
        btn.layer.cornerRadius = 20*qm_iPad_scale
        btn.layer.masksToBounds = true
        btn.isUserInteractionEnabled = true
        btn.addTarget(self, action: #selector(cameraClicked), for: .touchUpInside)
        return btn
    }()
    private lazy var nextButton: UIControl = {
        let btn = UIControl(frame: CGRect(x: qm_screen_W - (qm_screen_W-240*qm_iPad_scale)*3/7 - 120*qm_iPad_scale, y: qm_screen_H-30*qm_iPad_scale-42*qm_iPad_scale - qm_indicator_H, width: 120*qm_iPad_scale, height: 42*qm_iPad_scale))
        
        let imageView = UIImageView(frame: CGRect(x: 25*qm_iPad_scale, y: 12*qm_iPad_scale, width: 20*qm_iPad_scale, height: 18*qm_iPad_scale))
        imageView.image = UIImage(named: "icon_next")
        btn.addSubview(imageView)
        
        let label = UILabel(frame: CGRect(x: (25+20+6)*qm_iPad_scale, y: 12*qm_iPad_scale, width: 64*qm_iPad_scale, height: 20*qm_iPad_scale))
        label.text = "下一步"
        label.textColor = UIColor(hexString: "#713700")
        label.font = UIFont.systemFont(ofSize: 16*qm_iPad_scale)
        btn.addSubview(label)
        btn.backgroundColor = UIColor(hexString: "#FFC700")
//        let layer = btn.createLayer(rect: .init(x: 0, y: 0, width: 120*qm_iPad_scale, height: 42*qm_iPad_scale), fromColor: UIColor(hexString: "#FFE100"), toColor: UIColor(hexString: "#FFC700"))
//        btn.layer.insertSublayer(layer, at: 0)
//        btn.bringSubview(toFront: imageView)
        btn.layer.cornerRadius = 20*qm_iPad_scale
        btn.layer.masksToBounds = true
        btn.isUserInteractionEnabled = true
        btn.addTarget(self, action: #selector(submitClicked), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
        drawTheRect()
    }
    
    /// 设置图片
    func setImageView(image:UIImage){
        imgView = UIImageView(image: image)
    }
    
    /// 设置裁切区域
    func setClipSize(width:CGFloat,height:CGFloat){
        self.selectHeight = height
        self.selectWidth = width
    }
     
}

// MARK: - UI
extension QMClipperViewController{
    
    fileprivate func setupUI() {
        
        view.backgroundColor = UIColor.white
        
        scrollview.backgroundColor = UIColor.black
        scrollview.delegate = self
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.showsVerticalScrollIndicator = false
        scrollview.maximumZoomScale = maxScale
        scrollview.minimumZoomScale = minScale
        
        if #available(iOS 11.0, *) {
            scrollview.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        imgView = UIImageView(image: img)
        guard let imgView = imgView else {
            return
        }
        imgView.contentMode = .scaleToFill
        imgView.center = scrollview.center
        
        if imgView.bounds.width > qm_screen_W {
            imgView.frame.size = CGSize(width: qm_screen_W, height: imgView.bounds.height / imgView.bounds.width * qm_screen_W)
            imgView.center = scrollview.center
        }
        if imgView.bounds.height > qm_screen_H{
            imgView.frame.size = CGSize(width: qm_screen_H, height: imgView.bounds.width / imgView.bounds.height * qm_screen_H)
            imgView.center = scrollview.center
        }
        
        view.addSubview(scrollview)
        scrollview.addSubview(imgView)
        
        adjustScrollView()
        view.addSubview(cameraButton)
        view.addSubview(nextButton)
    }

    /// 绘制选择框
    fileprivate func drawTheRect(){
        
        // 获取上下文 size表示图片大小 false表示透明 0表示自动适配屏幕大小
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor)
        context?.fill(UIScreen.main.bounds)
        context?.addRect(CGRect(x: 0, y: (qm_screen_H - selectHeight)/2, width: qm_screen_W , height: selectHeight))
        context?.setBlendMode(.clear)
        context?.fillPath()
        
        // 绘制框框
        context?.setBlendMode(.color)
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(1.0)
        context?.stroke(CGRect(x: 0, y: (qm_screen_H - selectHeight)/2 - lineWidth , width: qm_screen_W , height: selectHeight + 2*lineWidth))
        context?.strokePath()
        
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let selectarea = UIImageView(image: img)
        selectarea.frame.origin = CGPoint(x: 0, y: 0)
        view.addSubview(selectarea)
        view.bringSubview(toFront: cameraButton)
        view.bringSubview(toFront: nextButton)
    }
    
}

// MARK: - 代理方法
extension QMClipperViewController:UIScrollViewDelegate{

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //当捏或移动时，需要对center重新定义以达到正确显示位置
        var centerX = scrollView.center.x
        var centerY = scrollView.center.y
        centerX = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width / 2 : centerX
        centerY = scrollView.contentSize.height > scrollView.frame.size.height ?scrollView.contentSize.height / 2 : centerY
        self.imgView?.center = CGPoint(x: centerX, y: centerY)
        adjustScrollView()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
    
}

// MARK: - 监听
extension QMClipperViewController{
    
    @objc fileprivate func cameraClicked() {
        var vc = self.presentingViewController
        while ((vc?.isKind(of: QMCameraViewController.self)) == false) {
            vc = vc?.presentingViewController
        }
        vc?.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func submitClicked() {
        let result = clipImage() ?? UIImage()
        delegate?.didFinishClippingPhoto(image: result)
        var vc = self.presentingViewController
        while ((vc?.isKind(of: QMCameraViewController.self)) == false) {
            vc = vc?.presentingViewController
        }
        vc = vc?.presentingViewController
        vc?.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func adjustScrollView() {
        guard let imgView = imgView else {
            return
        }
        if imgView.frame.size.height > qm_screen_H {
            let offsetTop = (qm_screen_H - selectHeight)/2
            let contentSizeHeight = offsetTop + (imgView.frame.size.height-qm_screen_H)
            scrollview.contentSize = CGSize(width: imgView.frame.width, height: qm_screen_H + contentSizeHeight)
            scrollview.contentInset = UIEdgeInsets(top: offsetTop, left: 0, bottom: 0, right:0)
        } else if imgView.frame.size.height > selectHeight {
            let offsetTop = (imgView.frame.size.height - selectHeight)/2
            scrollview.contentSize = CGSize(width: imgView.frame.width, height: qm_screen_H + offsetTop)
            scrollview.contentInset = UIEdgeInsets(top: offsetTop, left: 0, bottom: 0, right: 0)
        } else {
            scrollview.contentSize = CGSize(width: qm_screen_W, height: qm_screen_H)
        }
    }
    fileprivate func clipImage()->UIImage?{
        
        let rect  = UIScreen.main.bounds
        
        // 记录屏幕缩放比
        let scal = UIScreen.main.scale
        
        // 上下文
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        
        let context = UIGraphicsGetCurrentContext()
        
        UIApplication.shared.keyWindow?.layer.render(in: context!)
        // 截全屏
        guard let img = UIGraphicsGetImageFromCurrentImageContext()?.cgImage,
            let result = img.cropping(to: CGRect(x: scal * lineWidth, y: (qm_screen_H - selectHeight)/2 * scal, width: (qm_screen_W - 2*lineWidth) * scal, height: selectHeight * scal))   else{
                return nil
        }
        // 关闭上下文
        UIGraphicsEndImageContext()
        return UIImage(cgImage: result, scale: scal, orientation: .up)
        
    }

}
