import Foundation

public struct FlowStepInfo {
    fileprivate var flowStep: Make

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

public class Make {
    public typealias ViewControllerFactoryType = ( () -> FlowStepViewControllerProtocol)
    private let viewControllerFactory: ViewControllerFactoryType

    public typealias StepActionType = ( (_ vc: UIViewController) -> Void)
    internal var presentAction: StepActionType?
    internal var dismissAction: StepActionType?
    internal var endFlowAction: ( () -> Void)?

    internal var nextStep: Make?

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
}

extension Make {
    internal convenience init() {
        self.init(with: { BogusFlowController() })
    }

    internal func present(_ updating: Bool = false) {
        guard let viewController = vc as? UIViewController else { fatalError("FlowStepViewControllerProtocol is not a UIViewController") }

        vc.flow = FlowStepInfo(flowStep: self)
        presentAction?(viewController)
    }

    internal func dismiss() {
        guard let viewController = vc as? UIViewController else { fatalError("FlowStepViewControllerProtocol is not a UIViewController") }
        dismissAction?(viewController)
    }
}
