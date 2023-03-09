//
//  UploadViewController.swift
//  InstaCloneFirebase
//
//  Created by Kadirhan Keles on 5.03.2023.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
class UploadViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var uploadText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        uploadImageView.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    @objc func imageTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            uploadImageView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func uploadClicked(_ sender: UIButton) {
        let storage = Storage.storage()
        // bu referanslar sayesinde hangi klasöre kaydedeceğimizi vs. belirtiyoruz
        let storageReference = storage.reference()
        let mediaFolder = storageReference.child("media")
        
        if let data = uploadImageView.image?.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data) { metadata, error in
                if error != nil {
                    self.makeAlert(title: "Error!", message: error?.localizedDescription ?? "Error")
                }else {
                    imageReference.downloadURL { url, error in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            //Database
                            let firestoreDatabase = Firestore.firestore()
                            var firestoreReference : DocumentReference? = nil
                            
                            let firestorePost = ["imageUrl": imageUrl!, "postedBy": Auth.auth().currentUser!.email!, "postComment": self.uploadText.text!, "date": FieldValue.serverTimestamp(), "likes": 0 ] as [String : Any]
                            
                            firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { error in
                                if error != nil {
                                    self.makeAlert(title: "Error!", message: error?.localizedDescription ?? "Error")
                                }else {
                                    self.uploadImageView.image = UIImage(systemName: "square.and.arrow.down")
                                    self.uploadText.text = ""
                                    self.tabBarController?.selectedIndex = 0
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func makeAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    

}
