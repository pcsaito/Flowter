import Foundation

public struct FlowStepInfo {
    internal var flowStep: FlowStepProtocol

    public func next(updating: Bool = false) {
        if let endFlow = flowStep.nextStep?.endFlowAction {
            return endFlow()
        }
        flowStep.nextStep?.present(updating)
    }

    public func back() {
        flowStep.dismiss()
    }

    public func endFlow() {
        flowStep.endFlowAction?()
    }
}
