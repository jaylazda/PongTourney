//
//  ProfileViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-05-17.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit
import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var editImageButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var statsTableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    var firebase = FirebaseService.shared
    var player = Player()
    var statTitleArray = ["Games", "Wins", "Losses", "Total Shots", "Shots Hit", "Shots Missed", "Redemptions"]
    var statsArray = [Int]()
    let storage = Storage.storage()
    let userID = FirebaseService.shared.authentication?.currentUser?.uid
    let userDefaults = UserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statsTableView.delegate = self
        statsTableView.dataSource = self
        statsTableView.tableFooterView = UIView()
        if let image = loadImage(fileName: "profilePic.png") {
            profilePic.image = image
        }
        getPlayerData(firebase.authentication?.currentUser?.uid ?? "") { player in
            self.player = player
            self.statsArray = [player.games, player.wins, player.losses, player.shots, player.shotsHit, player.shotsMissed, player.redemptions]
            self.nameLabel.text = "\(player.firstName) \(player.lastName)"
            self.statsTableView.reloadData()
        }

    }
    
    func getPlayerData(_ playerID: String, completionHandler: @escaping (_ playerData: Player) -> Void) {
        var playerData = Player()
        firebase.playersRef?.whereField("id", isEqualTo: playerID)
            .getDocuments() { querySnapshot, error in
                    if let err = error {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            let result = Result {
                                try document.data(as: Player.self)
                            }
                            switch result {
                            case .success(let player):
                                if let player = player {
                                    playerData = player
                                    print("Received player data from server.")
                                } else {
                                    print("Player is empty")
                                }
                            case .failure(let error):
                                print("Error decoding player: \(error)")
                            }
                        }
                        completionHandler(playerData)
                }
            }
    }
    
    func selectImage() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        profilePic.image = image
        if let data = image.pngData() {
            let filename = getDocumentsDirectory().appendingPathComponent("profilePic.png")
            try? data.write(to: filename)
        }
        uploadImage()
        
    }
    
    @IBAction func editImageClicked(_ sender: Any) {
        selectImage()
    }
    
    func uploadImage() {
        let profilePicRef = storage.reference().child("profilePics/\(userID ?? "").png")
        guard let imageData = profilePic.image?.pngData() else { return }
        let uploadTask = profilePicRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                //Error
                return
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadImage(fileName: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image: \(error)")
        }
        return nil
    }
    

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "myStatCell") as? MyStatsTableViewCell else {
            return UITableViewCell()
        }
        cell.detailTextLabel?.text = "HI"
        cell.statTypeLabel.text = statTitleArray[indexPath.row]
        cell.statNumberLabel.text = "\(statsArray[indexPath.row])"
        return cell
    }
    
    
}


