import Foundation

public class Flowter<ContainerType> where ContainerType: UIViewController {

    public typealias StepFactoryType<T: FlowStepViewControllerProtocol> = (_ stepFactory: MakeStep<T,ContainerType>) -> FlowStep<T,ContainerType>
    public typealias DefaultStepActionType = ( (_ vc: UIViewController, _ container: ContainerType) -> Void)
    public typealias EndFlowStepActionType = (_ container: ContainerType) -> Void

    internal var steps = [FlowStepProtocol]()
    private let presentAction:  DefaultStepActionType
    private let dismissAction:  DefaultStepActionType

    public let flowContainer: ContainerType

    public init(with container: ContainerType,
                defaultPresentAction: @escaping  DefaultStepActionType = Flowter<ContainerType>.defaultPresent(),
                defaultDismissAction: @escaping  DefaultStepActionType = Flowter<ContainerType>.defaultDismiss())
    {
        flowContainer = container
        presentAction = defaultPresentAction
        dismissAction = defaultDismissAction
    }

    public func addStep<ControllerType: FlowStepViewControllerProtocol>(with: StepFactoryType<ControllerType>) -> Flowter<ContainerType> {
        let step = with(MakeStep<ControllerType,ContainerType>())
        step.container = flowContainer

        var lastStep = steps.last
        lastStep?.nextStep = step
        steps.append(step)

        if step.endFlowAction == nil && step.presentAction == nil {
            step.presentAction = presentAction
        }

        if steps.count != 0 && step.dismissAction == nil {
            step.dismissAction = dismissAction
        }

        if step.isLastStep, let endFlowAction = step.endFlowAction {
            steps.forEach { (eachStep) in
                var mutableStep = eachStep
                if let definedEndStep = mutableStep.endFlowAction {
                    mutableStep.endFlowAction = { [weak self] in
                        definedEndStep()
                        self?.clearSteps()
                    }
                } else {
                    mutableStep.endFlowAction = { [weak self] in
                        endFlowAction()
                        self?.clearSteps()
                    }
                }
            }
        }

        return self
    }

    public func addEndFlowStep(_ action: @escaping EndFlowStepActionType) -> FinishedFlowter<ContainerType> {
        let flow = self.addStep(with: { [weak self] (_) -> FlowStep<EndFlowStubController, ContainerType> in
            let step = FlowStep<EndFlowStubController, ContainerType> { EndFlowStubController() }
            step.isLastStep = true

            step.endFlowAction = { [weak flowContainer = self?.flowContainer] in
                guard let container = flowContainer else { return }
                action(container)
            }

            return step
        })
        return FinishedFlowter(flowter: flow)
    }

    private func clearSteps() {
        steps.forEach { $0.destroy() }
        steps.removeAll()
    }
}

//Convenience initializers
extension Flowter {
    public static func defaultPresent() -> DefaultStepActionType {
        return { (vc, container) in
            if let navContainer = container as? UINavigationController {
                navContainer.pushViewController(vc, animated: true)
            } else {
                container.present(vc, animated: true)
            }
        }
    }

    public static func defaultDismiss() -> DefaultStepActionType {
        return { (vc, container) in
            if let navContainer = container as? UINavigationController {
                navContainer.popViewController(animated: true)
            } else {
                container.dismiss(animated: true)
            }
        }
    }
}
