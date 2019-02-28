[![Build Status](https://travis-ci.org/Zazcar/Flowter.svg?branch=master)](https://travis-ci.org/Zazcar/Flowter)
[![codecov](https://codecov.io/gh/Zazcar/Flowter/branch/master/graph/badge.svg)](https://codecov.io/gh/Zazcar/Flowter)
[![Pod Platform](https://img.shields.io/cocoapods/p/Flowter.svg?style=flat)](https://cocoapods.org/pods/Flowter)
[![Pod License](https://img.shields.io/cocoapods/l/Flowter.svg?style=flat)](https://github.com/Zazcar/Flowter/blob/master/LICENSE)
[![Pod Version](https://img.shields.io/cocoapods/v/Flowter.svg?style=flat)](https://cocoapods.org/pods/Flowter)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Flowter
A lightweight, swifty and customizable UIViewController flow cordinator DSL.

It support static or dynamically build flows with a nice generic syntax.

### Install
#### Carthage
Just add the entry to your Cartfile:
```
github "Zazcar/Flowter"
```
Don't forget to run your favorite carthage command.

#### CocoaPods
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

You have to make your controllers conforming to the protocol ```Flowtable```.

This only specify that your controllers have an var named flow of type ```FlowStepInfo?```
```swift
	var flow: FlowStepInfo?
```

You call this on the controller when it is ready to proceed with the flow:
```swift
private func nextStep() {
	flow?.next()
}
```
### Piece by piece
Let's start with the ```Flowter```, it is just a temporary representation of the flow that you are building. You initialize it with a container, that shoud be an instance of UIViewController or UINavigationController, after that just add steps to it:
```swift
let flowContainer = UINavigationController()
let flowter = Flowter(with: flowContainer)

flowter.addStep(with: { (stepFactory) -> FlowStep<FlowtableViewController, UINavigationController> in
	return stepFactory.make(with: FlowtableViewController()) 
})
```
Your FlowtableViewController step will be added to the flow, it need to conform to the Flowtable protocol.

The view controller will be only instanciaded just before the presentation, and there are default presentation routines depending of the container type. So you will get a push and pop on your navigation based flow, and basic presentation on your UIViewController flow.
You can customize the presentation for the entirely flow or for each step, see the ahead....

After you end adding steps, you need to end you flow with its dismiss code and just after that you can finally start your flow
```swift
let finishedFlowter = flowter.addEndFlowStep { (container) in
	container.dismiss(animated: true)
}

finishedFlowter?.startFlow { (container) in
	someViewController.present(container, animated: true)
}
```

Of couse this can be writen in a more compact way
```swift
Flowter(with: UINavigationController())
	.addStep { $0.make(with: FlowtableViewController()) }
	.addEndFlowStep { $0.dismiss(animated: true) }
	.startFlow { someViewController.present($0, animated: true) }
```
Enjoy the short versions thanks to the trailing closure and shorthand argument name sugars.
Use the most convinient syntax when it is needed...

### Dependency injection
You can fully customize the factory clousure of each of your step UIViewController subclass, at this moment you can feed it with it's needings.

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

### Passing a context object to the next step
Optionally you can pass an arbitrary object to the next step calling `flow?.next(context: Any?)`
```swift
	let info: String = "context string"

	flow?.next(context: info)
```

The context will be delivered on `func updateFlowtableViewController(with context: Any?)` of the next step viewController, just before presentation.
```swift
func updateFlowtableViewController(with context: Any?) {
	guard let contextString = context as? String else {
		//do something or just return
		return
	}
	doSomething(with: contextString)
}
```

### Custom presentation and dismiss code
#### Defaults
Flow wide custom presentation or dissmiss code can be provided at the creation of the flow, when no custom routine is defined on the step these implementations will take place
```swift
let flowContainer = CustomNavigationController()

Flowter(with: flowContainer, 
		defaultPresentAction: { (vc, container) in
        	container.customPushViewController(vc)
		},
		defaultDismissAction: { (vc, container) in
			container.customPopViewController()
		})					
```
Expect the exact type of container that you used on the flow creation, type cast is not needed thanks to generics (:

#### Presentation:
To control the presentation of just one of your controllers 
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
 
Add the steps always to the same Flowter object. If you want chain steps, keep the reference to the returned FilledFlowters and use it to add more steps or finish the flow. 

### Code reusage
You can and should use the same controllers that is already used elsewhere in your App outside a flow!

Just guard or check the existence of the `flow`, or call it using the optional chaining like `flow?.next()`.
```swift
private func close() {
	if let flow = self?.flow { 
		//inside a Flowter, proceed the flow
		flow.next() 
		return
	}
	
	//on stand alone usage just pop the view controller
	self.navigationController?.popViewController(animated: true)
}
```

### Don't forget to weaken your selfs when nescessary. 
#### There is a bunch of closure being stored and this is vital to avoid memory leaks when the flow is closed.
