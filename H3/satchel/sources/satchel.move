/// Module: satchel
/// A module for managing a shared collection of magical scrolls.
/// This module provides functionality to create, add, remove, and borrow scrolls from a shared satchel.
module satchel::satchel;

use std::string::String;

/// Error code indicating that no scroll with the specified ID exists in the satchel.
const ENoScrollWithThisID: u64 = 0;
/// Error code indicating invalid authorization for satchel editing.
const ENotYourSatchel: u64 = 1;
/// Error code indicating an invalid return of a borrowed scroll.
const EInvalidReturn: u64 = 2;
/// Error code indicating that the test was expected to fail earlier.
const EExpectedFailure: u64 = 0xff;

/// A magical scroll that can be stored in the satchel.
/// Each scroll has a unique ID, a name, and a list of magical effects.
public struct Scroll has key, store {
    id: UID,
    name: String,
    effects: vector<String>,
}

/// A shared container that holds a collection of scrolls.
/// This is a shared object that can be accessed by multiple users.
public struct SharedSatchel has key {
    id: UID,
    scrolls: vector<Scroll>
}

/// A capability token that grants permission to modify the shared satchel.
/// Only holders of this capability can add or remove scrolls from the satchel.
public struct SatchelCap has key, store {
    id: UID,
}

/// A marker type used to track borrowed scrolls.
/// This ensures that borrowed scrolls are properly returned to the satchel.
public struct Borrow()

// Task 1: The `SatchelCap` should be linked with the `SharedSatchel` created.
// Else, anyone can edit any `SharedSatchel`.
/// Creates a new shared satchel and returns a capability token to manage it.
/// The satchel is initialized empty and is shared with all users.
public fun new(ctx: &mut TxContext): (SharedSatchel, SatchelCap) {
    (
        SharedSatchel { id: object::new(ctx), scrolls: vector[] },
        SatchelCap { id: object::new(ctx) }
    )
}

public fun share(self: SharedSatchel) {
    transfer::share_object(self)
}

// Task 2: Editing the `SharedSatchel` should be authorized for specific `SatchelCap`.
/// Adds a new scroll to the shared satchel.
/// Requires the satchel capability to ensure only authorized users can add scrolls.
public fun add_scroll(self: &mut SharedSatchel, cap: &SatchelCap, scroll: Scroll) {
    self.scrolls.push_back(scroll);
}

// Task 2: Editing the `SharedSatchel` should be authorized for specific `SatchelCap`.
/// Removes a scroll from the shared satchel by its ID.
/// Requires the satchel capability and returns the removed scroll.
/// Aborts if no scroll with the given ID exists.
public fun remove_scroll(self: &mut SharedSatchel, cap: &SatchelCap, scroll_id: ID): Scroll {
    let mut idx = self.scrolls.find_index!(|scroll| object::id(scroll) == scroll_id);
    assert!(idx.is_some(), ENoScrollWithThisID);
    let idx = idx.extract();
    self.scrolls.remove(idx)
}

// Task 3: `Borrow` hot-potato should only refer to the specific `SharedSatchel`.
// Else, anyone can take a scroll out of one satchel and put it into another.
/// Borrows a scroll from the shared satchel by its ID.
/// Returns both the scroll and a borrow token that must be used to return the scroll.
/// Aborts if no scroll with the given ID exists.
public fun borrow_scroll(self: &mut SharedSatchel, scroll_id: ID): (Scroll, Borrow) {
    let mut idx = self.scrolls.find_index!(|scroll| object::id(scroll) == scroll_id);
    assert!(idx.is_some(), ENoScrollWithThisID);
    let idx = idx.extract();
    (
        self.scrolls.remove(idx),
        Borrow()
    )
}

// Task 3: `Borrow` hot-potato should only refer to the specific `SharedSatchel`.
// Else, anyone can take a scroll out of one satchel and put it into another.
/// Returns a borrowed scroll to the shared satchel.
/// Requires both the scroll and its corresponding borrow token to ensure proper return.
public fun return_scroll(self: &mut SharedSatchel, scroll: Scroll, borrow: Borrow) {
    self.scrolls.push_back(scroll);
    let Borrow() = borrow;
}

#[test]
#[expected_failure(abort_code=ENotYourSatchel)]
fun test_satchel_editing() {
    let mut ctx = tx_context::dummy();

    let scroll = Scroll {
        id: object::new(&mut ctx),
        name: b"Scroll of Healing".to_string(),
        effects: vector[b"Heals 10 HP".to_string()],
    };

    let (_satchel1, cap1) = new(&mut ctx);
    let (mut satchel2, _cap2) = new(&mut ctx);

    satchel2.add_scroll(&cap1, scroll);

    abort(EExpectedFailure)
}

#[test]
#[expected_failure(abort_code=EInvalidReturn)]
fun test_satchel_return() {

    let mut ctx = tx_context::dummy();

    let scroll = Scroll {
        id: object::new(&mut ctx),
        name: b"Scroll of Healing".to_string(),
        effects: vector[b"Heals 10 HP".to_string()],
    };
    let scroll_id = object::id(&scroll);

    let (mut satchel1, cap1) = new(&mut ctx);
    satchel1.add_scroll(&cap1, scroll);

    let (scroll, borrow) = satchel1.borrow_scroll(scroll_id);

    let (mut satchel2, _cap2) = new(&mut ctx);

    satchel2.return_scroll(scroll, borrow);

    abort(EExpectedFailure)
}
