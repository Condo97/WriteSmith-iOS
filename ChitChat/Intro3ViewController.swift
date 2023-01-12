//
//  Intro1ViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/12/23.
//

import UIKit

class Intro3ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func continueButton(_ sender: Any) {
        performSegue(withIdentifier: "toUltraPurchase", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /* Is segue to Ultra Purchase? */
        if segue.identifier == "toUltraPurchase" {
            /* Is next view contorller Ultra Purchase View Controller? */
            if let detailVC = segue.destination as? UltraPurchaseViewController {
                /* Then let UltraPurcahseViewControlelr know it's from start */
                detailVC.fromStart = true
            }
        }
    }
}
