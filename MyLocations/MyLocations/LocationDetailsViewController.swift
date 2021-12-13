//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Islam Abd El Hakim on 27/11/2021.
//

import UIKit
import CoreLocation
import CoreData
class LocationDetailsViewController: UITableViewController {
//MARK:- creating Glopal private dateFormatter Once then reuse it through closure
    private let dateFormatter:DateFormatter =
    {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
       // print("iam excuted once all the tim date obj")
        return formatter
    }()
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    var coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark:CLPlacemark?
    var managedObjectContext:NSManagedObjectContext!
    var date = Date()
    var categoryName = "No Category"
    var locationToEdit:Location?
    {
        //when press any cell in the locations screen to edit it , put the location values to location details screen
        //The Edit Location screen should now appear with the data from the selected location:
       
        didSet {
        if let location = locationToEdit {
        DescriptionText = location.locationDescription
        categoryName = location.category
        date = location.date
        coordinates = CLLocationCoordinate2DMake(
        location.latitude, location.longitude)
        placemark = location.placemark
        }
        }
        
    }
    var DescriptionText = ""
    var image : UIImage?
    var observer: Any!
    
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let locationToEdit = locationToEdit {
            title = "Edit Location"
            if locationToEdit.hasPhoto
            {
                if let theimage = locationToEdit.photoImage
                {
                    showImage(image: theimage)
                   
                }
                
            }
            descriptionTextView.text = DescriptionText
            
        }
        updateLabels()
        // Hide keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self,
        action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        listenForBackgroundNotification()
        // Do any additional setup after loading the view.
    }
   deinit {
              // print("*** deinit \(self)")
               NotificationCenter.default.removeObserver(observer!)
          }
    
    @IBAction func Donebtn(_ sender: Any) {
        let hudView = HudView.hud(inView:navigationController!.view,
        animated: true)
        let location: Location
        if let temp = locationToEdit {
        hudView.text = "Updated"
        location = temp
          }
        else {
        hudView.text = "Tagged"
        location = Location(context: managedObjectContext)
        location.photoId = nil
         }
       
   //1-coreData store object
        //2
        location.placemark = placemark
        location.longitude=coordinates.longitude
        location.latitude=coordinates.latitude
        location.date=date
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        //3
        do {
        try managedObjectContext.save() // save mabagedObjectContext
            //tell the app to close the TagLocation-screen after 0.6 seconds.
                    // Free function made in swift functions
        afterDelay(0.6) {
        hudView.hide()
        self.navigationController?.popViewController(
        animated: true)
             }
        }
        catch
        {
            //3
            fatalCoreDataError(error)
        }
// Save image
if let image = image {
    // 1
    if !location.hasPhoto {
        location.photoId = Location.nextPhotoID() as NSNumber
            }
    // 2
    if let data = image.jpegData(compressionQuality: 0.5) {
    // 3
    do {
        try data.write(to: location.photoURL, options: .atomic)
        } catch {
        print("Error writing file: \(error)")
                }
          }
       }
    }
    
    @IBAction func Cancelbtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    // unwined segue to pass selected category back From CategoryPickerController to LocationDetailsViewController
    @IBAction func CategoryPickerPickCategory(_ segue:UIStoryboardSegue)
    {
        let categorySource = segue.source as! CategoryPickerViewController
        categoryName = categorySource.selectedCategoryName 
        categoryLabel.text = categoryName
        
    }
   
    func updateLabels()
    {
        descriptionTextView.text=DescriptionText
        categoryLabel.text=categoryName
        latitudeLabel.text=String(format: "%.08f",coordinates.latitude)
        longitudeLabel.text=String(format: "%.08f", coordinates.longitude)
        if let placemark = placemark {
            addressLabel.text = string(from:placemark)
        }
        else
        {addressLabel.text="No Address Found"}
        DateLabel.text = format(date:date)//date obj
       
    }
   
    // MARK:- Helper Methods
    func string(from placemark: CLPlacemark) -> String {
    var text = ""
    if let s = placemark.subThoroughfare {
    text += s + " "
    }
    if let s = placemark.thoroughfare {
    text += s + ", "
    }
    if let s = placemark.locality {
    text += s + ", "
    }
    if let s = placemark.administrativeArea {
    text += s + " "
    }
    if let s = placemark.postalCode {
    text += s + ", "
    }
    if let s = placemark.country {
    text += s
    }
    return text
    }
    
    func format(date:Date)->String
    {
        return dateFormatter.string(from: date)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCategory"
        {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    // specify section 0,1 that can be tapped
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (indexPath.section==0||indexPath.section==1)
        {
            return indexPath
        }
        else
        {
            return nil
        }
    }
    // Photo Row Cell auto height size  Configuration
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section==1){
            if let image = locationToEdit?.photoImage
            {
            let photowithratio = image.size.width / image.size.height
         return tableView.frame.width/photowithratio
            }
           else if let image = image {
                let photowithratio = image.size.width / image.size.height
             return tableView.frame.width/photowithratio
            }
        }

        return 72
    }
  
    //Table View Delegates
    // Focus in textview if section 0 && row 0 tabbed
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section==0&&indexPath.row==0)
        {
            descriptionTextView.becomeFirstResponder()
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
            }
    }
    override func tableView(_ tableView: UITableView,willDisplay cell: UITableViewCell,
    forRowAt indexPath: IndexPath) {
    let selection = UIView(frame: CGRect.zero)
    selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
    cell.selectedBackgroundView = selection
    }
   
    @objc func hideKeyboard(_ gestureRecognizer:
    UIGestureRecognizer) {
    let point = gestureRecognizer.location(in: tableView)
    let indexPath = tableView.indexPathForRow(at: point)
    if indexPath != nil && indexPath!.section == 0
    && indexPath!.row == 0 {
    return
    }
        descriptionTextView.resignFirstResponder()
        }

func showImage(image : UIImage)
{
    imageView.image = image
    imageView.isHidden = false
    addPhotoLabel.text = ""
    imageHeight.constant = 260
    tableView.reloadData()
    
}
// Handle the Application when Enter To the background [close all action sheets && alerts]
func listenForBackgroundNotification() {
   observer =  NotificationCenter.default.addObserver(forName:UIScene.didEnterBackgroundNotification,
    object: nil, queue: OperationQueue.main) { _ in
    if self.presentedViewController != nil {self.dismiss(animated: false, completion: nil)}
        //If there is an active image picker or action sheet[presented modal view controllers ], you dismiss it. You also hide the
       // keyboard if the text view is active
    self.descriptionTextView.resignFirstResponder()
                       }
    
    }
}
// Extention for Image Picker
extension LocationDetailsViewController:
    UIImagePickerControllerDelegate,UINavigationControllerDelegate {
// MARK:- Image Helper Methods
func takePhotoWithCamera() {
       let imagePicker = MyImagePickerController()
       imagePicker.sourceType = .camera
       imagePicker.delegate = self
       imagePicker.allowsEditing = true
       imagePicker.view.tintColor = view.tintColor
       present(imagePicker, animated: true, completion: nil)
            }
func choosePhotoFromLibrary() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .photoLibrary
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    imagePicker.view.tintColor = view.tintColor
    present(imagePicker, animated: true, completion: nil)
         }
func pickPhoto() {
    // if true||UIImagePickerController.isSourceTypeAvailable(.camera) -- Fake camera availability
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
    showPhotoMenu()
            }
    else {
    choosePhotoFromLibrary()
         }
    }
    
func showPhotoMenu() {
    let alert = UIAlertController(title: nil, message: nil,
    preferredStyle: .actionSheet)
    let actCancel = UIAlertAction(title: "Cancel", style: .cancel,
    handler: nil)
    alert.addAction(actCancel)
    let actPhoto = UIAlertAction(title: "Take Photo",
                                 style: .default, handler:{ _ in self.takePhotoWithCamera()})
    alert.addAction(actPhoto)
    let actLibrary = UIAlertAction(title: "Choose From Library",
                                   style: .default, handler:{ _ in self.choosePhotoFromLibrary()})
    alert.addAction(actLibrary)
    present(alert, animated: true, completion: nil)
    }
// MARK:- Image Picker Delegates
func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
    
    image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
    if let theImage = image {
    showImage(image:theImage)
    }
    dismiss(animated: true, completion: nil)
          }
func imagePickerControllerDidCancel(_ picker:UIImagePickerController) {
    dismiss(animated: true, completion: nil)
        }
    
 }
