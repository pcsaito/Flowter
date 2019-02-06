//
//  FlowStepViewController.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 17/05/18.
//  Copyright 2018 Zazcar. All rights reserved.
//
import UIKit

//should call flowStep.next() or optionally flowStep.back() to continue the flow
public protocol Flowtable where Self: UIViewController {
    var flow: FlowStepInfo? { get set }

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
