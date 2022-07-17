//
//  YHRequest.swift
//  
//
//  Created by 莹 on 2022/7/7.
//

import Foundation
import Alamofire

public typealias MultipartFormDataHandler = (_ multipartFormData:MultipartFormData) -> Void
public typealias YHHTTPCompletion = (_ request:YHRequest) -> Void

open class YHRequest: NSObject {
    
    public private(set) var dataRequest:DataRequest?
    public private(set) var dataResponse:AFDataResponse<String>?
    public private(set) var uploadRequest:UploadRequest?
    public private(set) var error:Error?
    public private(set) var responseString:String?
    public private(set) var responseJson:[String:Any]?
    public private(set) var httpCompletion:YHHTTPCompletion?
    public private(set) var startTime:Double = 0
    public private(set) var cookies:String?

    public init(httpCompletion:YHHTTPCompletion?) {
        self.httpCompletion = httpCompletion
    }
    
    public final var requestUrl:String {
        
        var tempBaseUrl = baseUrl()
        var tempApiUrl = apiUrl()

        if tempBaseUrl.last == "/"{
            tempBaseUrl.removeLast()
        }
        
        if tempApiUrl.first == "/" {
            tempApiUrl.removeFirst()
        }
        return "\(tempBaseUrl)/\(tempApiUrl)"
    }
    
    open func baseUrl() -> String {
        return ""
    }

    open func apiUrl() -> String {
        return ""
    }
    
    open func requestMethod() -> HTTPMethod {
        return .get
    }
    
    open func requestHeaders() -> HTTPHeaders? {
        return nil
    }
    
    open func requestParameters() -> Parameters? {
        return nil
    }
    
    open func requestParametersEncoding() -> ParameterEncoding {
        return URLEncoding.default
    }
    
    open func multipartFormDataHandler() -> MultipartFormDataHandler? {
        return nil
    }
    
    open func onSucceed(object:Any?) {}
    
    open func onFailed() {}
    
    open func handleReponseObject() -> Any? {
        return responseJson
    }
    
    public final func cancel() {
        dataRequest?.task?.cancel()
    }
    
    public final func start() {
        
        YHHTTPClient.shared.add(request: self)
        startTime = Date().timeIntervalSince1970
    }
    
    final func set(dataRequest:DataRequest?) {
        self.dataRequest = dataRequest
    }
    
    open func handleResponse() {
        
        onSucceed(object: handleReponseObject())
    }
    
    final func set(dataResponse:AFDataResponse<String>?) {
        
        self.dataResponse = dataResponse
        if let response = dataResponse {
            
            cookies = response.response?.allHeaderFields["Set-Cookie"] as? String
            switch response.result {
            case .success:
                responseString = response.value
                if responseString != nil {
                    responseJson = try? JSONSerialization.jsonObject(with: responseString!.data(using: .utf8)!, options:JSONSerialization.ReadingOptions.allowFragments) as? [String : Any]
                }
                handleResponse()
            case .failure:
                set(error: response.error)
            }
        }

        if error != nil {
            onFailed()
        }
        
        httpCompletion?(self)
    }
    
    final func set(uploadRequest:UploadRequest?) {
        self.uploadRequest = uploadRequest
    }
    
    public final func set(error:Error?) {
        self.error = error
    }
    
    open func redirect() -> Redirector {
        return .follow
    }
}
