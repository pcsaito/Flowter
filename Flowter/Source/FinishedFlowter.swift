//
//  FinishedFlowter.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 18/05/18.
//  Copyright 2018 Zazcar. All rights reserved.
//
import UIKit

public struct FinishedFlowter<ContainerType> where ContainerType: UIViewController {
    internal let flowter: FilledFlowter<ContainerType>

    public func startFlow(flowPresentAction: @escaping ( (_ flowContainer: ContainerType) -> Void)) {
        guard let step = flowter.steps.first else { return }

        (step as? FlowStepType)?.present(false)

        let presentFlow = { [weak flowContainer = flowter.flowContainer] in
            guard let container = flowContainer else { return }
            flowPresentAction(container)
        }
        presentFlow()
    }
}
