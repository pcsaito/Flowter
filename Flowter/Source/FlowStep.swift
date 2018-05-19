import Foundation

internal protocol FlowStepProtocol {
    var nextStep: FlowStepProtocol? { get set }
    var endFlowAction: ( () -> Void)? { get set }

    func present(_ updating: Bool)
    func dismiss()
    
    func destroy()
}

public class FlowStep<ControllerType: FlowStepViewControllerProtocol, ContainerType>: FlowStepProtocol {
    public typealias StepActionType = ( (_ vc: ControllerType, _ container: ContainerType) -> Void)
    public typealias ViewControllerFactoryType = () -> ControllerType

    private let viewControllerFactory: ViewControllerFactoryType

    internal var presentAction: StepActionType?
    internal var dismissAction: StepActionType?
    internal var endFlowAction: ( () -> Void)?

    internal var isLastStep: Bool = false
    internal var nextStep: FlowStepProtocol?
    internal var container: ContainerType?

    lazy var viewController: ControllerType = { self.viewControllerFactory() }()

    public init(with factory: @escaping ViewControllerFactoryType) {
        self.viewControllerFactory = factory
    }

    public func setPresentAction(_ action: @escaping StepActionType) {
        presentAction = action
    }

    public func setDismissAction(_ action: @escaping StepActionType) {
        dismissAction = action
    }

    public func setEndFlowAction(_ action: @escaping ( () -> Void)) {
        endFlowAction = action
    }

    internal func present(_ updating: Bool = false) {
        guard let containerController = container else { fatalError("Flow Step does not have a container") }

        viewController.flow = FlowStepInfo(flowStep: self)
        presentAction?(viewController, containerController)
    }

    internal func dismiss() {
        guard let containerController = container else { fatalError("Flow Step does not have a container") }

        dismissAction?(viewController, containerController)
    }

    internal func destroy() {
        presentAction = nil
        dismissAction = nil
        endFlowAction = nil

        container = nil
        nextStep = nil

        if !isLastStep {
            viewController.flow = nil
        }
    }
}

public struct MakeStep<ControllerType: FlowStepViewControllerProtocol, ContainerType: UIViewController> {
    internal let flowter: Flowter<ContainerType>

    public func make(with factory: @autoclosure @escaping () -> ControllerType) -> FlowStep<ControllerType,ContainerType> {
        return FlowStep<ControllerType,ContainerType>(with: factory)
    }
}
