//
//  WanikaniApi.swift
//  WanikaniSaver
//
//  Created by Brandon Thomas on 6/27/19.
//  Copyright © 2019 Brandon Thomas. All rights reserved.
//

import Alamofire
import RateLimit
import SwiftDate
import SwiftyJSON

class WanikaniApi {
    
    class AccountState {
        var currentLevel: Int = 0
        var immediateReviewCount: Int = 0
    }
    
    let apiKey: String
    let rateLimiter: TimedLimiter
    var accountState: AccountState?
    var requestedAt: Date?
    
    init(api_key: String) {
        requestedAt = Optional.none
        rateLimiter = TimedLimiter(limit: 1)
        accountState = Optional.none
        self.apiKey = api_key
    }
    
    public func getAccountState() -> Optional<AccountState> {
        return accountState
    }
    
    public func update() {
        rateLimiter.execute {
            // refreshUser()
            refreshSummary()
        }
    }
    
    private func refreshUser() {
        let headers = getHeaders()
        
        Alamofire.request("https://api.wanikani.com/v2/user", headers: headers).responseData { response in
            if let status = response.response?.statusCode {
                switch (status) {
                case 200:
                    break;
                default:
                    debugPrint("Bad response code: \(status)")
                }
            }

            if let j = response.result.value {
                do {
                    let json = try JSON.init(data: j);
                    let currentLevel = json["data"]["level"].intValue
                    
                    if let state  = self.accountState {
                        state.currentLevel = currentLevel
                    }
                } catch {
                    debugPrint("Failure to parse user")
                }
            }
        }
    }
    
    private func refreshSummary() {
        let headers = getHeaders()
        
        Alamofire.request("https://api.wanikani.com/v2/summary", headers: headers).responseData { response in
            if let j = response.result.value {
                if let status = response.response?.statusCode {
                    switch (status) {
                    case 200:
                        debugPrint("Good response: \(status)")
                        break;
                    default:
                        debugPrint("Bad response code: \(status)")
                    }
                }
                
                do {
                    let json = try JSON.init(data: j);
                    
                    debugPrint("JSON: \(json)")

                    // let nextReviewTimestamp = json["data"]["next_reviews_at"].stringValue
                    // let nextReviewDate = nextReviewTimestamp.toDate()
                    let immediateReviewCount = json["data"]["reviews"][0]["subject_ids"].count

                    if let state = self.accountState {
                        state.immediateReviewCount = immediateReviewCount
                    } else {
                        let state = AccountState.init()
                        state.immediateReviewCount = immediateReviewCount
                        self.accountState = state
                    }
                } catch {
                    debugPrint("Failure to parse summary")
                }
            }
        }
    }
    
    private func getHeaders() -> HTTPHeaders {
        return [
            "Wanikani-Revision": "20170710",
            "Authorization": "Bearer " + apiKey
        ]
    }
}
