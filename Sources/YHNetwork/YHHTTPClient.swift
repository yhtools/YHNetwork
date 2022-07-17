//
//  YHTTPClient.swift
//  
//
//  Created by 莹 on 2022/7/7.
//

import Foundation
import Alamofire

public class YHHTTPClient {
    
    public static let shared = YHHTTPClient()
    private var requests = [YHRequest]()

    public func add(request:YHRequest) {
        
        requests.append(request)
        if let handler = request.multipartFormDataHandler() {
            
            let uploadRequest = AF.upload(multipartFormData: handler, to: request.requestUrl).redirect(using: request.redirect())
            request.set(dataRequest: uploadRequest)
            handleRequest(request: request, dataRequest: uploadRequest)
        }
        else {
            
            let dataRequest = AF.request(request.requestUrl, method: request.requestMethod(), parameters: request.requestParameters(), encoding: request.requestParametersEncoding(), headers: request.requestHeaders()).redirect(using: request.redirect())
            request.set(dataRequest: dataRequest)
            handleRequest(request: request, dataRequest: dataRequest)
        }
    }
    
    public func cancel() {
        
        for request in requests {
            request.cancel()
        }
    }
    
    private func handleRequest(request:YHRequest,dataRequest:DataRequest) {
        
        dataRequest.responseString(completionHandler: {
            [unowned self]
            dataResponse in
            self.handleResponse(request: request, dataResponse: dataResponse)
        })
    }
    
    private func handleResponse(request:YHRequest,dataResponse:AFDataResponse<String>? = nil) {
        
        request.set(dataResponse: dataResponse)
    }
}
