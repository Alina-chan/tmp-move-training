/// We have a cofee shop to run.
/// 1. We want to sell coffee.
/// 2. We need a registry to keep track of payments.
/// 3. Create a coffee - worker needs a way to create a new coffee.
/// 4. Customer needs a way to buy a coffee (that was created)
/// 5. The only way for a customer to get a coffee is to buy it.
module move_training::coffee;
use move_training::membership::MembershipCard;
use move_training::suispresso::{CashRegistry, deposit};
use std::string::{Self, String};
use sui::coin::{Self, Coin};
use sui::display;
use sui::dynamic_field as df;
use sui::dynamic_object_field as dof;
use sui::package;
use sui::sui::SUI;

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

public struct Cup has key, store {
    id: UID,
    material: String,
}

public struct COFFEE has drop {}

// Constants are always uppercase, such as MAX_COFFEE_SIZE
// Error codes should always be prefix with E and be in camelcase.

// === Error codes ===
const EInsufficientPayment: u64 = 1;

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
    let mut display = display::new_with_fields<Coffee>(
        &publisher,
        fields,
        values,
        ctx,
    );

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
    create_coffee(
        name,
        size,
        price,
        true,
        option::some(create_straw()),
        image_url,
        ctx,
    )
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
    assert!(coin::value(&payment) == price, EInsufficientPayment);

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

/// Update the coffee name.
public fun update_name(coffee: &mut Coffee, new_name: String) {
    coffee.name = new_name
}

/// I want a way to update my coffee and add milk.
public fun add_milk(coffee: &mut Coffee) {
    df::add<String, bool>(&mut coffee.id, string::utf8(b"milk"), true);
}

/// A dynamic field with key `Name` can exist once. If you try to add a DF with the
/// same key, a ``EFieldAlreadyExists`` error will be thrown.
public fun add_sugar(coffee: &mut Coffee) {
    // Check if the field already exists
    // assert!(
    //     df::exists_(&coffee.id, string::utf8(b"sugar")) == false,
    //     ESugarAlreadyExists,
    // );

    // Check if sugar has already been added, and if not, add it.
    if (df::exists_(&coffee.id, string::utf8(b"sugar"))) {
        // If yes, increase it.
        let sugar = df::borrow_mut<String, u64>(
            &mut coffee.id,
            string::utf8(b"sugar"),
        );
        *sugar = *sugar + 1;
    } else {
        df::add<String, u64>(&mut coffee.id, string::utf8(b"sugar"), 1);
    };
}

/// Add cup for the cofee.
/// This will create a Cup object and add it to the coffee, and the Cup will persist as
/// an object on Sui.
public fun add_cup(coffee: &mut Coffee, material: String, ctx: &mut TxContext) {
    let cup = Cup {
        id: object::new(ctx),
        material,
    };

    dof::add(&mut coffee.id, string::utf8(b"cup"), cup);
}

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

// === Accessors/Getters ===
