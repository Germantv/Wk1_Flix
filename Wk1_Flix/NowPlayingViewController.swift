//
//  NowPlayingViewController.swift
//  Wk1_Flix
//
//  Created by German Flores on 2/5/18.
//  Copyright © 2018 German Flores. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import Foundation
import PKHUD


class NowPlayingViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    
    var movies: [[String: Any]] = []
    var refreshControl: UIRefreshControl!
    
    let alert = UIAlertController(title: "Warning", message: "No internet connection", preferredStyle: .alert)
    /*
    class Connectivity {
        class func isConnectedToNet() -> Bool {
            return NetworkReachabilityManager()!.isReachable
        }
    }
 */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        if Connectivity.isConnectedToNet() {
            present(alert, animated: true, completion: nil)
        }
         */
        
        //activityIndicator.startAnimating()
        HUD.dimsBackground = false
        HUD.allowsInteraction = false
        
        HUD.flash(.progress, onView: tableView, delay: 0.7) { finished in
            // Completion Handler
            HUD.flash(.success, onView: self.tableView)
        }

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NowPlayingViewController.didPullToRefresh(_:)), for: .valueChanged)
        
        tableView.insertSubview(refreshControl, at: 0)

        tableView.dataSource = self
        self.tableView.rowHeight = 200

        fetchMovies()
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        fetchMovies()
    }
    
    func fetchMovies() {
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            //this will run when the network request returns, network requests are asynchronous.
            if let error = error {
                print(error.localizedDescription)
            }else if let data = data {
                //if got data back --> need to parse it
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let movies = dataDictionary["results"] as! [[String: Any]]
                self.movies = movies
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                //self.activityIndicator.stopAnimating()
            }
        }
        task.resume()
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies[indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let posterPathString = movie["poster_path"] as! String
        let baseURLString = "https://image.tmdb.org/t/p/w500"
        
        let posterURL = URL(string: baseURLString + posterPathString)!
        cell.posterImageView.af_setImage(withURL: posterURL)
        
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}