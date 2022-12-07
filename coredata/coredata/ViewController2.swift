//
//  ViewController2.swift
//  coredata
//
//  Created by Şehriban Yıldırım on 6.12.2022.
//

import UIKit
import CoreData

class ViewController2: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageview: UIImageView!
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var place: UITextField!
    

    @IBOutlet weak var year: UITextField!
    
    var targetName = ""
    var targetId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if targetName != ""{
            //Core Data Verileri Buraya Gelecek
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Resimler")
            
            //FİLTRELEME
            let id = targetId?.uuidString //id aldık
            fetchRequest.predicate = NSPredicate(format: "id = %@", id!) //idyi eşitse filtrele.
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                
                let results = try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject]{
                    
                    if let namem = result.value(forKey: "name") as? String{
                        name.text = namem
                    }
                    
                    if let placee = result.value(forKey: "place") as? String{
                        place.text = placee
                    }
                    
                    if let yearr = result.value(forKey: "year") as? Int{
                        year.text = String(yearr)
                    }
                    
                    if let imagee = result.value(forKey: "image") as? Data{
                        
                        let image = UIImage(data: imagee)
                        
                        imageview.image = image
                    }
                }
            }catch{
                print("ERROR")
            }
            
        }else{
            
        }
        
        imageview.isUserInteractionEnabled = true
        let goster = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        imageview.addGestureRecognizer(goster)
    }
    
    @objc func imageTap(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker,animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageview.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true,completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        //Veri Kaydetme
        let appDelegete = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegete.persistentContainer.viewContext
        let saveData = NSEntityDescription.insertNewObject(forEntityName: "Resimler", into: context)
        
        saveData.setValue(name.text!, forKey: "name")
        saveData.setValue(place.text!, forKey: "place")
        
        if let year = Int(year.text!){
            saveData.setValue(year, forKey: "year")
        }
        
        let imagePress = imageview.image?.jpegData(compressionQuality: 0.5)
        saveData.setValue(imagePress, forKey: "image")
        saveData.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
            print("Succes")
        }catch{
            print("Error")
        }
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }

}
