import Foundation

//should call flowStep.next() or optionally flowStep.back() to continue the flow
public protocol FlowStepViewControllerProtocol {
    var flow: FlowStepInfo? { get set }

    func updateFlowStepViewController()
}

public extension FlowStepViewControllerProtocol {
    func updateFlowStepViewController() { }
}

internal class BogusFlowController: UIViewController, FlowStepViewControllerProtocol {
    var flow: FlowStepInfo?

    init() {
        fatalError("BogusFlowController should not be instaciated")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("BogusFlowController should not be instaciated")
    }

    func updateFlowStepViewController() { }
}
