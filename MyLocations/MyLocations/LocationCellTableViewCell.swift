//
//  LocationCellTableViewCell.swift
//  MyLocations
//
//  Created by Islam Abd El Hakim on 02/12/2021.
//

import UIKit

class LocationCellTableViewCell: UITableViewCell {
  
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addresslabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selection = UIView(frame: CGRect.zero)
        selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        selectedBackgroundView = selection
        // Rounded corners for images
        photoImageView.layer.cornerRadius =
        photoImageView.bounds.size.width / 2
        photoImageView.clipsToBounds = true
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0,
        right: 0)
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(for location :Location)
    {
        if location.locationDescription.isEmpty {
            descriptionLabel.text="(No Description)"
        }else
        {
            descriptionLabel.text = location.locationDescription
        }
        if let placemark = location.placemark
        {
            var text = ""
            if let s = placemark.subThoroughfare
            {
                text += s + ""
            }
            if let s = placemark.thoroughfare
            {
                text += s + ","
            }
            if let s = placemark.locality
            {
                text += s
            }
            addresslabel.text = text
        }
        else
        {
            addresslabel.text = String(format: "Lat :%.8f,long: %.8f", location.latitude,location.longitude)
        }
    photoImageView.image=thumbnail(for: location)
    }
    func thumbnail(for location: Location) -> UIImage {
      if location.hasPhoto, let image = location.photoImage {
        return image.resized(
          withBounds: CGSize(width: 52, height: 52))
      }
        return UIImage(named: "No Photo")!
    }
    

}
