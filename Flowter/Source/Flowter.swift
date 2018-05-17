import Foundation

public struct FinishedFlowter<T> {
    internal let flowter: Flowter<T>

    public func startFlow(flowPresentAction: ( (_ flowContainer: T) -> Void)) {
        guard let step = flowter.steps.first else { return }

        step.present()
        flowPresentAction(flowter.flowContainer)
    }
}

public class Flowter<T> {
    public typealias DefaultStepActionType = ( (_ vc: UIViewController, _ container: T) -> Void)

    fileprivate var steps = [Make]()
    private let presentAction: DefaultStepActionType
    private let dismissAction: DefaultStepActionType

    public let flowContainer: T

    public init(with container: T, defaultPresentAction: @escaping DefaultStepActionType, defaultDismissAction: @escaping DefaultStepActionType) {
        flowContainer = container
        presentAction = defaultPresentAction
        dismissAction = defaultDismissAction
    }

    public func addStep(withFactory stepFactory: () -> Make) -> Flowter<T> {
        let lastStep = steps.last
        let step = stepFactory()
        lastStep?.nextStep = step

        if step.endFlowAction == nil && step.presentAction == nil {
            step.presentAction = { (vc) in
                self.presentAction(vc, self.flowContainer)
            }
        }

        if step.dismissAction == nil {
            step.dismissAction = { (vc) in
                self.dismissAction(vc, self.flowContainer)
            }
        }

        steps.append(step)
        return self
    }

    public func addEndFlowStep(_ action: @escaping () -> Void ) -> FinishedFlowter<T> {
        let flow = self.addStep(withFactory: { () -> Make in
            let step = Make()

            step.setEndFlowAction {
                action()
            }

            return step
        })

        return FinishedFlowter(flowter: flow)
    }
}

extension Flowter where T: UINavigationController {
    private static var defaultPresent: DefaultStepActionType {
        return { (vc, container) in
            container.popViewController(animated: true)
        }
    }

    private static var defaultDismiss: DefaultStepActionType {
        return { (vc, container) in
            container.pushViewController(vc, animated: true)
        }
    }

    public convenience init(with container: T) {
        self.init(with: container, defaultPresentAction: Flowter<T>.defaultPresent, defaultDismissAction: Flowter<T>.defaultDismiss)
    }

    public convenience init(with container: T, defaultPresentAction: @escaping DefaultStepActionType) {
        self.init(with: container, defaultPresentAction: defaultPresentAction, defaultDismissAction: Flowter<T>.defaultDismiss)
    }

    public convenience init(with container: T, defaultDismissAction: @escaping DefaultStepActionType) {
        self.init(with: container, defaultPresentAction: Flowter<T>.defaultPresent, defaultDismissAction: defaultDismissAction)
    }
}

extension Flowter where T: UIViewController {
    private static var defaultPresent: DefaultStepActionType {
        return { (vc, container) in
            container.dismiss(animated: true)
        }
    }

    private static var defaultDismiss: DefaultStepActionType {
        return { (vc, container) in
            container.present(vc, animated: true)
        }
    }

    public convenience init(with container: T) {
        self.init(with: container, defaultPresentAction: Flowter<T>.defaultPresent, defaultDismissAction: Flowter<T>.defaultDismiss)
    }

    public convenience init(with container: T, defaultPresentAction: @escaping DefaultStepActionType) {
        self.init(with: container, defaultPresentAction: defaultPresentAction, defaultDismissAction: Flowter<T>.defaultDismiss)
    }

    public convenience init(with container: T, defaultDismissAction: @escaping DefaultStepActionType) {
        self.init(with: container, defaultPresentAction: Flowter<T>.defaultPresent, defaultDismissAction: defaultDismissAction)
    }
}
