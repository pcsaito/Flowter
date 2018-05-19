import Foundation

public struct FlowStepInfo {
    internal var flowStep: FlowStepProtocol

    public func next(updating: Bool = false) {
        guard let nextStep = flowStep.nextStep, !nextStep.isLastStep else {
            flowStep.nextStep?.endFlowAction?()
            return
        }

        nextStep.present(updating)
    }

    public func back() {
        flowStep.dismiss()
    }

    public func endFlow() {
        flowStep.endFlowAction?()
    }
}
