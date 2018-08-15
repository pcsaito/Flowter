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

    let labelString: String

    let label = UILabel(frame: .zero)
    let backButton = UIButton(type: .custom)
    let nextButton = UIButton(type: .custom)
    let closeButton = UIButton(type: .custom)

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    init(withLabel: String) {
        labelString = withLabel
        super.init(nibName: nil, bundle: nil)
        self.accessibilityLabel = withLabel
    }

    override func viewDidLoad() {
        navigationController?.setNavigationBarHidden(true, animated: false)

        let buttonMargin: CGFloat = 50
        let buttonHeight: CGFloat = 50
        let buttonWidth: CGFloat = 100

        view.backgroundColor = .white
        view.addSubview(label)
        view.addSubview(backButton)
        view.addSubview(nextButton)
        view.addSubview(closeButton)

        label.text = labelString
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
        label.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)

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

    @objc
    private func backStep() {
        flow?.back()
    }

    @objc
    private func nextStep() {
        flow?.next(updating: true)
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
