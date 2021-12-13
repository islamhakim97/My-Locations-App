//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by Islam Abd El Hakim on 30/11/2021.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject,MKAnnotation {
    //These variables are read-only computed properties.
public var coordinate: CLLocationCoordinate2D
    {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
public var title: String?
    {
        if locationDescription.isEmpty {
            return "(No Description)"
    }else
          {return locationDescription}
    }
public var subtitle: String?
    {
        return category
    }
 public var hasPhoto:Bool{return photoId != nil }
 public var photoURL:URL{
    assert(photoId != nil,"No Photo ID set") // assert takes condition  the use of assert() to make sure the photoID is not nil --- from asserition
    let filename = "photo-\(photoId?.intValue).jpg"
    return applicationDocumentsDirectory.appendingPathComponent(filename)
        }
    var photoImage: UIImage? {
      return UIImage(contentsOfFile: photoURL.path)
    }
class func nextPhotoID() -> Int {
    let userDefaults = UserDefaults.standard
    let currentID = userDefaults.integer(forKey: "photoId") + 1
    userDefaults.set(currentID, forKey: "photoId")
    userDefaults.synchronize()
    return currentID
    }
func removePhotoFile() {
    if hasPhoto {
    do {
    try FileManager.default.removeItem(at: photoURL)
    } catch {
    print("Error removing file: \(error)")
            }
        }
    }
}
