import Foundation

public struct FinishedFlowter<ContainerType> where ContainerType: UIViewController {
    internal let flowter: Flowter<ContainerType>

    public func startFlow(flowPresentAction: ( (_ flowContainer: ContainerType) -> Void)) {
        guard let step = flowter.steps.first else { return }

        step.present(false)
        flowPresentAction(flowter.flowContainer)
    }
}
