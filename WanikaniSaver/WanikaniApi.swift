//
//  WanikaniApi.swift
//  WanikaniSaver
//
//  Created by Brandon Thomas on 6/27/19.
//  Copyright © 2019 Brandon Thomas. All rights reserved.
//

import Alamofire

class WanikaniApi {
    var requested_at: Optional<Date>
    
    init() {
        requested_at = Optional.none
    }
    
    public func update() {
        guard let myObject = MyObject(dependency: xyz) else {
            print("This thing is nil")
            return
        }
    }
    
    public func call() {
        let headers: HTTPHeaders = [
            "Wanikani-Revision": "20170710",
            "Authorization": "Bearer "
        ]
        
        AF.request("https://api.wanikani.com/v2/user", headers: headers).responseJSON { response in
            debugPrint(response)
        }
    }
}
