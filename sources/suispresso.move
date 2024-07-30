/// We have a cofee shop to run.
/// 1. We want to sell coffee.
/// 2. We need a registry to keep track of payments.
/// 3. Create a coffee - worker needs a way to create a new coffee.
/// 4. Customer needs a way to buy a coffee (that was created)
///
module move_training::suispresso {
    // === Imports ===
    use std::string::{String};

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

    public struct Straw has store {
        color: String,
    }

    public struct Registry has key {
        id: UID,
        balance: u64,
    }

    // === Error codes ===

    // === Public functions ===
    public fun create_hot_coffee(name: String, size: u8, price: u64, ctx: &mut TxContext): Coffee {
        let coffee = Coffee {
            id: object::new(ctx),
            name,
            size,
            price,
            iced: false,
            creator: ctx.sender(),
            addons: option::none(),
        };

        coffee
    }

    public fun create_cold_coffee_with_straw(name: String, size: u8, price: u64, straw_color: String, ctx: &mut TxContext): Coffee {
        let straw = Straw {
            color: straw_color,
        };
        let coffee = Coffee {
            id: object::new(ctx),
            name,
            size,
            price,
            iced: true,
            creator: ctx.sender(),
            addons: option::some(straw),
        };

        coffee
    }


}

// === Private functions ===

// === Accessors/Getters ===
