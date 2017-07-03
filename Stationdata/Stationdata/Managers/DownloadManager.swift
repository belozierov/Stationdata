//
//  DownloadManager.swift
//  Stationdata
//
//  Created by Beloizerov on 23.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import Foundation

final class DownloadManager: NSObject, URLSessionDownloadDelegate, URLSessionDataDelegate {
    
    private static let manager = DownloadManager()
    
    class func download(request: URLRequest, completion: @escaping (Data?, URLResponse?) -> ()) {
        guard let url = request.url else { return }
        let key = url.absoluteString
        manager.activeDownloads[key]?.cancel()
        let task = !url.pathExtension.isEmpty
            ? manager.session.downloadTask(with: request)
            : manager.session.dataTask(with: request)
        task.taskDescription = key
        manager.activeDownloads[key] = TaskWrapper(task: task, completion: completion)
        task.resume()
    }
    
    // MARK: - URLSession
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "DownloadManager")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    // MARK: - TaskWrapper
    
    private struct TaskWrapper {
        
        let task: URLSessionTask
        let completion: (Data?, URLResponse?) -> ()
        
        func cancel() {
            task.cancel()
            completion(nil, nil)
        }
        
    }
    
    private var activeDownloads = [String: TaskWrapper]()
    
    // MARK: - URLSessionTaskDelegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        }
    }
    
    // MARK: - URLSessionDataDelegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let key = dataTask.taskDescription else { return }
        activeDownloads[key]?.completion(data, nil)
        activeDownloads[key] = nil
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        guard let key = dataTask.taskDescription else { return }
        activeDownloads[key]?.completion(nil, response)
        completionHandler(.allow)
    }
    
    // MARK: - URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let key = downloadTask.taskDescription, let wrapper = activeDownloads[key] else { return }
        activeDownloads[key] = nil
        do { wrapper.completion(try Data(contentsOf: location), downloadTask.response) }
        catch { wrapper.completion(nil, nil) }
        do { try FileManager.default.removeItem(at: location) } catch {}
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let key = task.taskDescription else { return }
        activeDownloads[key]?.completion(nil, nil)
        activeDownloads[key] = nil
    }
    
}
