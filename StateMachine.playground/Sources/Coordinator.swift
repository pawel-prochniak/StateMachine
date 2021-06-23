import Foundation

public protocol TransferStateModel { }
public class Empty: TransferStateModel { public init() {} }

public struct SelectAmountModel: TransferStateModel {
    let from: String
    let to: String

    public init(from: String, to: String) {
        self.from = from
        self.to = to
    }
}

public struct ConfirmModel: TransferStateModel {
    let from: String
    let to: String
    let amount: Double

    public init(from: String, to: String, amount: Double) {
        self.from = from
        self.to = to
        self.amount = amount
    }
}

public protocol CoordinatorDelegate { 
    func onFromSelected(_ from: String)
    func onToSelected(_ to: String)
    func onAmountSelected(_ amount: Double)
    func onConfirmTransfer()
}

public class Coordinator {
    private let delegate: CoordinatorDelegate

    public init(delegate: CoordinatorDelegate) {
        self.delegate = delegate
    }

    public func showFromSelection() {
        delegate.onFromSelected("From")
    }

    public func showToSelection() {
        delegate.onToSelected("To")
    }

    public func showAmountSelection(_ model: SelectAmountModel) {
        delegate.onAmountSelected(10.0)
    }

    public func showConfirm(_ model: ConfirmModel) {
        delegate.onConfirmTransfer()
    }

    public func showSuccess() {
        print("Success")
    }
}
