//
//  ARCollectionList.swift
//  MidigiTransAR
//
//  Created by Shashidhar Jagatap on 25/02/24.
//

import UIKit

protocol ARCollectionListDelegate {
    func setSelectedImage(image:UIImage)
}

class ARCollectionList: UIViewController{
    
    @IBOutlet weak var detailCollectionView: UICollectionView!
    var viewModel:ARSCNViewModel?
    var delegate:ARCollectionListDelegate?
    var deletePressed:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }

        // Get the index path of the long pressed cell
        if self.deletePressed == false {
            self.deletePressed = true
            self.detailCollectionView.reloadData()
        }else{
            self.deletePressed = false
            self.detailCollectionView.reloadData()
        }
    }
    
    private func handleLongPress(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            // Perform deletion logic here
            // self.deleteItem(at: indexPath)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupCollectionView() {
        detailCollectionView.backgroundColor = .white
        detailCollectionView.delegate = self
        detailCollectionView.dataSource = self
        detailCollectionView.collectionViewLayout = createCollectionViewLayout()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        detailCollectionView.addGestureRecognizer(longPressGesture)
    }
}

extension ARCollectionList: TileCollectionViewCellDelegate {
    func tileCellDidTapDelete(_ cell: TileCollectionViewCell) {
        guard let indexPath = detailCollectionView.indexPath(for: cell) else { return }
        let alert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.viewModel?.listData.remove(at: indexPath.row)
            self.viewModel?.saveImagesToUserDefaults()
            self.detailCollectionView.reloadData()
        }))
        present(alert, animated: true, completion: nil)
    }
}


extension ARCollectionList: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel?.paginationData.count ?? 0
        default:
            return viewModel?.listData.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TileCollectionViewCell", for: indexPath) as! TileCollectionViewCell
        if let vm = viewModel{
            cell.tileImage.contentMode = .scaleToFill
            
            if indexPath.section == 0 {
                cell.tileImage.image = vm.paginationData[indexPath.row]
            }else{
                cell.tileImage.image = vm.listData[indexPath.row]
                cell.deleteButtonImage.isHidden = !self.deletePressed
                if indexPath.row == 0{
                    cell.deleteButtonImage.isHidden = true
                }
                cell.delegate = self
            }
            cell.layer.cornerRadius = 8
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vm = viewModel{
            switch indexPath.section {
            case 0:
                let image = vm.paginationData[indexPath.row]
                self.delegate?.setSelectedImage(image: image)
        
            default:
                if indexPath.row == 0 {
                    self.openGallery()
                }else{
                    let image = vm.listData[indexPath.row]
                    self.delegate?.setSelectedImage(image: image)
                    vm.paginationData.insert(image, at: 0)
                }

            }
        }
    }
}


extension ARCollectionList: UICollectionViewDelegateFlowLayout {
    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (section, _) -> NSCollectionLayoutSection? in
            if section == 0 {
                // item
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)
                
                // group
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(280)
                    ),
                    subitem: item,
                    count: 1
                )
                group.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
                
                // section
                let section = NSCollectionLayoutSection(group: group)
                //section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 10, trailing: 5)
                section.orthogonalScrollingBehavior = .groupPaging
                
                // return
                return section
                
            } else if section == 1 {
                // item
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1/2),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5)
                
                // group
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(200)
                    ),
                    subitem: item,
                    count: 2
                )
                group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0)
                
                // section
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
                
                // return
                return section
            }
            
            return nil
        }
    }
}

extension ARCollectionList: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Function to open the photo gallery
    func openGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // UIImagePickerControllerDelegate method to handle when an image is picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Do something with the picked image, like displaying it in an image view
            // For example:
            // imageView.image = pickedImage
            //self.setSelectedImage(image: pickedImage)
            self.viewModel?.listData.append(pickedImage)
            self.viewModel?.saveImagesToUserDefaults()
            self.detailCollectionView.reloadData()
        }
        
        picker.dismiss(animated: true, completion: nil) // Dismiss the picker
    }
    
    // UIImagePickerControllerDelegate method to handle when the user cancels picking an image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil) // Dismiss the picker
    }
}

