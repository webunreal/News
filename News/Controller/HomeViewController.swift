//
//  HomeViewController.swift
//  News
//
//  Created by Nikolai Ivanov on 09.02.2021.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let network = Network()
    
    let cellReuseIdentifier = "HomeTableViewCell"
    
    private var news: [News] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        network.loadData(completion: { result in
            switch result {
            case .success(let news):
                self.news = news
                self.tableView.reloadData()
            case .failure(let error):
                print("Fetch failed: \(error.localizedDescription)")
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailedViewController" {
            guard let detailedViewController = segue.destination as? DetailedViewController else { return }
            guard let indexPath = tableView.indexPath(for: sender as! HomeTableViewCell) else { return }
            
            detailedViewController.urlToSource = news[indexPath.row].urlToSource
            detailedViewController.urlToImageFromSegue = news[indexPath.row].urlToImage
            detailedViewController.titleFromSegue = news[indexPath.row].title
            detailedViewController.contentFromSegue = news[indexPath.row].content
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! HomeTableViewCell
        
        var title = news[indexPath.row].title
        if let afterDash = title.range(of: " - ") {
            title.removeSubrange(afterDash.lowerBound..<title.endIndex)
        }
        
        cell.title.text = title
        cell.newsDescription.text = news[indexPath.row].description ?? ""
        
        if let imageURL = news[indexPath.row].urlToImage {
            network.downloadImage(imageURL: imageURL) { image in
                cell.newsImage.image = image
            }
        } else {
            cell.newsImage.image = UIImage(named: "noImage")
        }
        
        return cell
    }


}

