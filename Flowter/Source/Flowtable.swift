//
//  FlowStepViewController.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 17/05/18.
//  Copyright 2018 Zazcar. All rights reserved.
//
import UIKit

/// A Flowtable is an UIViewController subclass that can be used to create FlowSteps to a Flowter.
public protocol Flowtable where Self: UIViewController {
    
    /// This is the proxy you will use to go next(context: Any?) or back() on your flow.
    var flow: FlowStepInfo? { get set }

    /// This method provides you with the context passed on flow.next(context: Any?) call from the previous step.
    /// - Called just before presentation.
    func updateFlowtableViewController(with context: Any?)
}

public extension Flowtable {
    func updateFlowtableViewController(with context: Any?) {
        if let context = context {
            var dumpString = String()
            dump(context, to: &dumpString)
            
            print("[Flowter] Lost context on \(String(describing: self))")
            print("Implement updateFlowtableViewController(context: Any?) to receive the context object and suppress this warning")
            print("Context object dump: \(dumpString)")
        }
    }
}
