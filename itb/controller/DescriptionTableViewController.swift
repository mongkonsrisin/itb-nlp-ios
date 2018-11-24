//
//  DescriptionTableViewController.swift
//  itb
//
//  Created by Mongkon Srisin on 11/23/18.
//  Copyright © 2018 Mongkon Srisin. All rights reserved.
//

import UIKit
import Alamofire

class DescriptionTableViewController: UITableViewController {

    let BASE_URL = "https://www.deksuan.com/itb/"
    var ids:[Int] = []
    var descriptions:[String] = []
    var imgId:Int = 0
    
    let sentimentService = SentimentService()
    let classificationService = ClassificationService()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadDB()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ids.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DescriptionTableViewCell
        cell.descriptionLabel.text = descriptions[indexPath.row]
        let emoji = showEmoji(sentiment: sentimentService.predictSentiment(from: descriptions[indexPath.row]).sentiment)
        let score = sentimentService.predictSentiment(from: descriptions[indexPath.row]).score
        cell.sentimentLabel.text = "\(emoji) (\(score))"
        if let cat = classificationService.classify(descriptions[indexPath.row])?.prediction {
            let cattext = cat.category.rawValue
            var emoji2 = ""
            switch cattext {
                case "Business" : emoji2 = "📈"
                break
                case "Entertainment" : emoji2 = "📺"
                break
                case "Politics" : emoji2 = "🏛"
                break
                case "Sports" : emoji2 = "⚽️"
                break
                case "Technology" : emoji2 = "📱"
                break
                default: emoji2 = ""
                break
            }
            let score2 = cat.probability
            cell.classificationLabel.text = "\(emoji2) (\(score2))"
        } else {
            cell.classificationLabel.text = ""
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "delete") { (action, indexPath) in
            self.deleteDB(at: self.ids[indexPath.row])
        }
        let edit = UITableViewRowAction(style: .default, title: "edit") { (action, indexPath) in
            let alert = UIAlertController(title: "Alert", message: "Enter a text", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = self.descriptions[indexPath.row]
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                self.updateDB(with: (textField?.text!)!, at: self.ids[indexPath.row])
            }))
            self.present(alert, animated: true, completion: nil)        }
        delete.backgroundColor = .red
        edit.backgroundColor = .gray
        return [delete, edit]
    }

    @IBAction func insert(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Alert", message: "Enter a text", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.insertDB(with: (textField?.text!)!)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func reloadDB() {
        let parameters: Parameters = ["imgid": imgId]
        Alamofire.request(BASE_URL + "description",parameters: parameters).responseJSON { response in
            if let obj = response.result.value {
                let json = obj as! NSObject
                let data = json.value(forKey: "data") as! NSArray
                self.ids = data.value(forKey: "desc_id") as! [Int]
                self.descriptions = data.value(forKey: "desc_text") as! [String]
                self.tableView.reloadData()
            }
        }
    }
    
    private func insertDB(with description:String) {
        let parameters: Parameters = ["description": description,"id":imgId]
        Alamofire.request(BASE_URL + "insert",parameters: parameters).responseJSON { response in
            self.reloadDB()
        }
    }
    
    private func deleteDB(at id:Int) {
        let parameters: Parameters = ["id":id]
        Alamofire.request(BASE_URL + "delete",parameters: parameters).responseJSON { response in
            self.reloadDB()
        }
    }
    
    private func updateDB(with description:String , at id:Int) {
        let parameters: Parameters = ["description": description,"id":id]
        Alamofire.request(BASE_URL + "update",parameters: parameters).responseJSON { response in
            self.reloadDB()
        }
    }
    
    private func showEmoji(sentiment: Sentiment) -> String {
        return sentiment.emoji
    }
}
