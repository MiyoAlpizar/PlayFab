//
//  PlayFabHelper.swift
//  PlayFab
//
//  Created by Miyo Alpízar on 15/10/20.
//

import Foundation
import Alamofire

struct PlayFabLogin: Codable {
    var CreateAccount: Bool
    var DeviceId: String?
    var DeviceModel: String
    var OS: String
    var TitleId: String
    
    init(TitleID: String) {
        CreateAccount = true
        DeviceId = nil
        DeviceModel = ""
        OS = ""
        TitleId = TitleID
    }
    
}

struct LoginResult: Codable {
    let EntityToken: EntityTokenResponse
    let LastLoginTime: String
    let NewlyCreated: Bool
    let PlayFabId: String
    let SessionTicket: String
}

struct EntityTokenResponse: Codable {
    let Entity: EntityKey
    let EntityToken: String
    let TokenExpiration: String
}

struct EntityKey : Codable {
    let Id: String
}

class PlayFabHelper {
    
    private let TITLEID = "62E19"

    func getAppInfo()->String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return version + "(" + build + ")"
    }
    
    
    func Test() {
       
    }
    
    
    func LoginWithIOSDeviceID(completion: @escaping(Result<LoginResult, Error>)-> Void){
        var params = PlayFabLogin(TitleID: TITLEID)
        params.DeviceId = UIDevice.current.identifierForVendor?.uuidString
        params.OS = getAppInfo()
        print(params)
        AF.request("https://titleId.playfabapi.com/Client/LoginWithIOSDeviceID", method: HTTPMethod.post, parameters: params, encoder: URLEncodedFormParameterEncoder.default, headers: nil, interceptor: nil, requestModifier: nil).response { (response) in
            DispatchQueue.global(qos: .background).async {
                if let data = response.data {
                    do {
                        let codable = try JSONDecoder().decode(LoginResult.self, from: data)
                        DispatchQueue.main.async {
                            completion(.success(codable))
                        }
                    }catch {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }else if let error = response.error {
                    completion(.failure(error))
                }else {
                    completion(.failure(NSError(domain: "Something wrong happend", code: 100, userInfo: nil)))
                }
                
            }
        }
    }
    
}
