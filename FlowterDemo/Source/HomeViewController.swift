//
//  HomeViewController.swift
//  FlowterDemo
//
//  Created by Paulo Cesar Saito on 21/05/18.
//  Copyright © 2018 Zazcar. All rights reserved.
//

import UIKit
import Flowter

class HomeViewController: UIViewController {
    @objc
    func startFlow() {
        Flowter(with: UINavigationController())
            .addStep(with: { (stepFactory) -> FlowStep<StepViewController, UINavigationController> in
                let step = stepFactory.make(with: StepViewController(withLabel: "Flow Start"))
                
                step.setPresentAction({ (welcomeVC, container) in
                    welcomeVC.setAsWelcomeStep()
                    container.pushViewController(welcomeVC, animated: true)
                })
                
                return step
            })
            .addStep { $0.make(with: StepViewController(withLabel: "1st Step"))}
            .addStep {
                $0.make { () -> StepViewController in
                    let title = "2nd Step"
                    return StepViewController(withLabel: title)
                }
            }
            .addStep(with: { (stepFactory) -> FlowStep<StepViewController, UINavigationController> in
                return stepFactory.make(withFactoryClosure: {
                    let title = "3rd Step"
                    return StepViewController(withLabel: title)
                })
            })
            .addStep(with: { (stepFactory) -> FlowStep<StepViewController, UINavigationController> in
                let step = stepFactory.make(with: StepViewController(withLabel: "Flow Ending"))
                step.setPresentAction({ (welcomeVC, container) in
                    welcomeVC.updateFlowStepViewController()
                    welcomeVC.setAsLastStep()
                    container.pushViewController(welcomeVC, animated: true)
                })
                return step
            })
            .addEndFlowStep { (container) in
                container.dismiss(animated: true)
            }
            .startFlow { [weak self] (container) in
                self?.present(container, animated: true)
        }
    }
}

extension HomeViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    func configureView() {
        view.accessibilityLabel = "HomeViewController"
        view.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)

        let buttonWidth: CGFloat = 300
        let buttonHeight: CGFloat = 100

        let startFlowButton = UIButton(type: .custom)
        startFlowButton.accessibilityLabel = "startFlowButton"
        startFlowButton.setTitle("Present Flow", for: .normal)
        startFlowButton.setTitleColor(.blue, for: .normal)
        startFlowButton.addTarget(self, action: #selector(startFlow), for: .touchUpInside)
        startFlowButton.frame = CGRect(x: (view.bounds.width - buttonWidth) / 2.0,
                                       y: (view.bounds.height - buttonHeight) / 2.0,
                                       width: buttonWidth,
                                       height: buttonHeight)

        view.addSubview(startFlowButton)
    }
}

