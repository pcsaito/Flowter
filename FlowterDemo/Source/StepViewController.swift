//
//  TestViewController.swift
//  FlowterDemo
//
//  Created by Paulo Cesar Saito on 21/05/18.
//  Copyright 2018 Zazcar. All rights reserved.
//

import Foundation
import UIKit
import Flowter

class StepViewController: UIViewController, Flowtable {
    var flow: FlowStepInfo?
    
    let label = UILabel(frame: .zero)
    let contextLabel = UILabel(frame: .zero)
    let backButton = UIButton(type: .custom)
    let nextButton = UIButton(type: .custom)
    let closeButton = UIButton(type: .custom)

    convenience init(withLabel: String) {
        self.init(nibName: nil, bundle: nil)
        self.accessibilityLabel = withLabel
        self.label.text = withLabel
    }

    override func viewDidLoad() {
        navigationController?.setNavigationBarHidden(true, animated: false)

        let buttonMargin: CGFloat = 50
        let buttonHeight: CGFloat = 50
        let buttonWidth: CGFloat = 100

        view.backgroundColor = .white
        view.addSubview(label)
        view.addSubview(contextLabel)
        view.addSubview(backButton)
        view.addSubview(nextButton)
        view.addSubview(closeButton)

        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
        label.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        
        contextLabel.textAlignment = .center
        contextLabel.font = UIFont.boldSystemFont(ofSize: 22)
        contextLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        contextLabel.center = CGPoint(x: view.bounds.width / 2, y: (label.frame.origin.y + label.frame.size.height) + 10)

        backButton.accessibilityLabel = "backButton"
        backButton.setTitle("back", for: .normal)
        backButton.setTitleColor(.blue, for: .normal)
        backButton.addTarget(self, action: #selector(backStep), for: .touchUpInside)
        backButton.frame = CGRect(x: buttonMargin,
                                  y: view.bounds.height - (buttonMargin + buttonHeight),
                                  width: buttonWidth,
                                  height: buttonHeight)

        nextButton.accessibilityLabel = "nextButton"
        nextButton.setTitle("next", for: .normal)
        nextButton.setTitleColor(UIColor.blue, for: .normal)
        nextButton.addTarget(self, action: #selector(nextStep), for: .touchUpInside)
        nextButton.frame = CGRect(x: view.bounds.width - (buttonMargin + buttonWidth),
                                  y: view.bounds.height - (buttonMargin + buttonHeight),
                                  width: buttonWidth,
                                  height: buttonHeight)

        closeButton.accessibilityLabel = "closeButton"
        closeButton.setTitle("close", for: .normal)
        closeButton.setTitleColor(UIColor.blue, for: .normal)
        closeButton.addTarget(self, action: #selector(closeFlow), for: .touchUpInside)
        closeButton.frame = CGRect(x: (view.bounds.width - buttonWidth) / 2,
                                  y: buttonMargin,
                                  width: buttonWidth,
                                  height: buttonHeight)
    }

    func updateFlowtableViewController(with context: Any?) {
        contextLabel.text = "Previous: " + (context as? String ?? "Home")
    }
    
    @objc
    private func backStep() {
        flow?.back()
    }

    @objc
    private func nextStep() {
        flow?.next(context: label.text)
    }

    @objc
    private func closeFlow() {
        flow?.endFlow()
    }

    func setAsWelcomeStep() {
        backButton.isHidden = true
    }

    func setAsLastStep() {
        guard view != nil else { return }
        nextButton.setTitle("close flow", for: .normal)
    }
}
