//
//  ClassesBrowserViewController.swift
//  RuntimeUI
//
//  Created by KIEU, HAI on 1/29/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import UIKit
#if os(iOS)
import Runtime
#endif

#if os(tvOS)
import RuntimeTV
#endif

class ClassesBrowserViewController: UIViewController {
    
    weak var framework : AFramework!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = framework.name
        navigationController?.isNavigationBarHidden = false
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

extension ClassesBrowserViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return framework.classes.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClassCell", for: indexPath) as! ClassCell
        let aClass = framework.classes[indexPath.row]
        cell.nameLabel.text = aClass.name
        return cell
    }
}

extension ClassesBrowserViewController : UICollectionViewDelegate {
    
}

