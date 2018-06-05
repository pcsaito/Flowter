//
//  FinishedFlowter.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 18/05/18.
//  Copyright © 2018 Zazcar. All rights reserved.
//

import Foundation

public struct FinishedFlowter<ContainerType> where ContainerType: UIViewController {
    internal let flowter: Flowter<ContainerType>

    public func startFlow(flowPresentAction: @escaping ( (_ flowContainer: ContainerType) -> Void)) {
        guard let step = flowter.steps.first else { return }

        step.present(false)

        let presentFlow = { [weak flowContainer = flowter.flowContainer] in
            guard let container = flowContainer else { return }
            flowPresentAction(container)
        }
        presentFlow()
    }
}
