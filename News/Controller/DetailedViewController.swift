//
//  DetailedViewController.swift
//  News
//
//  Created by Nikolai Ivanov on 11.02.2021.
//

import UIKit

class DetailedViewController: UIViewController {
    
    @IBOutlet weak private var newsImage: UIImageView!
    @IBOutlet weak private var newsTitle: UILabel!
    @IBOutlet weak private var newsContent: UILabel!
    
    public var urlToSource: String = ""
    public var urlToImageFromSegue: String?
    public var titleFromSegue = ""
    public var contentFromSegue: String?
    
    private let network = Network()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let imageURL = urlToImageFromSegue {
            network.downloadImage(imageURL: imageURL) { image in
                self.newsImage.image = image
            }
        } else {
            newsImage.image = UIImage(named: "noImage")
        }
        newsTitle.text = titleFromSegue
        
        if var content = contentFromSegue {
            if let afterDots = content.range(of: "[") {
                content.removeSubrange(afterDots.lowerBound..<content.endIndex) 
            }
            newsContent.text = content
        } else {
            newsContent.text = ""
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSourceViewController" {
            guard let sourceViewController = segue.destination as? SourceViewController else { return }
            sourceViewController.urlToSource = urlToSource
        }
    }
    
}
