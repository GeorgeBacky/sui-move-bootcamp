# Sui & Move Bootcamp - H2: Advanced Move Patterns

This section demonstrates three fundamental Move patterns that are essential for building secure and flexible smart contracts on Sui.

## 1. Capability Pattern with Properties

The capability pattern is implemented through two modules:
- `hero`: Contains the main game logic
- `store`: A generic store management module

Key features:
- Uses `AdminCap` objects for access control
- Demonstrates how store managers must hold the correct `AdminCap` object
- Implements property-based access control

This pattern builds on top of the simple Capability Pattern that solely relies on Sui object ownership model and builds a more fine grained authorization mechanism using arbitrary proeprties declaerd on the Cap oject.

## 2. Witness Pattern

The witness pattern demonstrates how to implement module-level or smart contract-level access control:
- Utilizes Move's type system to ensure a struct can only be initialized in its declaring module
- Implements a whitelisting mechanism for contract calls
- Shows how to verify the origin of calls between modules within the same or different smart contracts
- Demonstrates secure cross-module communication

This pattern is particularly useful for implementing secure module interactions and ensuring that only authorized modules can perform specific actions.

## 3. Hot Potato Pattern

The hot potato pattern showcases dynamic flow control:
- Implements ability-less objects that must be consumed
- Demonstrates how to chain multiple calls in a single transaction
- Shows how to create dynamic flows with different potential combinations
- Illustrates the importance of proper object destruction in Programmable Transaction Blocks (PTB)

This pattern is essential for implementing complex transaction flows where objects must be passed through multiple functions and eventually consumed.

