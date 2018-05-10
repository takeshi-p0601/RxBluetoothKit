import Foundation
import RxSwift
import CoreBluetooth

/// Closure that receives restored state dict as a parameter
public typealias OnWillRestorePeripheralManagerState = ([String: Any]) -> Void

extension PeripheralManager {

    // MARK: State restoration

    /// Creates new `PeripheralManager` instance, which supports bluetooth state restoration.
    /// - warning: If you pass background queue to the method make sure to observe results on main thread
    /// for UI related code.
    /// - parameter queue: Queue on which bluetooth callbacks are received. By default main thread is used
    /// and all operations and events are executed and received on main thread.
    /// - parameter options: An optional dictionary containing initialization options for a peripheral manager.
    /// For more info about it please refer to [Peripheral Manager initialization options](https://developer.apple.com/documentation/corebluetooth/cbperipheralmanager/peripheral_manager_initialization_options)
    /// - parameter onWillRestoreState: Closure called when state has been restored.
    ///
    /// - seealso: `RestoredState`
    public convenience init(queue: DispatchQueue = .main,
                            options: [String: AnyObject]? = nil,
                            onWillRestoreState: OnWillRestorePeripheralManagerState? = nil) {
        self.init(queue: queue, options: options)
        if let onWillRestoreState = onWillRestoreState {
            listenOnWillRestoreState(onWillRestoreState)
        }
    }

    /// Creates new `PeripheralManager`
    /// - parameter peripheralManager: Peripheral instance which is used to perform all of the necessary operations
    /// - parameter delegateWrapper: Wrapper on CoreBluetooth's peripheral manager callbacks.
    /// - parameter onWillRestoreState: Closure called when state has been restored.
    convenience init(
        peripheralManager: CBPeripheralManager,
        delegateWrapper: CBPeripheralManagerDelegateWrapper,
        onWillRestoreState: @escaping OnWillRestorePeripheralManagerState
        ) {
        self.init(
            peripheralManager: peripheralManager,
            delegateWrapper: delegateWrapper
        )
        listenOnWillRestoreState(onWillRestoreState)
    }

    /// Emits restored state dict instance, when state of `PeripheralManager` has been restored,
    /// Should only be called once in the lifetime of the app
    /// - returns: Observable which emits next events state has been restored
    func listenOnWillRestoreState(_ handler: @escaping OnWillRestorePeripheralManagerState) {
        _ = delegateWrapper
            .willRestoreState
            .take(1)
            .subscribe(onNext: { [weak self] restoredState in
                guard let strongSelf = self else { return }
                // swiftlint:disable line_length
                strongSelf.restoredAdvertisementData = restoredState[CBPeripheralManagerRestoredStateAdvertisementDataKey] as? RestoredAdvertisementData
                // swiftlint:enable line_length
                handler(restoredState)
            })
    }
}
