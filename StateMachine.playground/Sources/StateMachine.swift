public protocol State: Hashable {}

public protocol Event: Hashable {
    var payload: Any? { get }
}

public struct Transition<S: State>: Hashable {
    public let fromState: S
    public let toState: S

    public init(fromState: S, toState: S) {
        self.fromState = fromState
        self.toState = toState
    }

    public static func == (lhs: Transition<S>, rhs: Transition<S>) -> Bool {
        lhs.fromState == rhs.fromState && lhs.toState == rhs.toState
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(fromState.hashValue)
        hasher.combine(toState.hashValue)
    }
}

extension Transition: CustomStringConvertible {
    public var description: String {
        "Transition \(fromState) -> \(toState)"
    }
}

public typealias Handler = () -> Void
public typealias Condition = () -> Bool

//public class StateMachine<S: State, E: Event> {
//    public typealias EventToState = (E, S)
//    public private(set) var state: S
//    private var eventsTransitions: [E : [Transition<S>]] = [:]
//    private var conditionMappings: [EventToTransition<E, S> : Condition] = [:]
//    private var handlers: [Transition<S>: Handler] = [:]
//
//    public init(initialState: S) {
//        state = initialState
//    }
//
//    public func addTransition(_ eventToTransition: EventToTransition<E, S>, condition: Condition? = nil, handler: @escaping Handler) {
//        addTransition(eventToTransition.transition, onEvent: eventToTransition.event, condition: condition, handler: handler)
//    }
//
//    public func addTransition(from: S, to: S, onEvent event: E, condition: Condition? = nil, handler: @escaping Handler) {
//        addTransition(Transition(fromState: from, toState: to), onEvent: event, condition: condition, handler: handler)
//    }
//
//    public func addTransition(_ transition: Transition<S>, onEvent event: E, condition: Condition? = nil, handler: @escaping Handler) {
//        if eventsTransitions[event] == nil {
//            eventsTransitions[event] = []
//        }
//        let conditionsKey = EventToTransition(event: event, transition: transition)
//        guard conditionMappings[conditionsKey] == nil else  {
//            fatalError("\(transition) on event: \(event) - this transition is already defined")
//        }
//        conditionMappings[conditionsKey] = condition ?? { true }
//        eventsTransitions[event]!.append(transition)
//        handlers[transition] = handler
//    }
//
//    public func addTransitions(from: S, _ transitions: AvailableTransition<E, S>...) {
//        transitions.forEach {
//            addTransition(from: from, to: $0.to, onEvent: $0.event, condition: $0.condition, handler: $0.handler)
//        }
//    }
//
//    public func addTransitions(start: S,  @AvailableTransitionBuilder transitions: () -> [AvailableTransition<E, S>]) {
//        transitions().forEach {
//            addTransition(from: start, to: $0.to, onEvent: $0.event, condition: $0.condition, handler: $0.handler)
//        }
//    }
//
//    private func findTransition(for event: E) -> Transition<S>? {
//        guard let eventTransitions = eventsTransitions[event] else {
//            return nil
//        }
//        return eventTransitions.first {
//            let key = EventToTransition(event: event, transition: $0)
//            return $0.fromState == self.state
//                    && (conditionMappings[key]?() ?? true )
//        }
//    }
//
//    public func event(_ event: E) -> Bool {
//        guard let transition = findTransition(for: event) else {
//            return false
//        }
//        if let handler = handlers[transition] {
//            handler()
//        }
//        self.state = transition.toState
//        return true
//    }
//
//    @resultBuilder
//    public struct AvailableTransitionBuilder {
//        public static func buildBlock(_ components: AvailableTransition<E, S>...) -> [AvailableTransition<E, S>] {
//            components
//        }
//    }
//}
//
//public struct AvailableTransition<E: Event, S: State> {
//    let to: S
//    let event: E
//    let condition: Condition?
//    let handler: Handler
//
//    public init(_ to: S, _ event: E, _ condition: Condition? = nil, _ handler: @escaping Handler) {
//        self.to = to
//        self.event = event
//        self.condition = condition
//        self.handler = handler
//    }
//
//    public init(availableTransition: AvailableTransition<E,S>, _ handler: @escaping Handler) {
//        self.to = availableTransition.to
//        self.event = availableTransition.event
//        self.condition = availableTransition.condition
//        self.handler = handler
//    }
//}
//
//public struct EventToTransition<E: Event, S: State>: Hashable {
//    public let event: E
//    public let transition: Transition<S>
//    init(event: E, transition: Transition<S>) {
//        self.event = event
//        self.transition = transition
//    }
//
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(event.hashValue)
//        hasher.combine(transition.hashValue)
//    }
//}
//
//public func ~> <S>(fromState: S, toState: S) -> Transition<S> {
//    return Transition(fromState: fromState, toState: toState)
//}
//
////infix operator ==> : MultiplicationPrecedence
//infix operator ==> : AdditionPrecedence
//
//public func ==> <S, E>(event: E, toState: S) -> AvailableTransition<E, S> {
//    AvailableTransition(toState, event, nil) { }
//}
//
//infix operator ?! : AdditionPrecedence
//
//public func ?! <S, E>(eventToState: AvailableTransition<E, S>, condition: @escaping Condition) -> AvailableTransition<E, S> {
//    AvailableTransition(eventToState.to, eventToState.event, condition) { }
//}
//
////infix operator | : AdditionPrecedence
//
//public func | <E, S>(availableTransition: AvailableTransition<E, S>, handler: @escaping Handler) -> AvailableTransition<E, S> {
//    AvailableTransition(availableTransition: availableTransition, handler)
//}
//
//public func ==> <E, S>(availableTransition: AvailableTransition<E, S>, handler: @escaping Handler) -> AvailableTransition<E, S> {
//    AvailableTransition(availableTransition: availableTransition, handler)
//}

