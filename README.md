## Flowter
A lightweight, swifty and customizable UIViewController flow cordinator

### Install
#### Carthage
Just add the entry to your Cartfile:
```
github "Zazcar/Flowter"
```
Don't forget to run your favorite carthage command.

#### CocoaPods (soon...)
Simply add Flowter to your Podfile:
```
pod 'Flowter'
```
Don't forget to run your favorite cocoapods command.

### Basic usage
Create the flow and set its UIViewControllers and a Containter.

The Flowter can be created anywhere, regarding that you have a reference to who will present your flow, just use it on the startFlow closure:
```swift
Flowter(with: UINavigationController())
	.addStep { $0.make(with: StepViewController(withLabel: "1st Step"))}
	.addStep { $0.make(with: StepViewController(withLabel: "2nd Step"))}
	.addStep { $0.make(with: StepViewController(withLabel: "3rd Step"))}
	.addEndFlowStep { (container) in
		container.dismiss(animated: true)
	}
	.startFlow { (container) in
		myNavigationController.present(container, animated: true)
	}
```

You have to make your controllers conforming to the protocol Flowtable.

This only specify that your controllers have an var named flow of type FlowStepInfo?
```swift
	var flow: FlowStepInfo?
```

You call this on the controller when it is ready to proceed with the flow:
```swift
private func nextStep() {
	flow?.next()
}
```

### Dependency injection
You can fully customize the factory clousure of each of your step UIViewController subclass, at this moment you can feed it with it's needings.

Enjoy the short versions thanks to the trailing closure and shorthand argument name sugars.
```swift
let newUser = User()

Flowter(with: UINavigationController())
	.addStep { $0.make(with: FirstStepViewController(withUser: newUser))}
	.addStep {
		$0.make { () -> SecondStepViewController in
			let viewModel = SecondStepViewModel(with: newUser)
			return SecondStepViewController(with: viewModel)
		}
	}
	.addStep(with: { (stepFactory) -> FlowStep<ThirdStepViewController, UINavigationController> in
		let step = stepFactory.make(with: ThirdStepViewController())
		step.setPresentAction({ (thirdStepVC, container) in
			thirdStepVC.setUser(newUser)
			thirdStepVC.setCustomParameter(foo: false)
			container.pushViewController(thirdStepVC, animated: false)
		})
		return step
	})
	.addEndFlowStep { (container) in
		container.dismiss(animated: true)
	}
	.startFlow { [weak self] (container) in
		self?.present(container, animated: true)
	}
```
You can do every thing you could do inside your viewControllers, in an easy to visualize and flexible syntax.

### Custom presentation and dismiss code
#### Presentation:
You have control of the presentation code of your controllers too! 
```swift
	.addStep(with: { (stepFactory) -> FlowStep<StepViewController, UINavigationController> in
		let step = stepFactory.make(with: StepViewController(withLabel: "Flow Start"))
	
		step.setPresentAction({ (welcomeVC, container) in
			welcomeVC.setAsWelcomeStep()
			container.pushViewController(welcomeVC, animated: false) 
			//I don't known why I would do this...
		})
		return step
	})
```

#### Dissmiss:
The dismiss is also avaliable when you view controllers dont rely on the automatic UINavigationController back button.

You have to call the FlowStepInfo method back to navigate back, your step dismissAction closure will be called and you will be responsable for the dismiss of the viewController
```swift
	.addStep(with: { (stepFactory) -> FlowStep<StepViewController, UINavigationController> in
		let step = stepFactory.make(with: StepViewController(withLabel: "Flow Start"))
	
		step.setPresentAction({ (welcomeVC, container) in
			container.pushViewController(welcomeVC, animated: false)
		})
		
		step.setDismissAction({ (welcomeVC, container) in
			container.dismiss(animated: false, completion: {
				//some completion code
			})
		})

		return step
	})
```

On your Flowtable conforming UIViewController subclass:
```swift
private func backStep() {
	flow?.back()
}

private func nextStep() {
	flow?.next()
}
```

### Dynamically built flow
A flow can also be built with variable number and type of steps. To do that, store the flowter on a let and use this reference to add new steps.
 ```swift
private func openFlow(includeSecondStep: Bool) {
	let flowter = Flowter(with: UINavigationController())
		.addStep { $0.make(with: StepViewController(withLabel: "1st Step"))}
	
	if includeSecondStep {
		flowter.addStep { $0.make(with: StepViewController(withLabel: "2nd Step"))}
	}

	flowter
		.addStep { $0.make(with: StepViewController(withLabel: "3rd Step"))}
		.addEndFlowStep { (container) in
			container.dismiss(animated: true)
		}
		.startFlow { (container) in
			myNavigationController.present(container, animated: true)
		}
}
 ```

### Code reusage
You can and should use the same controllers that is already used elsewhere in your App outside a flow!

Just guard or check the existence of the `flow`, or call it using the optional chaining like `flow?.next()`.
```swift
private func close() {
	guard let flow = self?.flow else { 
	//on stand alone usage just pop the view controller
		self.navigationController?.popViewController(animated: true)
		return
	}
	
	//inside a Flowter, proceed the flow
	flow.next() 
}
```

### Don't forget to weaken your selfs when nescessary. 
#### There is a bunch of closure being stored and this is vital to avoid memory leaks when the flow is closed.
