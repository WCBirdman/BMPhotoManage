//
//  QMCameraViewController.swift
//  QMEnglish
//
//  Created by xmly on 2022/3/22.
//

import UIKit
import AVFoundation
import Photos
import MobileCoreServices

//MARK: -- life cycle
extension QMCameraViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(backBtn)
        view.addSubview(cameraPickerController.view)
        setupUI()
        configFrame()
    }
    func setupUI() {
        
        view.addSubview(topBlackView)
        view.addSubview(cameraPickerController.view)
        view.addSubview(bottomBlackView)
        
        topBlackView.addSubview(backBtn)
        cameraPickerController.cameraOverlayView = cameraOverlayView
        cameraOverlayView.addSubview(bottomBlackView)
        
        bottomBlackView.addSubview(photoBtn)
        bottomBlackView.addSubview(cameraBtn)
        bottomBlackView.addSubview(reverseBtn)
        
    }
    func configFrame() {
       
        let allBlackHeight = qm_screen_H - cameraH - qm_status_H
        let topBlackHeight = allBlackHeight * 0.25 + qm_status_H
        let bottomBlckHeight = allBlackHeight * 0.75
        topBlackView.frame = CGRect(x: 0, y: 0, width: qm_screen_W, height: topBlackHeight)
        
        cameraPickerController.view.frame = CGRect(x: 0, y: topBlackHeight, width: qm_screen_W, height: qm_screen_H - topBlackHeight)
        cameraOverlayView.frame = cameraPickerController.view.bounds
        bottomBlackView.frame = CGRect(x: 0, y: cameraOverlayView.frame.size.height - bottomBlckHeight, width: qm_screen_W, height: bottomBlckHeight)
        backBtn.frame = CGRect(x: 18*qm_whole_scale, y: qm_status_H + 4*qm_whole_scale, width: 32*qm_iPad_scale, height: 32*qm_iPad_scale)
        
        photoBtn.frame = CGRect(x: 20, y: (bottomBlckHeight-44*qm_iPad_scale)/2.0, width: 44*qm_iPad_scale, height: 44*qm_iPad_scale)
        
        cameraBtn.frame = CGRect(x: (qm_screen_W-69*qm_iPad_scale)/2.0, y: (bottomBlckHeight-69*qm_iPad_scale)/2.0, width: 69*qm_iPad_scale, height: 69*qm_iPad_scale)
        
        reverseBtn.frame = CGRect(x: qm_screen_W-20-44*qm_iPad_scale, y: (bottomBlckHeight-44*qm_iPad_scale)/2.0, width: 44*qm_iPad_scale, height: 44*qm_iPad_scale)

    }
}

//MARK: -- private method
extension QMCameraViewController {
    @objc private func goBack() {
        self.dismiss(animated: true)
    }
    @objc private func cameraClick() {
        cameraPickerController.takePicture()
    }
    @objc private func photoClick() {
        if !checkPhotoAuthStatus() {
            return
        }
        present(photoPickerController, animated: true)
    }
    @objc private func reverseClick() {
        if cameraPickerController.cameraDevice == .rear {
            cameraPickerController.cameraDevice = .front
        } else {
            cameraPickerController.cameraDevice = .rear
        }
    }
    private func checkPhotoAuthStatus() -> Bool {
        let photoAuthStatus = PHPhotoLibrary.authorizationStatus()
        if photoAuthStatus == .notDetermined { //未授权
            PHPhotoLibrary.requestAuthorization { _ in
            }
        } else if (photoAuthStatus == .restricted || photoAuthStatus == .denied) {//拒绝
            let  alertVc = UIAlertController(title: "", message: "你还没有开启相册权限，请去\"设置-权限\" 开启该权限并使用该功能", preferredStyle: .alert)
            let sureAction = UIAlertAction(title: "去设置", style: .default) { _ in
                guard let url = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    
                }
            }
            alertVc.addAction(sureAction)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel)
            alertVc.addAction(cancelAction)
            self.present(alertVc, animated: true, completion: nil)
            return false
        }
        return true
    }
}


//MARK: -- delegate
extension QMCameraViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate,QMClipperPhotoDelegate {
    //选择后的照片
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage as UIImagePickerController.InfoKey] as? UIImage else {
            return
        }
        let clipper = QMClipperViewController()
        clipper.delegate = self
        clipper.img = image
        clipper.modalPresentationStyle = .fullScreen
        if picker == photoPickerController {
            picker.present(clipper, animated: true, completion: nil)
        } else {
            present(clipper, animated: true, completion: nil)
        }
    }
    //裁剪后的照片
    func didFinishClippingPhoto(image: UIImage) {
        delegate?.didFinishClippingPhoto(image: image)
    }
}

class QMCameraViewController: UIViewController {
    let cameraH = qm_screen_W * 4 / 3.0
    var delegate:QMClipperPhotoDelegate?
    private lazy var topBlackView: UIView = {
        return UIView()
    }()
    
    private lazy var bottomBlackView: UIView = {
        return UIView()
    }()
    
    private lazy var cameraOverlayView: UIView = {
        return UIView()
    }()
    
    private lazy var backBtn: UIImageView = {
        let btn = UIImageView()
        btn.image = UIImage.init(named: "icon_back")
        btn.isUserInteractionEnabled = true
        btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goBack)))
        return btn
    }()
    private lazy var photoBtn: UIImageView = {
        let btn = UIImageView()
        btn.image = UIImage.init(named: "icon_photo")
        btn.isUserInteractionEnabled = true
        btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photoClick)))
        return btn
    }()
    private lazy var cameraBtn: UIImageView = {
        let btn = UIImageView()
        btn.image = UIImage.init(named: "icon_take")
        btn.isUserInteractionEnabled = true
        btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cameraClick)))
        return btn
    }()
    private lazy var reverseBtn: UIImageView = {
        let btn = UIImageView()
        btn.image = UIImage.init(named: "icon_reverse")
        btn.isUserInteractionEnabled = true
        btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(reverseClick)))
        return btn
    }()
    
    private lazy var cameraPickerController: UIImagePickerController = {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.sourceType = .camera
        vc.mediaTypes = [kUTTypeImage as String]
        vc.cameraCaptureMode = .photo
        vc.showsCameraControls = false
        vc.cameraViewTransform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    private lazy var photoPickerController: UIImagePickerController = {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.sourceType = .photoLibrary
        vc.mediaTypes = [kUTTypeImage as String]
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
}

