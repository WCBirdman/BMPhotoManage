//
//  QMCameraPhotoTool.swift
//  QMEnglish
//
//  Created by xmly on 2022/3/19.
//

import UIKit
import AVFoundation
import Photos
import MobileCoreServices

typealias ClicpPhotoBlock = (UIImage?) -> Void

//MARK: public method
extension QMPhotoManage {
    
    public static let shared = QMPhotoManage()

    public func show(_ fromViewController: UIViewController, _ clicpPhotoBlock: @escaping ClicpPhotoBlock) {
        self.fromViewController = fromViewController
        self.clicpPhotoBlock = clicpPhotoBlock
        openCamera()
    }
}

//MARK: private method
extension QMPhotoManage {
    private func checkCameraAuthStatus() -> Bool {
       let cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
       if cameraAuthStatus == .notDetermined { //未授权
           print("notDetermined")
           AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] granted in
               print("notDetermined\(granted)")
               if granted {
                   DispatchQueue.main.async {
                       self?.gotoCamera()
                   }
               }
           }
       } else if cameraAuthStatus == .restricted || cameraAuthStatus == .denied { //拒绝
           let  alertVc = UIAlertController(title: "", message: "你还没有开启相机权限，请去\"设置-权限\" 开启该权限并使用该功能", preferredStyle: .alert)
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
           return false
       }
       return cameraAuthStatus == .authorized
   }
}
class QMPhotoManage: QMClipperPhotoDelegate {
    
    private var fromViewController: UIViewController!
    private var clicpPhotoBlock: ClicpPhotoBlock?
    
    public func openCamera() {
        
        if !checkCameraAuthStatus() {
            return
        }
        gotoCamera()
    }
    func gotoCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let vc = QMCameraViewController()
            vc.delegate = self
            vc.modalPresentationStyle = .fullScreen
            fromViewController.present(vc, animated: true)
        } else {
            let  alertVc = UIAlertController(title: "提示", message: "相机不可用", preferredStyle: .alert)
            let sureAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            alertVc.addAction(sureAction)
            fromViewController.present(alertVc, animated: true, completion: nil)
        }
    }
    //裁剪后的照片
    func didFinishClippingPhoto(image: UIImage) {
        if let clicpPhotoBlock = clicpPhotoBlock {
            clicpPhotoBlock(image)
        }
    }
}
