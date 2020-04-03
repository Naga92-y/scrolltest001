//
//  TimeLineCreate.swift
//  scrollTest01
//
//  Created by Yuta Nagaiwa on 2020/04/03.
//  Copyright © 2020 yutanagaiwa. All rights reserved.
//

import UIKit
import ObjectMapper

// リクエスト用クラス
class TimeLineCreateRequest: Mappable {
  var uuid: String?
  var image_1: UIImage!
  var image_2: UIImage?
  var image_3: UIImage?
  var image_4: UIImage?
  var image_5: UIImage?
  var message: String?
  func setImage(images:[UIImage]) {
    image_1 = images[0]
    if images.count > 1 {
      image_2 = images[1]
    }
    if images.count > 2 {
      image_3 = images[2]
    }
    if images.count > 3 {
      image_4 = images[3]
    }
    if images.count > 4 {
      image_5 = images[4]
    }
  }
  init(){}
    required init?(map: Map) {}
    func mapping(map: Map) {
    uuid <- map["uuid"]
    image_1 <- map["image_1"]
    image_2 <- map["image_2"]
    image_3 <- map["image_3"]
    image_4 <- map["image_4"]
    image_5 <- map["image_5"]
    message <- map["message"]
    }
}
// レスポンス用構造体
struct TimeLineCreateResponse: Codable {
  let success: Bool?
  let message: String?
  let data: TimeLine?
}
