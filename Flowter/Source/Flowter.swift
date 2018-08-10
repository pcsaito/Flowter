//
//  Flowter.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 17/05/18.
//  Copyright © 2018 Zazcar. All rights reserved.
//

import Foundation

public class Flowter<ContainerType> where ContainerType: UIViewController {

    public typealias StepFactoryType<T: Flowtable> = (_ stepFactory: MakeStep<T,ContainerType>) -> FlowStep<T,ContainerType>
    public typealias DefaultStepActionType = ( (_ vc: UIViewController, _ container: ContainerType) -> Void)
    public typealias EndFlowStepActionType = (_ container: ContainerType) -> Void

    internal var steps = [FlowStepType]()

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

    @discardableResult
    public func addStep<ControllerType>(with: StepFactoryType<ControllerType>) -> Flowter<ContainerType> {
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
                var endAction = endFlowAction
                if let definedEndStep = mutableStep.endFlowAction {
                    endAction = definedEndStep
                }

                mutableStep.endFlowAction = {
                    endAction()
                    self.clearSteps()
                    self.clearNavigation()
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

    //private methods
    private func clearNavigation() {
        //fixme
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let navigationContainer = self?.flowContainer as? UINavigationController else { return }
            navigationContainer.viewControllers = [UIViewController]()
        }
    }

    private func clearSteps() {
        steps.forEach { $0.destroy() }
        steps.removeAll()
    }

    #if DEBUG
    deinit {
        print("Bye Flowter: \(self)")
    }
    #endif
}

//for convenience initializers usage
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
