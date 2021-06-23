import Foundation

public class StateMachine<S: State, E: Event> {
    public typealias EventToState = (E, S)
    public private(set) var state: S
    private var eventsTransitions: [E : [Transition<S>]] = [:]
    private var conditionMappings: [EventToTransition<E, S> : Condition] = [:]
    private var handlers: [Transition<S>: Handler] = [:]
    let dispatchQueue: DispatchQueue

    public init(initialState: S, workQueue: DispatchQueue? = nil) {
        self.dispatchQueue = workQueue ?? DispatchQueue(label: "statemachine", qos: .background, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
        state = initialState
    }

    public func addTransition(_ eventToTransition: EventToTransition<E, S>, condition: Condition? = nil, handler: @escaping Handler) {
        addTransition(eventToTransition.transition, onEvent: eventToTransition.event, condition: condition, handler: handler)
    }

    public func addTransition(from: S, to: S, onEvent event: E, condition: Condition? = nil, handler: @escaping Handler) {
        addTransition(Transition(fromState: from, toState: to), onEvent: event, condition: condition, handler: handler)
    }

    public func addTransition(_ transition: Transition<S>, onEvent event: E, condition: Condition? = nil, handler: @escaping Handler) {
        if eventsTransitions[event] == nil {
            eventsTransitions[event] = []
        }
        let conditionsKey = EventToTransition(event: event, transition: transition)
        guard conditionMappings[conditionsKey] == nil else  {
            fatalError("\(transition) on event: \(event) - this transition is already defined")
        }
        conditionMappings[conditionsKey] = condition ?? { true }
        eventsTransitions[event]!.append(transition)
        handlers[transition] = handler
    }

    public func addTransitions(from: S, _ transitions: AvailableTransition<E, S>...) {
        transitions.forEach {
            addTransition(from: from, to: $0.to, onEvent: $0.event, condition: $0.condition, handler: $0.handler)
        }
    }

    public func addTransitions(start: S,  @AvailableTransitionBuilder transitions: () -> [AvailableTransition<E, S>]) {
        transitions().forEach {
            addTransition(from: start, to: $0.to, onEvent: $0.event, condition: $0.condition, handler: $0.handler)
        }
    }

    private func findTransition(for event: E) -> Transition<S>? {
        guard let eventTransitions = eventsTransitions[event] else {
            return nil
        }
        return eventTransitions.first {
            let key = EventToTransition(event: event, transition: $0)
            return $0.fromState == self.state
                    && (conditionMappings[key]?() ?? true )
        }
    }

    public func event(_ event: E) -> Bool {
        guard let transition = findTransition(for: event) else {
            return false
        }
        if let handler = handlers[transition] {
            dispatchQueue.async {
                handler()
            }
        }
        self.state = transition.toState
        return true
    }

    @resultBuilder
    public struct AvailableTransitionBuilder {
        public static func buildBlock(_ components: AvailableTransition<E, S>...) -> [AvailableTransition<E, S>] {
            components
        }
    }
}

public struct AvailableTransition<E: Event, S: State> {
    let to: S
    let event: E
    let condition: Condition?
    let handler: Handler

    public init(_ to: S, _ event: E, _ condition: Condition? = nil, _ handler: @escaping Handler) {
        self.to = to
        self.event = event
        self.condition = condition
        self.handler = handler
    }

    public init(availableTransition: AvailableTransition<E,S>, _ handler: @escaping Handler) {
        self.to = availableTransition.to
        self.event = availableTransition.event
        self.condition = availableTransition.condition
        self.handler = handler
    }
}

public struct EventToTransition<E: Event, S: State>: Hashable {
    public let event: E
    public let transition: Transition<S>
    init(event: E, transition: Transition<S>) {
        self.event = event
        self.transition = transition
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(event.hashValue)
        hasher.combine(transition.hashValue)
    }
}

public func ~> <S>(fromState: S, toState: S) -> Transition<S> {
    return Transition(fromState: fromState, toState: toState)
}

//infix operator ==> : MultiplicationPrecedence
infix operator ==> : AdditionPrecedence

public func ==> <S, E>(event: E, toState: S) -> AvailableTransition<E, S> {
    AvailableTransition(toState, event, nil) { }
}

infix operator ?! : AdditionPrecedence

public func ?! <S, E>(eventToState: AvailableTransition<E, S>, condition: @escaping Condition) -> AvailableTransition<E, S> {
    AvailableTransition(eventToState.to, eventToState.event, condition) { }
}

//infix operator | : AdditionPrecedence

public func | <E, S>(availableTransition: AvailableTransition<E, S>, handler: @escaping Handler) -> AvailableTransition<E, S> {
    AvailableTransition(availableTransition: availableTransition, handler)
}

public func ==> <E, S>(availableTransition: AvailableTransition<E, S>, handler: @escaping Handler) -> AvailableTransition<E, S> {
    AvailableTransition(availableTransition: availableTransition, handler)
}

enum TransferState: State {
    case start, fromSelection, toSelection, setAmount, confirm, complete
}

enum TransferEvent: Event {
    var payload: Any? { return nil }

    case onFromAccountChosen
    case onToAccountChosen
    case onChangeFromAccount
    case onChangeToAccount
    case onAmountSet
    case onConfirm
}

class TransferLogicController: CoordinatorDelegate {
    var from: String?
    var to: String?
    var amount: Double?
    var fromChosen: Bool { from != nil }
    var toChosen: Bool { to != nil }
    let machine = StateMachine<TransferState, TransferEvent>(initialState: .start)
    lazy var navigator = Coordinator(delegate: self)

    init() {
        configureStateMachine()
    }

    private func configureStateMachine() {
        machine.addTransitions(from: .start,
                               .onFromAccountChosen ==> .toSelection
                                | navigator.showToSelection,
                               .onToAccountChosen ==> .fromSelection
                                | navigator.showFromSelection
        )

        machine.addTransitions(from: .toSelection,
                               .onToAccountChosen ==> .setAmount ?! { self.fromChosen }
                                | navigateToAmountSelection,
                               .onToAccountChosen ==> .fromSelection ?! { !self.fromChosen }
                                | navigator.showFromSelection
        )

        machine.addTransitions(from: .fromSelection,
                               .onFromAccountChosen ==> .setAmount ?! { self.toChosen }
                                | navigateToAmountSelection,
                               .onFromAccountChosen ==> .toSelection ?! { !self.toChosen }
                                | navigator.showToSelection
        )

        machine.addTransitions(from: .setAmount,
                               .onAmountSet ==> .confirm
                                | navigateToConfirm,
                               .onChangeFromAccount ==> .fromSelection
                                | navigator.showFromSelection,
                               .onChangeToAccount ==> .toSelection
                                | navigator.showToSelection
        )

        machine.addTransitions(from: .confirm,
                               .onConfirm ==> .complete
                                | navigator.showSuccess
        )
    }

    private func navigateToAmountSelection() {
        navigator.showAmountSelection(SelectAmountModel(from: from!, to: to!))
    }

    private func navigateToConfirm() {
        navigator.showConfirm(ConfirmModel(from: from!, to: to!, amount: amount!))
    }

    func onFromSelected(_ from: String) {
        self.from = from
        machine.event(.onFromAccountChosen)
    }

    func onToSelected(_ to: String) {
        self.to = to
        machine.event(.onToAccountChosen)
    }

    func onAmountSelected(_ amount: Double) {
        self.amount = amount
        machine.event(.onAmountSet)
    }

    func onConfirmTransfer() {
        machine.event(.onConfirm)
    }
}

let controller = TransferLogicController()
controller.onFromSelected("From")
//
//var fromChosen = false
//var toChosen = false
//let machine = StateMachine<TransferState, TransferEvent>(initialState: .start)
//machine.addTransition(.start ~> .toSelection, onEvent: .onFromAccountChosen) {
//    fromChosen = true
//    print("start->to")
//}
//
//machine.addTransition(from: .start, to: .fromSelection, onEvent: .onToAccountChosen) {
//    toChosen = true
//    print("start->from")
//}
//
////machine.addTransition(from: .toSelection,
////                      to: .setAmount,
////                      onEvent: .onToAccountChosen,
////                      condition: { fromChosen }) {
////    toChosen = true
////    print("to->amount")
////}
////
////machine.addTransition(from: .toSelection, to: .fromSelection, onEvent: .onToAccountChosen, condition: { !fromChosen }) {
////    toChosen = true
////    print("to->from")
////}
//
//machine.addTransitions(from: .toSelection,
//                       .onToAccountChosen ==> .setAmount ?! { print("onToAccountChosen: \(fromChosen)"); return fromChosen }
//                        | { toChosen = true; print("to->amount") },
//                       .onToAccountChosen ==> .fromSelection ?! { print("onToAccountChosen: \(fromChosen)"); return !fromChosen }
//                        | { toChosen = true; print("to->from") }
//)
//
//machine.addTransition(from: .fromSelection, to: .setAmount, onEvent: .onFromAccountChosen, condition: { toChosen }) {
//    fromChosen = true
//    print("from->amount")
//}
//
//machine.addTransition(from: .fromSelection, to: .toSelection, onEvent: .onFromAccountChosen, condition: { !toChosen }) {
//    fromChosen = true
//    print("from->amount")
//}
//
//machine.addTransition(from: .setAmount, to: .fromSelection, onEvent: .onChangeFromAccount) {
//    print("amount->from")
//}
//
//machine.addTransition(from: .setAmount, to: .toSelection, onEvent: .onChangeToAccount) {
//    print("amount->from")
//}
//
//machine.addTransition(from: .setAmount, to: .confirm, onEvent: .onAmountSet) {
//    print("amount->confirm")
//}
//
//machine.addTransition(from: .confirm, to: .complete, onEvent: .onConfirm) {
//    print("confirm->complete")
//}
//
////// to -> from -> amount -> confirm
////machine.event(.onToAccountChosen)
////machine.event(.onFromAccountChosen)
////machine.event(.onAmountSet)
////machine.event(.onConfirm)
////machine.state
////
////// from -> to -> amount -> confirm
////machine.event(.onFromAccountChosen)
////machine.event(.onToAccountChosen)
////machine.event(.onAmountSet)
////machine.event(.onConfirm)
////machine.state
////
////// to -> from -> amount -> from -> amount -> confirm
////machine.event(.onToAccountChosen)
////machine.event(.onFromAccountChosen)
////machine.event(.onChangeFromAccount)
////machine.event(.onFromAccountChosen)
////machine.event(.onAmountSet)
////machine.event(.onConfirm)
////machine.state
//
//// to -> from -> amount -> from -> amount -> confirm
//machine.event(.onFromAccountChosen)
//machine.event(.onToAccountChosen)
//machine.event(.onChangeToAccount)
//machine.event(.onToAccountChosen)
//machine.event(.onAmountSet)
//machine.event(.onConfirm)
//machine.state
