import Foundation

public class Flowter<ContainerType> where ContainerType: UIViewController {
    public typealias DefaultStepActionType = ( (_ vc: UIViewController, _ container: ContainerType) -> Void)

    internal var steps = [FlowStepProtocol]()
    private let presentAction:  DefaultStepActionType
    private let dismissAction:  DefaultStepActionType

    public let flowContainer: ContainerType

    public init(with container: ContainerType, defaultPresentAction: @escaping  DefaultStepActionType, defaultDismissAction: @escaping  DefaultStepActionType) {
        flowContainer = container
        presentAction = defaultPresentAction
        dismissAction = defaultDismissAction
    }

    public func addStep<ControllerType: UIViewController>(with: (_ stepFactory: MakeStep<ControllerType, ContainerType>) -> FlowStep<ControllerType, ContainerType>) -> Flowter<ContainerType> {
        let step = with(MakeStep(flowter: self))

        var lastStep = steps.last
        lastStep?.nextStep = step

        if step.endFlowAction == nil && step.presentAction == nil {
            step.presentAction = presentAction
        }

        if steps.count != 0 && step.dismissAction == nil {
            step.dismissAction = dismissAction
        }

        if step.endFlowAction != nil {
            steps.forEach { (eachStep) in
                var eachStep = eachStep
                eachStep.endFlowAction = step.endFlowAction
            }
        }

        step.container = flowContainer
        steps.append(step)
        return self
    }

    public func addEndFlowStep(_ action: @escaping (_ container: ContainerType) -> Void) -> FinishedFlowter<ContainerType> {
        let flow = self.addStep(with: { (_) -> FlowStep<EndFlowPlaceholderController, ContainerType> in
            let step = FlowStep<EndFlowPlaceholderController, ContainerType>(with: { () -> EndFlowPlaceholderController in
                EndFlowPlaceholderController()
            })

            step.endFlowAction = {
                action(self.flowContainer)
            }

            return step
        })
        return FinishedFlowter(flowter: flow)
    }
}

//Convenience initializers
extension Flowter {
    public convenience init(with container: ContainerType) {
        self.init(with: container, defaultPresentAction: Flowter<ContainerType>.defaultPresent(), defaultDismissAction: Flowter<ContainerType>.defaultDismiss())
    }

    public convenience init(with container: ContainerType, defaultPresentAction: @escaping  DefaultStepActionType) {
        self.init(with: container, defaultPresentAction: defaultPresentAction, defaultDismissAction: Flowter<ContainerType>.defaultDismiss())
    }

    public convenience init(with container: ContainerType, defaultDismissAction: @escaping  DefaultStepActionType) {
        self.init(with: container, defaultPresentAction: Flowter<ContainerType>.defaultPresent(), defaultDismissAction: defaultDismissAction)
    }

    private static func defaultPresent() -> DefaultStepActionType {
        return { (vc, container) in
            if let navContainer = container as? UINavigationController {
                navContainer.pushViewController(vc, animated: true)
            } else {
                container.present(vc, animated: true)
            }
        }
    }

    private static func defaultDismiss() -> DefaultStepActionType {
        return { (vc, container) in
            if let navContainer = container as? UINavigationController {
                navContainer.popViewController(animated: true)
            } else {
                container.dismiss(animated: true)
            }
        }
    }
}
