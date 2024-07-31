/// We have a cofee shop to run.
/// 1. We want to sell coffee.
/// 2. We need a registry to keep track of payments.
/// 3. Create a coffee - worker needs a way to create a new coffee.
/// 4. Customer needs a way to buy a coffee (that was created)
/// 5. The only way for a customer to get a coffee is to buy it.
module move_training::coffee {
    // === Imports ===
    use std::string::{Self, String};
    use move_training::suispresso::{CashRegistry, deposit};
    use sui::coin::{Coin, Self};
    use sui::sui::{SUI};
    use sui::package;
    use sui::display;
    use move_training::membership::{MembershipCard};

    // === Structs ===

    public struct Coffee has key, store {
        id: UID,
        name: String,
        size: u8, // 8 or 16 oz
        price: u64,
        iced: bool, // iced or hot coffee
        creator: address,
        addons: Option<Straw>,
        image_url: String,
    }

    public struct Straw has store, drop {
        color: String,
    }

    public struct COFFEE has drop {}

    // === Error codes ===
    const ERROR_INSUFFICIENT_PAYMENT: u64 = 1;

    fun init(otw: COFFEE, ctx: &mut TxContext) {
        // Claim the Publisher object.
        let publisher = package::claim(otw, ctx);

        // Create the fields for the display.
        let fields = vector[
            string::utf8(b"name"),
            string::utf8(b"image_url"),
        ];

        let values = vector[
            string::utf8(b"{name}"),
            string::utf8(b"{image_url}"),
        ];

        // Create a new display for the Coffee.
        let mut display = display::new_with_fields<Coffee>(&publisher, fields, values, ctx);

        // Update the display with the new fields.
        display.update_version();

        // Transfer the publisher to the sender.
        transfer::public_transfer(publisher, ctx.sender());

        // Transfer the display to the sender.
        transfer::public_transfer(display, ctx.sender());
    }

    // === Public functions ===

    /// Create a hot coffee (without a straw).
    public(package) fun create_hot_coffee(
        name: String,
        size: u8,
        price: u64,
        image_url: String,
        ctx: &mut TxContext,
    ): Coffee {
        create_coffee(name, size, price, false, option::none(), image_url, ctx)
    }

    /// Create a cold coffee (and adds a straw).
    public(package) fun create_cold_coffee(
        name: String,
        size: u8,
        price: u64,
        image_url: String,
        ctx: &mut TxContext,
    ): Coffee {
        create_coffee(name, size, price, true, option::some(create_straw()), image_url, ctx)
    }

    /// Give a customer the ability to buy a coffee.
    public fun buy_coffee(
        card: &mut MembershipCard,
        name: String,
        size: u8,
        price: u64,
        iced: bool,
        payment: Coin<SUI>,
        registry: &mut CashRegistry,
        image_url: String,
        ctx: &mut TxContext,
    ): Coffee {
        // Verify the payment amount matches the price
        assert!(coin::value(&payment) == price, ERROR_INSUFFICIENT_PAYMENT);

        // Create the coffee
        let coffee = if (iced) {
            create_cold_coffee(name, size, price, image_url, ctx)
        } else {
            create_hot_coffee(name, size, price, image_url, ctx)
        };

        // Classic syntax
        // membership::add_points( card, 1);

        // Move 2024 syntax
        card.add_points(1);

        // Deposit the payment into the cash registry
        deposit(payment, registry);

        coffee
    }

    // === Private functions ===

    /// Create cofee.
    fun create_coffee(
        name: String,
        size: u8,
        price: u64,
        iced: bool,
        straw: Option<Straw>,
        image_url: String,
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
            image_url,
        }
    }

    // Create a default straw object with Red generic type.
    public(package) fun create_straw(): Straw {
        Straw {
            color: string::utf8(b"red"),
        }
    }

    /// Destroy a coffee.
    public(package) fun destroy(coffee: Coffee) {
        let Coffee {
            id,
            name: _,
            size: _, // 8 or 16 oz
            price: _,
            iced: _, // iced or hot coffee
            creator: _,
            addons: _,
            image_url: _,
        } = coffee;

        id.delete();
    }
}

// === Accessors/Getters ===
