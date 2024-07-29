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
  - `public fun example_fun()` - anyone can call this function, such as the CLI, other modules and  packages.
  - `fun example_fun()` - functions without a specific visibility identifier are private to their modules. Cannot be accessed by other modules and by no means other packages.
  - `public(package) fun example_fun()` - function can be accessed by other modules under the same package only. Cannot be accessed by other packages and anywhere else.
- Function signatures and function returns.
- Module imports: How to import typenames and how to use public functions from other modules.
- How to navigate the Sui and STD library: Always think what you want to achieve and then research the Sui library by keywords to see how you could achieve what you need. Pay attention to function signatures (what parameters they expect) and their return types.

### TODOs
- [] Implement a function that creates a cold coffee and adds a Straw. Function should return the coffee.
- [] Declare a struct for our coffeeshop registry where we will keep a balance of SUI.