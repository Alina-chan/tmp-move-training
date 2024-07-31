module move_training::membership {
    // === Imports ===
    use std::string::{String};
    use move_training::suispresso::{EmployeeCard};

    // === Structs ===
    public struct MembershipCard has key {
        id: UID,
        name: String,
        points: u64,
        // TODO: we can store transaction history for coffee in timestamp (ms)
        history: vector<TmpExampleWithtoutDrop>,
    }

    public struct TmpExampleWithtoutDrop has store {}

    /// Mint a new membership card.
    public fun new_card(
        _issuer: &EmployeeCard,
        name: String,
        customer_address: address,
        ctx: &mut TxContext,
    ) {
        let card = MembershipCard {
            id: object::new(ctx),
            name,
            points: 0,
            history: vector::empty(),
        };

        transfer::transfer(card, customer_address);
    }

    /// Add points to a membership card.
    /// This function is only callable by this package's modules.
    public(package) fun add_points(card: &mut MembershipCard, amount: u64) {
        card.points = card.points + amount;
    }

    /// Destroy a membership card.
    public fun burn_card(card: MembershipCard) {
        let MembershipCard {
            id,
            // We don't need the name or points.
            name: _name,
            points: _,
            mut history,
        } = card;

        // In order to delete a vector, we need to loop over all the vector elements
        // and delete them one by one after popping them off the vector.
        let i = history.length();
        while (i > 0) {
            let x = history.pop_back();
            let TmpExampleWithtoutDrop {} = x;
        };

        // then destroy the empty vector
        history.destroy_empty();

        id.delete();
    }
}
