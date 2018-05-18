import Foundation

public struct FinishedFlowter<ContainerType> where ContainerType: UIViewController {
    internal let flowter: Flowter<ContainerType>

    public func startFlow(flowPresentAction: ( (_ flowContainer: ContainerType) -> Void)) {
        guard let step = flowter.steps.first else { return }

        step.present()
        flowPresentAction(flowter.flowContainer)
    }
}

public class Flowter<ContainerType> where ContainerType: UIViewController {
    public typealias  DefaultStepActionType = ( (_ vc: UIViewController, _ container: ContainerType) -> Void)

    fileprivate var steps = [FlowStep<ContainerType>]()
    private let presentAction:  DefaultStepActionType
    private let dismissAction:  DefaultStepActionType

    public let flowContainer: ContainerType

    public init(with container: ContainerType, defaultPresentAction: @escaping  DefaultStepActionType, defaultDismissAction: @escaping  DefaultStepActionType) {
        flowContainer = container
        presentAction = defaultPresentAction
        dismissAction = defaultDismissAction
    }

    public func addStep(with: (_ stepFactory: MakeStep<ContainerType>) -> FlowStep<ContainerType>) -> Flowter<ContainerType> {
        let step = with(MakeStep(flowter: self))

        steps.last?.nextStep = step

        if step.endFlowAction == nil && step.presentAction == nil {
            step.presentAction = presentAction
        }

        if step.dismissAction == nil {
            step.dismissAction = dismissAction
        }

        step.container = flowContainer
        steps.append(step)
        return self
    }

    public func addEndFlowStep(_ action: @escaping () -> Void ) -> FinishedFlowter<ContainerType> {
        let flow = self.addStep(with: { (_) -> FlowStep<ContainerType> in
            let step = FlowStep<ContainerType>()

            step.setEndFlowAction {
                action()
            }

            return step
        })

        return FinishedFlowter(flowter: flow)
    }
}

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

    private static func defaultPresent() ->  DefaultStepActionType {
        return { (vc, container) in
            container.dismiss(animated: true)
        }
    }

    private static func defaultDismiss() ->  DefaultStepActionType {
        return { (vc, container) in
            container.present(vc, animated: true)
        }
    }
}

extension Flowter where ContainerType == UINavigationController {
    private static func defaultPresent() ->  DefaultStepActionType {
        return { (vc, container) in
            container.popViewController(animated: true)
        }
    }

    private static func defaultDismiss() ->  DefaultStepActionType {
        return { (vc, container) in
            container.pushViewController(vc, animated: true)
        }
    }
}
