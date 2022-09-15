//
//  YHDownload.swift
//  
//
//  Created by 莹 on 2022/9/15.
//

import Foundation
import Alamofire

public class YHDownload {
    
    public static let shared = YHDownload()
    private var downloadModels = [YHDownloadModel]()
    private var downloadings = Set<YHDownloadModel>()
    public var maxCount = 5
    private init(){}
    
    public func add(downloadModels:[YHDownloadModel]) {
        
        downloadModels.forEach({
            [unowned self]
            downloadModel in
            
            add(downloadModel: downloadModel)
        })
    }
    
    public func add(downloadModel:YHDownloadModel) {
        
        downloadModels.append(downloadModel)
        download()
    }
    
    private func download() {
        
        if downloadings.count < maxCount, downloadModels.count > 0 {
            
            downloadFromNetwork(downloadModels.removeFirst())
        }
    }
    
    private func downloadFromNetwork(_ downloadModel:YHDownloadModel) {
        
        downloadings.insert(downloadModel)
        downloadModel.progress = AF.download(downloadModel.getSrc(), to: {[unowned self] _,response in
            return (documentURL(path: response.url?.lastPathComponent),[.removePreviousFile, .createIntermediateDirectories])})
            .response {
                [unowned self]
                response in
        
                downloadings.remove(downloadModel)
                self.download()
            }.downloadProgress
    }
    
    private func documentURL(path:String?) -> URL {
        
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if let tempPath = path {
            
            return documentURL.appendingPathComponent(tempPath)
        }
        
        return documentURL
    }
    
}

open class YHDownloadModel: Hashable {
    
    public var progress:Progress?
    
    public static func == (lhs: YHDownloadModel, rhs: YHDownloadModel) -> Bool {
        return lhs.getSrc() == rhs.getSrc()
    }
    
    open func getSrc() -> String {
        return ""
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(getSrc())
    }
    
}
