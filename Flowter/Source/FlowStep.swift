//
//  FlowStep.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 17/05/18.
//  Copyright 2018 Zazcar. All rights reserved.
//
import UIKit

/// Proxy that gets ViewControllerFactoryType's and returns FlowStep's
public struct MakeStep<ControllerType: Flowtable, ContainerType: UIViewController> {
    let container: ContainerType
    
    /**
     Make an FlowStep based on the factory that returns a UIViewController: Flowtable
     
     - Parameters:
         - withFactoryClosure: A closure that returns the UIViewController: Flowtable of this step
     
     - Returns: A FlowStep with a Flowtable factory, a container and presentation/dismiss/endFlow actions
     */
    public func make(withFactoryClosure: @escaping () -> ControllerType) -> FlowStep<ControllerType,ContainerType> {
        return FlowStep<ControllerType,ContainerType>(with: withFactoryClosure, on: container)
    }

    /**
     Make an FlowStep based on an autoclosure factory that returns a UIViewController: Flowtable
     
     - Parameters:
         - controller: A autoclosure that returns the UIViewController: Flowtable of this step
     
     - Returns: A FlowStep with a Flowtable factory, a container and presentation/dismiss/endFlow actions
     */
    public func make(with controller: @autoclosure @escaping () -> ControllerType) -> FlowStep<ControllerType,ContainerType> {
        return make(withFactoryClosure: controller)
    }
}

/// A FlowStep contains the step UIViewController factory, a container and presentation/dismiss/endFlow actions
public class FlowStep<ControllerType: Flowtable, ContainerType>: FlowStepType {
    
    /// Function type of an presentation or dismiss actions
    public typealias StepActionType = ( (_ vc: ControllerType, _ container: ContainerType) -> Void)
    
    /// A closure that returns the ControllerType: Flowtable object
    public typealias ViewControllerFactoryType = () -> ControllerType

    private let viewControllerFactory: ViewControllerFactoryType

    internal var presentAction: StepActionType?
    internal var dismissAction: StepActionType?
    internal var endFlowAction: ( () -> Void)?

    internal var nextStep: BaseFlowStepType?
    internal let container: ContainerType

    lazy var viewController: ControllerType = { [unowned self] in
        self.viewControllerFactory()
    }()

    /**
     Initializes a new Flowter object with a container and optionally custom default presentation or dismiss code for all your steps.
     - Parameters:
         - factory: A closure that returns the UIViewController: Flowtable of this step
         - container: The container that is presenting the flow
     
     - Returns: A FlowStep with a Flowtable factory, a container and presentation/dismiss/endFlow actions
     */
    public init(with factory: @escaping ViewControllerFactoryType, on container: ContainerType) {
        self.viewControllerFactory = factory
        self.container = container
    }

    /// Set a custom present StepAction to this step
    public func setPresentAction(_ action: @escaping StepActionType) {
        presentAction = action
    }

    /// Set a custom dismiss StepAction to this step
    public func setDismissAction(_ action: @escaping StepActionType) {
        dismissAction = action
    }

    /// Set a custom EndFlowStepAction that will be calling on premature flow dismissing on this step
    public func setEndFlowAction(_ action: @escaping ( () -> Void)) {
        endFlowAction = action
    }

    //private methods
    internal func present(with context: Any?) {
        viewController.flow = FlowStepInfo(flowStep: self)
        viewController.updateFlowtableViewController(with: context)

        presentAction?(viewController, container)
    }

    internal func dismiss() {
        dismissAction?(viewController, container)
    }

    internal func destroy() {
        presentAction = nil
        dismissAction = nil
        endFlowAction = nil

        nextStep = nil
        viewController.flow = nil
    }

    #if DEBUG
    deinit {
        print("Bye FlowStep: \(self.viewController.description)")
    }
    #endif
}
