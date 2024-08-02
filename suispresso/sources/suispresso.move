module move_training::suispresso;
use std::string;
use sui::balance::{Self, Balance};
use sui::coin::{Self, Coin};
use sui::display;
use sui::package;
use sui::sui::SUI;

/// Cash registry that holds the balance of the coffee shop.
public struct CashRegistry has key {
    id: UID,
    balance: Balance<SUI>,
}

/// One-time-witness for claiming the Publisher object.
public struct SUISPRESSO has drop {}

/// Declare a coffee shop employee.
public struct EmployeeCard has key {
    id: UID,
}

/// Object that will be used at temp struct inside the contract
public struct HotPotato {}

/// Coin<SUI> <--> Balance<SUI> --> u64
/// This function is ran once upon publishing the smart contract.
/// Create and share the cash registry.
fun init(otw: SUISPRESSO, ctx: &mut TxContext) {
    // Create a new cash registry with a balance of zero.
    let registry = CashRegistry {
        id: object::new(ctx),
        balance: balance::zero(),
    };

    transfer::share_object(registry);

    // Claim the Publisher object.
    let publisher = package::claim(otw, ctx);

    // Create the fields for the display.
    let fields = vector[
        string::utf8(b"name"),
        string::utf8(b"image_url"),
    ];

    let values = vector[
        string::utf8(b"Suispresso Cash Registry"),
        string::utf8(
            b"ipfs://bafkreibngqhl3gaa7daob4i2vccziay2jjlp435cf66vhono7nrvww53ty/",
        ),
    ];

    // Create a new display for the cash registry.
    let mut display = display::new_with_fields<CashRegistry>(
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

/// Increase the balance of the cash registry.
public fun deposit(payment: Coin<SUI>, registry: &mut CashRegistry) {
    coin::put(&mut registry.balance, payment);
}

/// Mint a new employee card and transfer it to the sender.
public fun new_employee_card(ctx: &mut TxContext): (EmployeeCard, HotPotato) {
    let hot_potato = HotPotato {};
    let card = EmployeeCard {
        id: object::new(ctx),
    };

    (card, hot_potato)
}

public fun transfer_employee_card(
    hot_potato: HotPotato,
    card: EmployeeCard,
    ctx: &mut TxContext,
) {
    let HotPotato {} = hot_potato;
    transfer::transfer(card, ctx.sender());
}

/// Destroy an employee card.
public fun burn_employee_card(card: EmployeeCard) {
    let EmployeeCard {
        id,
    } = card;

    id.delete();
}

// === Test functions ===

#[test_only]
/// Test init by creating a proper OTW.
public fun init_for_test(ctx: &mut TxContext) {
    init(SUISPRESSO {}, ctx);
}

#[test_only]
/// Destroy the hot potato for testing purposes.
public fun burn_hot_potato_for_test(hot_potato: HotPotato) {
    let HotPotato {} = hot_potato;
}
