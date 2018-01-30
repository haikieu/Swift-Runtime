//
//  RuntimeBrowserViewController.swift
//  RuntimeUI
//
//  Created by KIEU, HAI on 1/29/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import UIKit
import Runtime

class RuntimeBrowserViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

class CommonCell : UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.blue.withAlphaComponent(0.8).cgColor
        self.layer.borderWidth = 1
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.9).cgColor
        self.layer.shadowRadius = 3
        self.layer.cornerRadius = 5
    }
}

class FrameworkCell : CommonCell {
    
}

class ClassCell : CommonCell {
    
}

extension RuntimeBrowserViewController : UICollectionViewDelegate {
    
}

extension RuntimeBrowserViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Runtime.environment.frameworks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FrameworkCell", for: indexPath) as! FrameworkCell
        let framework = Runtime.environment.frameworks[indexPath.row]
        cell.nameLabel.text = framework.name
        return cell
    }
}
