//
//  SwiftyInspector.swift
//  Pods
//
//  Created by Siddharth Gupta on 01/05/17.
//
//

import Foundation

@available(iOS 10.0, *)
public struct NetworkResourceMetric {
    let task: URLSessionTask
    let metrics: URLSessionTaskMetrics
}

@available(iOS 10.0, *)
public class SwiftyInspector: UITableViewController {
    
    public static let shared = SwiftyInspector()
    
    public static func presentableInspector() -> UINavigationController {
        return UINavigationController(rootViewController: SwiftyInspector.shared)
    }
    
    var metrics = [NetworkResourceMetric]()
    
    public func add(_ metric: NetworkResourceMetric) {
        self.metrics.insert(metric, at: 0)
        self.tableView.reloadData()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView = UITableView(frame: self.view.frame, style: .grouped)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SwiftyInspector.closeViewController))
        
        title = "Swifty Inspector"
    }
    
    func closeViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Network Requests: Latest First"
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metrics.count
    }
    
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
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = SwiftyInspectorDetailTableView(metric: self.metrics[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let metric = metrics[indexPath.row]
        
        var statusCode = "Unknown"
        if let urlResponse = metric.task.response as? HTTPURLResponse {
            statusCode = String(urlResponse.statusCode)
        }
        
        
        if let intStatus = Int(statusCode){
            if intStatus/100 == 2 {
                cell.detailTextLabel?.backgroundColor = UIColor(hex: "2ecc71")
            }
            else {
                cell.detailTextLabel?.backgroundColor = UIColor(hex: "c0392b")
            }
        }
        else {
            cell.detailTextLabel?.backgroundColor = UIColor(hex: "c0392b")
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
