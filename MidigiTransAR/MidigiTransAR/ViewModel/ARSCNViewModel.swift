//
//  ARSCNViewModel.swift
//  MidigiTransAR
//
//  Created by Shashidhar Jagatap on 25/02/24.
//

import Foundation
import UIKit

class ARSCNViewModel {
    var paginationData: [UIImage] = []
    var listData: [UIImage] = []
    
    init() {
        self.loadImagesFromUserDefaults()
    }
    
    func saveImagesToUserDefaults() {
        // Convert images to Data
        if listData.count > 0{
            let imageDataArray = listData.compactMap { image in
                image.pngData()
            }
            // Save the array of image data to UserDefaults
            UserDefaults.standard.set(imageDataArray, forKey: "selectedImages")
        }
    }
    
    func loadImagesFromUserDefaults() {
        if let imageDataArray = UserDefaults.standard.array(forKey: "selectedImages") as? [Data] {
            // Convert image data back to UIImage and populate the selectedImages array
            listData = imageDataArray.compactMap { data in
                UIImage(data: data)
            }
            
            paginationData.append(listData.last!)
            
        }else{
            let defaultImages = ["gallery","tile1", "tile2", "tile1","tile1", "tile2", "tile1","tile1", "tile2", "tile1","tile1", "tile2", "tile1"]
            var imageDataArray = [Data]()
            defaultImages.forEach { item in
                if let image = UIImage(named: item), let data = image.pngData(){
                    imageDataArray.append(data)
                }
            }
            // Save the array of image data to UserDefaults
            UserDefaults.standard.set(imageDataArray, forKey: "selectedImages")
            // Convert image data back to UIImage and populate the selectedImages array
            listData = imageDataArray.compactMap { data in
                UIImage(data: data)
            }
            
            paginationData.append(listData.last!)
        }
        
        
    }
}
