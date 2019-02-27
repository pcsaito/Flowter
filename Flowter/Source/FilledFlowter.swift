//
//  FilledFlowter.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 25/01/19.
//  Copyright © 2019 Zazcar. All rights reserved.
//
import UIKit

/// FinishedFlowter is a subclass of Flowter returned on step addition.
/// It behaves identically to Flowter execpt it can return an non-optional FinishedFlowter on addEndFlowStep(:) method.
public class FilledFlowter<ContainerType: UIViewController>: Flowter<ContainerType> {
    internal init(basedOn flowter: Flowter<ContainerType>) {
        super.init(with: flowter.flowContainer, defaultPresentAction: flowter.presentAction,
                   defaultDismissAction: flowter.dismissAction, flowSteps: flowter.steps)
    }
    
    /**
     Add a step to Flowter object providing an StepFactory that will be allocated only before presenting.
     - Parameters:
         - with: A StepFactory that returns an FlowStep that represents the step
     
     - Waning: Never discart a chained FilledFlowter, keep an reference to continue chaining
     - Returns: A FilledFlowter ready to be finished.
     */
    public override func addStep<ControllerType>(with: StepFactoryType<ControllerType>) -> FilledFlowter<ContainerType> {
        return super.addStep(with: with) //     Never discart a FilledFlowter, keep an reference to continue chaining

    }
    
    /**
     Add the end step to FilledFlowter providing an EndFlowStepAction with the flow container dismiss code.
     - Parameters:
         - action: EndFlowStepActionType with the flow container dismiss code.
     
     - Returns: A FinishedFlowter ready to be started.
     */
    public override func addEndFlowStep(_ action: @escaping EndFlowStepActionType) -> FinishedFlowter<ContainerType> {
        let endStep = MakeEndStep<ContainerType>().makeEndFlow(with: flowContainer)
        
        var lastStep = steps.last
        lastStep?.nextStep = endStep
        steps.append(endStep)
        
        endStep.endFlowAction = { [weak self] in
            guard let container = self?.flowContainer else { return }
            action(container)
        }
        
        if let endFlowAction = endStep.endFlowAction {
            steps.forEach { (eachStep) in
                var mutableStep = eachStep
                var endAction = endFlowAction
                if let definedEndStep = mutableStep.endFlowAction {
                    endAction = definedEndStep
                }
                
                mutableStep.endFlowAction = {
                    endAction()
                    self.clearSteps()
                    self.clearNavigation()
                }
            }
        }
        
        return FinishedFlowter(basedOn: self)
    }
}
