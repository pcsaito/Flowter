import UIKit
import Flowter

class InitialViewController: UIViewController {
    @objc
    func startFlow() {
        Flowter(with: UINavigationController())
            .addStep(with: { (stepFactory) -> FlowStep<TestViewController, UINavigationController> in
                let step = stepFactory.make(with: TestViewController(withLabel: "Flow Start"))
                step.setPresentAction({ (welcomeVC, container) in
                    welcomeVC.setAsWelcomeStep()
                    container.pushViewController(welcomeVC, animated: true)
                })
                return step
            })
            .addStep { $0.make(with: TestViewController(withLabel: "1st Step"))}
            .addStep { $0.make(with: TestViewController(withLabel: "2nd Step"))}
            .addStep { $0.make(with: TestViewController(withLabel: "3nd Step"))}
            .addStep(with: { (stepFactory) -> FlowStep<TestViewController, UINavigationController> in
                let step = stepFactory.make(with: TestViewController(withLabel: "Flow Ending"))
                step.setPresentAction({ (welcomeVC, container) in
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

extension InitialViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    func configureView() {
        view.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)

        let buttonWidth: CGFloat = 300
        let buttonHeight: CGFloat = 100

        let startFlowButton = UIButton(type: .custom)
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

