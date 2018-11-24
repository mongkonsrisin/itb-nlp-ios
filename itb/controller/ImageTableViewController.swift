//
//  ImageTableViewController.swift
//  itb
//
//  Created by Mongkon Srisin on 11/23/18.
//  Copyright © 2018 Mongkon Srisin. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class ImageTableViewController: UITableViewController {
    
    let BASE_URL = "https://www.deksuan.com/itb/"
    var ids:[Int] = []
    var urls:[String] = []
    var titles:[String] = []
    var selectedId:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request(BASE_URL + "img").responseJSON { response in
            if let obj = response.result.value {
                let json = obj as! NSObject
                let data = json.value(forKey: "data") as! NSArray
                self.ids = data.value(forKey: "img_id") as! [Int]
                self.urls = data.value(forKey: "img_url") as! [String]
                self.titles = data.value(forKey: "img_title") as! [String]
                self.tableView.reloadData()
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ids.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ImageTableViewCell
        cell.photoImageView.sd_setImage(with: URL(string: urls[indexPath.row]), placeholderImage: UIImage(named: "placeholder.png"))
        cell.titleLabel.text = " " + titles[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedId = ids[indexPath.row]
        performSegue(withIdentifier: "segue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue" {
            let descriptionTableViewController = segue.destination as! DescriptionTableViewController
            descriptionTableViewController.imgId = selectedId
        }
    }
  
}

