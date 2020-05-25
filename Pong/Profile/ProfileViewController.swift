//
//  ProfileViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-05-17.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var recentGamesCollectionView: UICollectionView!
    @IBOutlet weak var statsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statsTableView.delegate = self
        statsTableView.dataSource = self
        recentGamesCollectionView.delegate = self
        recentGamesCollectionView.dataSource = self
//        statsTableView.register(MyStatsTableViewCell.self, forCellReuseIdentifier: "myStatCell")
//        recentGamesCollectionView.register(RecentGameCollectionViewCell.self, forCellWithReuseIdentifier: "recentGame")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "myStatCell") as? MyStatsTableViewCell else {
            return UITableViewCell()
        }
        return cell
    }
    
    
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recentGame", for: indexPath) as? RecentGameCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.accuracyLabel.text = "Accuracy 56%"
        cell.winLoseLabel.text = "W"
        cell.scoreLabel.text = "6-4"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 124, height: 124)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 1.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 1.0
    }
    
}
