module package_upgrade::blacksmith;

use package_upgrade::admin::AdminCap;

// DEMO: Change constant name, add constant.
const ENotEnoughExpertise: u64 = 0;

/// Blacksmith; can create items.
public struct Blacksmith has key, store {
    id: UID,
    expertise: u64
}

public struct Sword has key, store {
    id: UID,
    attack: u64,
}

public struct Shield has key, store {
    id: UID,
    defence: u64,
}

/// Admin can create new Blacksmiths.
public fun new_blacksmith(_: &AdminCap, expertise: u64, ctx: &mut TxContext): Blacksmith {
    Blacksmith { id: object::new(ctx), expertise } 
}

/// Blacksmith can create swords with attack no more than their expertise.
public fun new_sword(self: &Blacksmith, attack: u64, ctx: &mut TxContext): Sword {
    assert!(self.expertise >= attack, ENotEnoughExpertise) ;
    Sword {
        id: object::new(ctx),
        attack
    }
}

public fun attack(self: &Sword): u64 {
    self.attack
}

/// Blacksmith can create shields with defence no more than their expertise.
public fun new_shield(self: &Blacksmith, defence: u64, ctx: &mut TxContext): Shield {
    assert!(self.expertise >= defence, ENotEnoughExpertise);
    Shield {
        id: object::new(ctx),
        defence
    }
}

public fun defence(self: &Shield): u64 {
    self.defence
}

