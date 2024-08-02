#[test_only]
module move_training::suispresso_tests;
use move_training::suispresso::{Self, CashRegistry, EmployeeCard};
use sui::test_scenario as ts;

// === Constants ===
const ADMIN: address = @0x123;
// const EMPLOYEE: address = @0x456;
// const CUSTOMER: address = @0x789;

#[test]
fun test_init() {
    let mut scenario = ts::begin(ADMIN);

    // Creates the cash registry
    suispresso::init_for_test(scenario.ctx());

    // Check if the cash registry was created
    ts::next_tx(&mut scenario, ADMIN);
    let registry = scenario.take_shared<CashRegistry>();

    ts::return_shared(registry);
    ts::end(scenario);
}

#[test]
#[expected_failure(abort_code = ts::ECantReturnObject)]
fun test_create_employee_card() {
    let mut scenario = ts::begin(ADMIN);

    // Create an employee card
    let (card, hot_potato) = suispresso::new_employee_card(scenario.ctx());

    // Transfer the employee card to the sender bypassing the hot potato
    ts::return_to_sender<EmployeeCard>(&scenario, card);
    hot_potato.burn_hot_potato_for_test();

    ts::end(scenario);
}
