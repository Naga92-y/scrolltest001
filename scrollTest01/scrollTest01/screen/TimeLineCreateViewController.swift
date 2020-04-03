//
//  TimeLineCreateViewController.swift
//  withcrew
//
//  Created by Yuta Nagaiwa on 2020/02/28.
//  Copyright © 2020 Developer. All rights reserved.
//

import UIKit
import ImageSlideshow

class TimeLineCreateViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate {
    
    // MARK:IBOutlet
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var imageSlideShow: ImageSlideshow!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var postTextViewHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Indicatorの場所
        imageSlideShow.pageIndicatorPosition = .init(horizontal: .center, vertical: .bottom)
        //画像のスケール
        imageSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
        //色などUIなど
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        imageSlideShow.pageIndicator = pageControl
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        imageSlideShow.activityIndicator = DefaultActivityIndicator()
        imageSlideShow.delegate = self as? ImageSlideshowDelegate
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(TimeLineCreateViewController.didTap))
        imageSlideShow.addGestureRecognizer(recognizer)
        
        //textViewの文字全消し
        postText.text = ""
        postText.becomeFirstResponder()
        
        //キーボードにUIViewを載せる固定する
        postText.inputAccessoryView = tabView
        
        // Notification発行
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        //pageが変わったらprintで表示される
        func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
            print("current page:", page)
        }
        
        postText.delegate = self
        
    }
    
    //textViewの高さを動的に変える
    func textViewDidChange(_ postText: UITextView) {
        let height = postText.sizeThatFits(CGSize(width: postText.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        postText.heightAnchor.constraint(equalToConstant: height).isActive = true
        scroll.heightAnchor.constraint(equalToConstant: height).isActive = true

        postText.sizeToFit()
        postTextViewHeight.constant = postText.contentSize.height
        
    }
    
    
    @objc private func didTap() {
        // set the activity indicator for full screen controller (フルスクリーンで表示されたときのindicatorの処理)
        let fullScreenController = imageSlideShow.presentFullScreenController(from: self)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    
    
    @IBAction func didTapBackBtn(_ sender: Any) {
        postText.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    //     TODO: 投稿したらTimeTableに遷移し投稿したものが表示
    @IBAction func didTapPostBtn(_ sender: Any) {
        postText.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        let request = TimeLineCreateRequest.init()
        
        request.uuid = uuid
        //どうやったらいいかわからない場所
        request.image_1 = imageSlideShow.images[0]
        request.image_2 = imageSlideShow.images[0]
        request.image_3 = imageSlideShow.images[0]
        request.image_4 = imageSlideShow.images[0]
        request.image_5 = imageSlideShow.images[0]
        
       
        
        var inputers: [InputSource] = imageSlideShow.images
        APIClient<TimeLineCreateResponse>().getApiResponse(type: .REQUEST_TIMELINE_CREATE, params: request.toJSON()) { (result) in
          switch result {
           case .Success(let response):
            DLog(message: "success")
            if response.data != nil {
              print("成功")
            }
            else {
              print("失敗")
            }
          default:
            print("失敗")
          }
        }

    }
    
    //     TODO: フォトライブラリーを下に表示・追加したらheight出す
    @IBAction func didTapAlbumBtn(_ sender: Any) {
        let ipc = UIImagePickerController()
        ipc.delegate = self
        ipc.sourceType = UIImagePickerController.SourceType.photoLibrary
        //編集を可能にする
        ipc.allowsEditing = true
        self.present(ipc,animated: true, completion: nil)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[UIImagePickerController.InfoKey.originalImage] != nil {
            let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
            
            //imageSlideShowに画像を追加
            let inputer: InputSource = {
                return ImageSource(image: image)
            }()
            
            var inputers: [InputSource] = imageSlideShow.images
            
            //[InputSource,InputSource,InputSource]
            
            inputers.append(inputer)
            
            //imageSlideShow.images.append(inputer)
            
            imageSlideShow.setImageInputs(inputers)
            
            if ((imageSlideShow?.images) != nil) {
                imageSlideShow.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.65).isActive = true
                
            }
            
            //更新
            imageSlideShow.reloadInputViews()
            
            view.layoutIfNeeded()
            
        }
        
        //編集機能を表示させない場合の処理
        //let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        //imageView.image = image
        
        dismiss(animated: true,completion: nil)
    }
    
    // TODO: comment押したらコメントできる実装
    @IBAction func didTapCameraBtn(_ sender: Any) {
        let pickerController = UIImagePickerController()
        //ソースタイプを指定
        pickerController.sourceType = .camera
        
        //カメラを表示
        present(pickerController, animated: true, completion: nil)
    }
    
    //キーボードでtextView隠れないようにする
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            postText.contentInset = .zero
            scroll.contentInset.bottom = .zero
            
        } else {
            scroll.contentInset.bottom = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
            postText.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height + view.safeAreaInsets.bottom + tabView.frame.height , right: 0)
        }
        postText.scrollIndicatorInsets = postText.contentInset
        let selectedRange = postText.selectedRange
        postText.scrollRangeToVisible(selectedRange)
    }
}

