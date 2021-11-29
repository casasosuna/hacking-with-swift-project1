//
//  ViewController.swift
//  Project1
//
//  Created by Enrique Casas on 6/19/21.
//

import UIKit

class ViewController: UITableViewController {
var pictures = [String]()
var ans = [String]()

var countTracker = [0: 0,
                    1: 0,
                    2: 0,
                    3: 0,
                    4: 0,
                    5: 0,
                    6: 0,
                    7: 0,
                    8: 0,
                    9: 0,]
    
// Challenge for Project 12
var count = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Storm Viewer"
        
        let defaults = UserDefaults.standard
        if let savedCounts = defaults.object(forKey: "counts") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                countTracker = try jsonDecoder.decode(Dictionary<Int, Int>.self, from: savedCounts)
            } catch {
                print("Failed")
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        navigationController?.navigationBar.prefersLargeTitles = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let fm = FileManager.default
            let path = Bundle.main.resourcePath!
            
            let items = try! fm.contentsOfDirectory(atPath: path)
            
            for item in items {
                if item.hasPrefix("nssl") {
                    self.pictures.append(item)
                }
            }
            
            //ans = pictures.sorted {
                //(s1, s2) -> Bool in return s1.localizedStandardCompare(s2) == .orderedAscending
            //}
            self.pictures.sort()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
//        let fm = FileManager.default
//        let path = Bundle.main.resourcePath!
//
//        let items = try! fm.contentsOfDirectory(atPath: path)
//
//        for item in items {
//            if item.hasPrefix("nssl") {
//                pictures.append(item)
//            }
//        }
//
//        //ans = pictures.sorted {
//            //(s1, s2) -> Bool in return s1.localizedStandardCompare(s2) == .orderedAscending
//        //}
//        pictures.sort()
        //print(pictures)
        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row]
        cell.detailTextLabel?.text = String(countTracker[indexPath.row] ?? 0)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1: try loading the "Detail" view controller and typecasting it to be DetailViewController
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            // 2: success! Set its selectedImage property
            vc.selectedImage = pictures[indexPath.row]
            vc.selectedPictureNumber = indexPath.row + 1
            vc.totalPictures = pictures.count
            
            // 3. now push it onto the navigation controller
            navigationController?.pushViewController(vc, animated: true)
        }
        
        guard var dictValue = countTracker[indexPath.row] else { return}
        dictValue += 1
        
        countTracker.updateValue(dictValue, forKey: indexPath.row)
        save()
        tableView.reloadData()
    }
    
    @objc func shareTapped() {
        let message = "please share this app!"
        
        let vc = UIActivityViewController(activityItems: [message], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(countTracker) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "counts")
        } else {
            print("Failed to save")
        }
    }
    
}

