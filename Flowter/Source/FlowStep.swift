import Foundation

public struct MakeStep<ControllerType: FlowStepViewControllerProtocol, ContainerType: UIViewController> {
    public func make(with factory: @autoclosure @escaping () -> ControllerType) -> FlowStep<ControllerType,ContainerType> {
        return FlowStep<ControllerType,ContainerType>(with: factory)
    }
}

internal protocol FlowStepProtocol {
    var isLastStep: Bool { get }
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

    lazy var viewController: ControllerType = { [unowned self] in
        self.viewControllerFactory()
    }()

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

    //private methods
    internal func present(_ updating: Bool = false) {
        guard let containerController = container else { fatalError("Flow Step does not have a container") }

        viewController.flow = FlowStepInfo(flowStep: self)
        if updating {
            viewController.updateFlowStepViewController()
        }

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

    #if DEBUG
    deinit {
        print("Bye FlowStep: \(!isLastStep ? self.viewController.description : "EndStep")")
    }
    #endif
}
