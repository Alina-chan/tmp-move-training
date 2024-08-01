# Move Training Sessions Summary

## Session #1

📅 Monday 29th, July, 2024

### Summary

#### Sui CLI

How to set up Sui environments, how to check the current active env

```bash
// list all Sui environments
$ sui client envs

// default/active Sui environment
$ sui client active-env
```

Differences between Sui envs:

- `devnet` hosts features that are not production ready - and may take a long time until the feature is available on mainnet.
- `testnet` hosts features right before they are published on mainnet. Preffered environment for development, especially when working towards releasing your package on mainnet.
- `mainnet` is the ultimate boss (uhm, goal).

Your Sui binaries must be updated by the branch that corresponds to the Sui environment you will publish your contract to.

#### Sui Move CLI

How to start a new move project through the command line

```bash
$ sui move new <your_project_name>
```

How to build your move project

```bash
$ sui move build
```

This will automatically create:

- a `sources` folder that will host your smart contract modules and code
- a `tests` folder that will host all the tests in move for your contract
- a `Move.toml` file that keeps the default configuration for developing a smart contract

Tips:

- Filenames under your `sources` and `tests` folders should be in `snake_case`, not `CamelCase` or `camelCase` or any other.
- Each filename represents one module, and it's best to use the same name for both the module and the filaneme.

#### Sui Objects

- Everything on Sui is an object.
- A Sui object is created through a `struct` in move and has a unique identifier `UID`.
- There are three object types on Sui:
  - Owned object - is transferred to an address and address is the owner.
  - Shared object - is shared in the network, has no owner.
  - Immutabled objects - such as packages, exist in the network, has no owner, cannot be mutated.

### Move Notes

- Had an introduction of the basic syntax in Move.
- How to write typedoc and inline comments.
- How to approach the initial contract design, what components of our use case will be represented on-chain: Think of the smart contract as an API that provides the interface for a backend or a person to interact with. Your contract will represent the important components of the use case as objects on-chain (like an NFT) and will also provide the guidelines on how to retrieve, manipulate and what to do with those objects through the appropriate functions.
- Module code structure (imports first, structs, public functions etc).
- Move primitives (u8, u16, u64, address, bool etc).
- Type abilities for structs:
  - `key` - object has a unique identifier UID and can exist in global storage
  - `store` - object can be transferred outside of the module
  - `copy` - object can be copied
  - `drop` - can automatically be discarded by storage
- Object reference types:
  - By value: `fun example_fun(obj: Object)` - function has complete ownership of `Object`.
  - Immutable reference `fun example_fun(obj: &Object)` - function can only read the object.
  - Mutable reference `fun example_fun(obj: &mut Object)` - function can mutate the object.
- Object ownership in-module: An object can only be manipulated as per the module's supported functions. Object cannot be mutated outside of its module unless there is a function to allow so.
- Function visibility:
  - `public fun example_fun()` - anyone can call this function, such as the CLI, other modules and packages.
  - `fun example_fun()` - functions without a specific visibility identifier are private to their modules. Cannot be accessed by other modules and by no means other packages.
  - `public(package) fun example_fun()` - function can be accessed by other modules under the same package only. Cannot be accessed by other packages and anywhere else.
- Function signatures and function returns.
- Module imports: How to import typenames and how to use public functions from other modules.
- How to navigate the Sui and STD library: Always think what you want to achieve and then research the Sui library by keywords to see how you could achieve what you need. Pay attention to function signatures (what parameters they expect) and their return types.

### TODOs

- [x] Implement a function that creates a cold coffee and adds a Straw. Function should return the coffee.
- [x] Declare a struct for our coffeeshop registry where we will keep a balance of SUI.

## Session #2

📅 Tuesday 30th, July, 2024

### Summary

- Revised struct generic types and their use in function calls.
- Revised struct abilities and their combinations (for example, an object that has `key` cannot have `drop`).
- Explained the purpose of omitting the `store` ability from structs if we don't want to allow transfers outside of the module from other parties.
- Talked about the difference of owned vs shared objects:
  - Owned objects always have an owner of type `address`, because as the name states, they are owned by someone. Only the owner of the object can use it in a transaction. Owned objects can be passed by value, by reference `&` and mutable reference `&mut`.
  - Shared objects are not owned by anyone and can be accessed and used by anyone in a transaction. A shared object can be passed by reference `&` or mutable `&mut`, but not by value.
- Worked on creating helper functions to avoid repetitive/duplicate code.
- Discussed the approach of designing a contract and how we abstract the logic of our use cases into separate modules that handle specific parts of the logic. We don't want to have a do-it-all module that is too complicated to manage, read and maintain.
- How to pass option arguments in a function call and how to check for empty options with `is_none` and `is_some`.
- Worked with `coin` and `balance` modules, and how we convert a Coin into a Balance and vice versa.
- Purpose of `init` functions - they only run once upon publishing our smart contract. Existing `init` functions (or even newly added in new modules) don't run when we upgrade an already published package. It's not possible to return anything through the `init` function because they only execute actions.

### TODOs

- [x] Implement a function in the `coffee` module that the customer can use to buy a coffee. The function must accept a payment of type `Coin<SUI>` and all the data it needs so that the worker can create the coffee. The function should return the coffee and deposit his payment to the cash registry.
- [x] Food for thought: How could we restrict access to buying a coffee only to customers that would carry one of our membership cards?

## Session #3

📅 Wednesday 31th, July, 2024

### Summary

- Witness pattern and one-time-witness
- What is a `Publisher`, how and when to claim and how to use to create a `Display` for multiple objects.
- How to restrict function access by requiring a capability to be passed as a witness with `&` reference.
- How to burn objects. Objects should always be destroyed in the module that defines them. In order to destroy an object, first we need to destructure it and manually delete any fields that don't have `drop`.
- How to import module functions in other modules from your own package.
- What is a dependency cycle and how to avoid.
- Move 2024 method syntax and creating aliases for functions.
- Typescript SDK and how to create a Transaction Block.
- How to set up a .env and config file in TS in order to feed your contract related data to your app.
- Execute a moveCall via the SDK.

#### Notes

In order to interact with the smart contract through the TS code, you will need to `sui client publish` the package and populate your `.env` accordingly (include your private key so you can sign transactions).

### TODOs

- [ ] Update the `history` vector in `membership` module, to add an entry of the current timestamp every time someone buys a coffee. You will need to add appropriate functions for accessing and updating the vector.
- [x] Create a new `EmployeeCard` through the SDK.
- [x] Create an `MembershipCard` through the SDK.

## Session #4

📅 Thursday 1st, August, 2024

### Summary

- Set up a local account with Sui CLI. Also did a walkthrough on Sui wallet (switching networks, requesting test tokens, how to import an existing account).
- Sui CLI overview: Make sure to frequently use `sui client --help` whenever you need to check what your available options are.
- Configured prettier Move VS Code extension.
- Extensively reviewed what happens when you publish a smart contract and how to navigate the transaction response & digest.
- We saw how to input all necessarry addresses, keys, IDs in our project, with a `.env` private file under our project.
- Reviewed last session's TS code and worked on new approaches and use cases, such as:
  - Attempted to return the `EmployeeCard` instead of transferring it in-contract. `EmployeeCard` doesn't have `store`, so we needed to create a custom transfer function that would handle the transfer of objects that don't have `store`.
  - Also worked on the hop-potato pattern. Discussed what are the benefits of serving hot-potatoes, and how to resolve them in our contract.
- Also touched more on destructuring objects, even temporary objects that don't have `key`.
- Explored the nature of PTBs, how to make multiple moveCalls in a PTB and how to get the returned objects from moveCalls and use them in our next moveCalls.
- How we can satisfy the hot-potato pattern when building transactions with the SDK.
- Limitations of PTBs, such as, we cannot use as input returns from functions that return references, we need to have the object by value in our PTB.
- Talked about private keys, how to get the signer/keypair and how to also derive the public key and Sui address from a keypair.
- Reviewed how the signer can utilise any objects being created in a PTB and pass them as arguments to other moveCalls, even if the transaction has not been executed yet (signer-scoped ownership). Also saw how we can re-order moveCalls to accommodate our purpose.
- Conversed on the importance of designing a smart contract and how the TS SDK integration would happen - also how sometimes we may need to trace back and apply changes to our contract in order to make it more modular or even apply restrictions in order to enhance or protect the execution of PTBs.

### TODOs

- [ ] Update the `history` vector in `membership` module, to add an entry of the current timestamp every time someone buys a coffee. You will need to add appropriate functions for accessing and updating the vector.
- [ ] Write the TS integration code with the SDK, for a customer to buy a coffee. There are a few things you will need to do as subtasks for this task:
  1. You need two entities in your app; one admin that will act as the employee and a customer with their own address and private key.
  2. Make sure the admin entity has an `EmployeeCard` so that they can issue a `MembershipCard` to the customer.
  3. The creation of `EmployeeCard` and `MembershipCard` are signed by the employee/admin.
  4. The transaction of buying a coffee will be signed by the customer.
  5. In order for the customer to buy a coffee, they need to supply their `MembershipCard`. Use existing methods from the client and RPC, to retrieve the customer's `MembershipCard` (you will need to query for the customer's address owned objects and find an object with type that corresponds to the `MembershipCard` type that we need).
  6. Use existing methods and RPC calls to retrieve the user's SUI balance, and create a coin (hint: split his coin) that will correspond to the price we need in order to call `buy_coffee`.
  7. Examine the transaction response and make sure that the payment is indeed stored under the `CashRegistry` and that the customer's `MembershipCard` points are incremented.
