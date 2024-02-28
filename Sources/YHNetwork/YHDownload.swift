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
    public var delegate:YHDownloadDelegate?
    public var userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36"
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
        downloadModel.progress = AF.download(downloadModel.getSrc(), headers: HTTPHeaders(["User-Agent":userAgent]), to: {_,response in
            return (downloadModel.getFileURL(),[.removePreviousFile, .createIntermediateDirectories])})
            .response {
                [unowned self]
                response in
        
                delegate?.downloadCompleted(url: downloadModel.getFileURL())
                downloadings.remove(downloadModel)
                self.download()
            }.downloadProgress
    }
    
    
}

open class YHDownloadModel: Hashable {
    
    public var progress:Progress?
    
    public init(progress: Progress? = nil) {
        self.progress = progress
    }
    
    public static func == (lhs: YHDownloadModel, rhs: YHDownloadModel) -> Bool {
        return lhs.getSrc() == rhs.getSrc()
    }
    
    open func getSrc() -> String {
        return ""
    }
    
    open func getFileName() -> String {
        return URL(string: getSrc())!.lastPathComponent
    }
    
    open func getFileURL() -> URL {
        
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentURL.appendingPathComponent(getFileName())
    }
    
    open func downloadCompleted() -> Bool {
     
        return FileManager.default.fileExists(atPath: getFileURL().path)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(getSrc())
    }
    
}

public protocol YHDownloadDelegate {
    
    func downloadCompleted(url:URL);
}
