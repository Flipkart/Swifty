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

#if os(iOS)
import Foundation
import UIKit


@available(iOS 10.0, *)
struct NetworkResourceMetric {
    let task: URLSessionTask
    let metrics: URLSessionTaskMetrics
}

/**
 Swifty Inspector is way to view the log of all requests that have gone through Swifty, and view their request and response parameters, including their `URLSessionTaskMetrics`.
 
 To show the Swifty Inspector, present the `UINavigationController` returned from the `SwiftyInspecter.shared.presentableInspector()` method.
 
 > Swifty Inspector only collects and displays information in the `DEBUG` compiler configuration.
 > Only available on iOS 10+.
 */
@available(iOS 10.0, *)
@objc public final class SwiftyInspector: UITableViewController {
    
    /**
     The shared instance of the Swifty Inspector.
    */
    @objc public static let shared = SwiftyInspector()
    
    /**
     Get the Swifty Inspector's View Controller.
     
    - Returns: UINavigationController - The `SwiftyInspector's UIViewController` wrapped in a `UINavigationController`
    */
    @objc public static func presentableInspector() -> UINavigationController {
        return UINavigationController(rootViewController: SwiftyInspector.shared)
    }
    
    var metrics = [NetworkResourceMetric]()
    
    func add(_ metric: NetworkResourceMetric) {
        self.metrics.insert(metric, at: 0)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    /// :nodoc:
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView = UITableView(frame: self.view.frame, style: .grouped)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SwiftyInspector.closeViewController))
        
        title = "Swifty Inspector"
    }
    
    @objc func closeViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// :nodoc:
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Network Requests: Latest First"
    }
    
    /// :nodoc:
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// :nodoc:
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metrics.count
    }
    
    /// :nodoc:
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        let metric = metrics[indexPath.row]
        
        cell.textLabel?.text = metric.task.currentRequest?.url?.absoluteString
        cell.textLabel?.numberOfLines = 0
        
        
        var statusCode = "Unknown"
        if let urlResponse = metric.task.response as? HTTPURLResponse {
            statusCode = String(urlResponse.statusCode)
        }
        
        let detailText = " Status Code: \(statusCode) RTT:  \(round(metric.metrics.taskInterval.duration * 1000)) ms "
        
        cell.detailTextLabel?.text = detailText
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.isOpaque = true
        cell.detailTextLabel?.textColor = .white
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        
        return cell
    }
    
    /// :nodoc:
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    /// :nodoc:
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = SwiftyInspectorDetailTableView(metric: self.metrics[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
    
    /// :nodoc:
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let metric = metrics[indexPath.row]
        
        var statusCode = "Unknown"
        if let urlResponse = metric.task.response as? HTTPURLResponse {
            statusCode = String(urlResponse.statusCode)
        }
        
        cell.detailTextLabel?.backgroundColor = UIColor(hex: "c0392b")
        
        if let intStatus = Int(statusCode){
            if intStatus/100 == 2 {
                cell.detailTextLabel?.backgroundColor = UIColor(hex: "2ecc71")
            }
        }
        
        cell.detailTextLabel?.layer.cornerRadius = 2
        cell.detailTextLabel?.clipsToBounds = true
    }
    
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

#endif
