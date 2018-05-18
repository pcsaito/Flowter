import Foundation

internal protocol FlowStepProtocol {
    var nextStep: FlowStepProtocol? { get }
    var endFlowAction: ( () -> Void)? { get }

    func present(_ updating: Bool)
    func dismiss()
}

public struct FlowStepInfo {
    fileprivate var flowStep: FlowStepProtocol

    public func next(updating: Bool = false) {
        if let endFlow = flowStep.nextStep?.endFlowAction {
            return endFlow()
        }
        flowStep.nextStep?.present(updating)
    }

    public func back() {
        flowStep.dismiss()
    }
}

public typealias ViewControllerFactoryType = () -> FlowStepViewControllerProtocol
public struct MakeStep<ContainerType: UIViewController> {
    internal let flowter: Flowter<ContainerType>

    public func make(with factory: @autoclosure @escaping () -> FlowStepViewControllerProtocol) -> FlowStep<ContainerType> {
        return FlowStep<ContainerType>(with: factory)
    }
}

public class FlowStep<ContainerType>: FlowStepProtocol {
    public typealias StepActionType = ( (_ vc: UIViewController, _ container: ContainerType) -> Void)
    private let viewControllerFactory: ViewControllerFactoryType

    internal var presentAction: StepActionType?
    internal var dismissAction: StepActionType?
    internal var endFlowAction: ( () -> Void)?

    internal var nextStep: FlowStepProtocol?
    internal var container: ContainerType?

    lazy var vc = { self.viewControllerFactory() }()

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


    internal convenience init() {
        self.init(with: { BogusFlowController() })
    }

    internal func present(_ updating: Bool = false) {
        guard let containerController = container else { fatalError("Flow Step does not have a container") }
        guard let viewController = vc as? UIViewController else { fatalError("FlowStepViewControllerProtocol is not a UIViewController") }

        vc.flow = FlowStepInfo(flowStep: self)
        presentAction?(viewController, containerController)
    }

    internal func dismiss() {
        guard let containerController = container else { fatalError("Flow Step does not have a container") }
        guard let viewController = vc as? UIViewController else { fatalError("FlowStepViewControllerProtocol is not a UIViewController") }

        dismissAction?(viewController, containerController)
    }
}
