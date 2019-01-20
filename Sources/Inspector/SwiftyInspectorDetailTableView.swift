//
//
// Swifty (https://github.com/Flipkart/Swifty)
//
// Copyright 2017 Flipkart Internet Pvt. Ltd.
// Apache License
// Version 2.0, January 2004
//
// See https://github.com/Flipkart/Swifty/blob/master/LICENSE for the full license
//


/*
 Request - URL, Method, Headers
 Response - Headers, Mime, Content-Length, Encoding, Body
 Metrics - All Of Them
*/

#if os(iOS)
import Foundation
import UIKit

@available(iOS 10.0, *)
class SwiftyInspectorDetailTableView: UITableViewController {
    
    var metric: NetworkResourceMetric!
    let sectionTitles = ["Request", "Response", "Metrics"]
    
    var sectionModel: [[String]] {
        
        let task = self.metric.task
        let metrics = self.metric.metrics
        
        var model = [[String]]()
        
        /// Request
        var requestHeaders: String = ""
        var contentType: String?
        if let headers = task.currentRequest?.allHTTPHeaderFields {
            for (_, key) in headers.keys.enumerated() {
                requestHeaders.append("\(key): \(headers[key]!)\n")
                if(key == "Content-Type") {
                    contentType = headers[key]
                }
            }
        }
        
        var requestModel = [task.currentRequest!.url!.absoluteString, task.currentRequest!.httpMethod!, requestHeaders]
        
        if let contentType = contentType {
            switch contentType {
            case "application/json":
                if let bodyData = task.originalRequest?.httpBody {
                    if let json = try? JSONSerialization.jsonObject(with: bodyData, options: .allowFragments) {
                        if let prettyJsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                            if let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) {
                                requestModel.append(prettyPrintedJson)
                            }
                        }
                    }
                }
            case "application/x-www-form-urlencoded":
                if let queryData = task.originalRequest?.httpBody {
                    if let queryString = String(data: queryData, encoding: .utf8) {
                        requestModel.append(queryString)
                    }
                }
            default:
                break
            }
        }
        model.append(requestModel)
        
        guard let transactionMetric = metrics.transactionMetrics.first else {
            return model
        }
        
        /// Response
        if let response = transactionMetric.response {
            let responseMimeType = response.mimeType ?? "Unknown Mime-Type"
            let responseLength = "Expected Content-Length: \(response.expectedContentLength)"
            let responseEncoding = response.textEncodingName ?? "Unknown Response Encoding"
            
            var responseModel: [String] = [responseLength, responseEncoding, responseMimeType]
            
            if let urlResponse = transactionMetric.response as? HTTPURLResponse {
                var requestHeaders: String = ""
                for (_, key) in urlResponse.allHeaderFields.keys.enumerated() {
                    requestHeaders.append("\(key): \(urlResponse.allHeaderFields[key]!)\n")
                }
                let statusCode = "Status: \(urlResponse.statusCode)"
                responseModel.insert(statusCode, at: 0)
                responseModel.append(requestHeaders)
            }
            model.append(responseModel)
        }
        
        /// Metrics
        let isReused = "Connection Status: " + (transactionMetric.isReusedConnection ? "Reused Connection" : "New Connection")
        let fetchType = "Fetch Type: " + transactionMetric.resourceFetchType.displayString
        let connectionTime = "Connection Time: \( transactionMetric.connectTime ?? 0) ms"
        let domainLookupTime = "Domain Lookup: \( transactionMetric.domainLookupTime ?? 0) ms"
        let secureConnectionTime = "Secure Connection Time: \( transactionMetric.secureConnectionTime ?? 0) ms"
        let requestTime = "Request Time: \( round(transactionMetric.requestTime ?? 0)) ms"
        let responseTime = "Response Time: \( round(transactionMetric.responseTime ?? 0)) ms"
        let metricsModel: [String] = [isReused, fetchType, connectionTime, domainLookupTime, secureConnectionTime, requestTime, responseTime]
        model.append(metricsModel)
        
        
        return model
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.estimatedRowHeight = 80
    }
    
    init(metric: NetworkResourceMetric) {
        self.metric = metric
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionModel.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionModel[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = self.sectionModel[indexPath.section][indexPath.row]
        
        if((indexPath.section == 0 && indexPath.row == 3) || (indexPath.section == 1 && indexPath.row == 5)) {
            cell.textLabel?.font = UIFont(name: "Menlo-Regular", size: 16)
        }
        else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

#endif
