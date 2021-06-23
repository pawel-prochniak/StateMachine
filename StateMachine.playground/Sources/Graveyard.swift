import Foundation

//@StateMachine<TransferState, TransferEvent>.AvailableTransitionBuilder var transitions: [AvailableTransition<TransferEvent, TransferState>] {
//    AvailableTransition<TransferEvent, TransferState>(.toSelection, .onFromAccountChosen, nil, {
//        fromChosen = true
//        print("start->to")
//    })
//    AvailableTransition<TransferEvent, TransferState>(.toSelection, .onFromAccountChosen, nil, {
//        fromChosen = true
//        print("start->to")
//    })
//}
//
////// resultBuilder
//machine.addTransitions(start: .start) {
//    .onFromAccountChosen ==> .toSelection
////    {
////        fromChosen = true
////        print("start->to")
////    }
//    .init(.fromSelection, .onToAccountChosen, nil, {
//        toChosen = true
//        print("start->to")
//    })
//}

//// AvailableTransition<E, S>...
//machine.addTransitions(from: .start,
//                       .init(.toSelection,
//                             .onFromAccountChosen) {
//                        fromChosen = true
//                        print("start->to")
//                       },
//                       .init(.fromSelection,
//                             .onToAccountChosen) {
//                        toChosen = true
//                        print("start->from")
//                       }
//)


//machine.addTransition(from: .start,
//                      .onToAccountChosen ==> .fromSelection ~! { true }
////                        {
//    toChosen = true
//    print("start->from")
//}
//)
//
//
//var fromChosen = false
//var toChosen = false
//let machine = StateMachine<TransferState, TransferEvent>(initialState: .start)
//machine.addTransition(.start ~> .toSelection, onEvent: .onFromAccountChosen) {
//    fromChosen = true
//    print("start->to")
//}
//
//machine.addTransition(from: .start,
//                      to: .fromSelection,
//                      onEvent: .onToAccountChosen) {
//    toChosen = true
//    print("start->from")
//}
//
//machine.addTransition(from: .start,
//                      to: .toSelection,
//                      onEvent: .onFromAccountChosen) {
//    toChosen = true
//    print("start->from")
//}
//
//machine.addTransition(from: .toSelection,
//                      to: .setAmount,
//                      onEvent: .onToAccountChosen,
//                      condition: { fromChosen }) {
//    toChosen = true
//    print("to->amount")
//}
//
//machine.addTransition(from: .toSelection, to: .fromSelection, onEvent: .onToAccountChosen, condition: { !fromChosen }) {
//    toChosen = true
//    print("to->from")
//}
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
//// to -> from -> amount -> confirm
//machine.event(.onToAccountChosen)
//machine.event(.onFromAccountChosen)
//machine.event(.onAmountSet)
//machine.event(.onConfirm)
//machine.state

//// from -> to -> amount -> confirm
//machine.event(.onFromAccountChosen)
//machine.event(.onToAccountChosen)
//machine.event(.onAmountSet)
//machine.event(.onConfirm)
//machine.state
//
//// to -> from -> amount -> from -> amount -> confirm
//machine.event(.onToAccountChosen)
//machine.event(.onFromAccountChosen)
//machine.event(.onChangeFromAccount)
//machine.event(.onFromAccountChosen)
//machine.event(.onAmountSet)
//machine.event(.onConfirm)
//machine.state

//// to -> from -> amount -> from -> amount -> confirm
//machine.event(.onFromAccountChosen)
//machine.event(.onToAccountChosen)
//machine.event(.onChangeToAccount)
//machine.event(.onToAccountChosen)
//machine.event(.onAmountSet)
//machine.event(.onConfirm)
//machine.state
