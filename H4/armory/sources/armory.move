/// Module: armory
module armory::armory;

public struct Sword has key, store {
    id: UID,
    attack: u64
}

// Task 2: Resolve max object size limit
public struct Armory has key {
    id: UID,
    swords: vector<Sword>,
}

public fun new_armory(ctx: &mut TxContext): Armory {
    Armory {
        id: object::new(ctx),
        swords: vector[],
    }
}

public fun share(self: Armory) {
    transfer::share_object(self)
}

public fun mint_swords(self: &mut Armory, n_swords: u64, attack: u64, ctx: &mut TxContext) {
    n_swords.do!(|_i| {
        let sword = Sword {
            id: object::new(ctx),
            attack
        };
        self.swords.push_back(sword);
    });
}
