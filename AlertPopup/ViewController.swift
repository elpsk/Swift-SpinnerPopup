//
//  ViewController.swift
//  AlertPopup
//
//  Created by Pasca Alberto, IT on 11/08/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(
            timeInterval: 5,
            target: self,
            selector: #selector(closeSpinner),
            userInfo: nil,
            repeats: false
        )
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        SpinnerManager.shared.showAlert(blurBackground: false, autodismissTimeout: 15) {
            print( "closed after timeout" )
        }
    }

    @objc func closeSpinner() {
        SpinnerManager.shared.dismiss()
    }

}

