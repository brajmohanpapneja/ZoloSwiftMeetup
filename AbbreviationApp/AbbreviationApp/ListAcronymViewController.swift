//
//  ListAcronymViewController.swift
//  AbbreviationApp
//
//  Created by Papneja, Brajmohan on 22/08/19.
//  Copyright © 2019 Papneja, Brajmohan. All rights reserved.
//

import UIKit

class ListAcronymViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var acronymsTableView: UITableView!
    var countAcronyms : Int = 0
    var responseAcronyms : Array<Any>?
    var cellShortText : String! = ""
    var cellLongText : String! = ""
    var gameBreak: Int

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countAcronyms
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        
        let localDict : Dictionary = responseAcronyms?[indexPath.row] as! Dictionary<String,String>
        
        cellShortText  = localDict["short"]
        cellLongText  = localDict["long"]
        cell.textLabel?.text = cellShortText + " : " + cellLongText

        return cell
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "List Acronyms"
        
        // Do any additional setup after loading the view.
        self.acronymsTableView.delegate=self
        self.acronymsTableView.dataSource = self
        
        AcronymServices.shared.getAllAcronyms(successBlock: { [weak self] response in
            print("response=\(String(describing: response))")
            self?.countAcronyms = (response as! Array<Any>).count as Int
            self?.responseAcronyms = (response as! Array<Any>)

            DispatchQueue.main.async {
                self?.acronymsTableView?.reloadData()
            }
            
        }) { error in
            print("error=\(String(describing: error))")
        }
        
       
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
