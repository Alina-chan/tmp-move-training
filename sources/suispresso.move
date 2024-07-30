module move_training::suispresso {
    use sui::coin::{Self, Coin};
    use sui::sui::{SUI};
    use sui::balance::{Self, Balance};

    /// Cash registry that holds the balance of the coffee shop.
    public struct CashRegistry has key {
        id: UID,
        balance: Balance<SUI>,
    }

    /// Coin<SUI> <--> Balance<SUI> --> u64
    /// This function is ran once upon publishing the smart contract.
    /// Create and share the cash registry.
    fun init(ctx: &mut TxContext) {
        let registry = CashRegistry {
            id: object::new(ctx),
            balance: balance::zero(),
        };

        transfer::share_object(registry);
    }

    /// Increase the balance of the cash registry.
    public fun deposit(payment: Coin<SUI>, registry: &mut CashRegistry) {
        coin::put(&mut registry.balance, payment);
    }
}
