/// We have a cofee shop to run.
/// 1. We want to sell coffee.
/// 2. We need a registry to keep track of payments.
/// 3. Create a coffee - worker needs a way to create a new coffee.
/// 4. Customer needs a way to buy a coffee (that was created)
/// 5. The only way for a customer to get a coffee is to buy it.
module move_training::coffee {
    // === Imports ===
    use std::string::{Self, String};

    // === Structs ===

    public struct Coffee has key, store {
        id: UID,
        name: String,
        size: u8, // 8 or 16 oz
        price: u64,
        iced: bool, // iced or hot coffee
        creator: address,
        addons: Option<Straw>,
    }

    public struct Straw has store, drop {
        color: String,
    }

    // === Public functions ===

    /// Create a hot coffee (without a straw).
    public(package) fun create_hot_coffee(
        name: String,
        size: u8,
        price: u64,
        ctx: &mut TxContext,
    ): Coffee {
        create_coffee(name, size, price, false, option::none(), ctx)
    }

    /// Create a cold coffee (and adds a straw).
    public(package) fun create_cold_coffee(
        name: String,
        size: u8,
        price: u64,
        ctx: &mut TxContext,
    ): Coffee {
        create_coffee(name, size, price, true, option::some(create_straw()), ctx)
    }

    // === Private functions ===

    /// Create cofee.
    fun create_coffee(
        name: String,
        size: u8,
        price: u64,
        iced: bool,
        straw: Option<Straw>,
        ctx: &mut TxContext,
    ): Coffee {
        Coffee {
            id: object::new(ctx),
            name,
            size,
            price,
            iced,
            creator: ctx.sender(),
            addons: straw,
        }
    }

    // Create a default straw object with Red generic type.
    public(package) fun create_straw(): Straw {
        Straw {
            color: string::utf8(b"red"),
        }
    }
}

// === Private functions ===

// === Accessors/Getters ===
