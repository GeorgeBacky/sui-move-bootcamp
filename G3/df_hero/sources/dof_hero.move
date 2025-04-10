module hero::dof_hero;

use std::string::String;
use sui::dynamic_object_field as dof;

const ENotEmptyArena: u64 = 0;
const ENotReadyArena: u64 = 1;

public struct Hero has key, store {
    id: UID,
    name: String,
    power: u64,
}

public struct FightArena has key {
    id: UID,
    hero1: Option<address>,
    hero2: Option<address>,
}

public struct AdminCap has key {
    id: UID,
}

fun init(ctx: &mut TxContext) {
    transfer::transfer(AdminCap { id: object::new(ctx) }, ctx.sender());
}

public fun create_hero(_admin_cap: &AdminCap, name: String, power: u64, ctx: &mut TxContext): Hero {
    let hero = Hero {
        id: object::new(ctx),
        name,
        power,
    };
    hero
}

public fun create_arena(_admin_cap: &AdminCap, ctx: &mut TxContext) {
    let arena = FightArena {
        id: object::new(ctx),
        hero1: option::none(),
        hero2: option::none(),
    };
    transfer::share_object(arena);
}

public fun add_hero_to_arena(arena: &mut FightArena, owner: address, hero: Hero) {
    // Detach the heroes from the arena and determine the winner 
    // and transfer the winner to the winner address
    // delete the loser hero and the arena
}

public fun fight(_admin_cap: &AdminCap, arena: FightArena) {
    // Detach the heroes from the arena and determine the winner 
    // and transfer the winner to the winner address
    // delete the loser hero and the arena
}

/// This introduces the risk of leaving orphaned heroes in the system.
public fun delete_arena(_admin_cap: &AdminCap, arena: FightArena) {
    let FightArena { id, hero1: _, hero2: _ } = arena;
    id.delete()
}

// Test Only

#[test_only]
use sui::{test_scenario as ts, test_utils::assert_eq};

#[test_only]
const ADMIN: address = @0xAA;
const USER1: address = @0xBB;
const USER2: address = @0xCC;

#[test]
fun test_end_to_end() {
    let mut ts = ts::begin(ADMIN);
    {
        assert_eq(ts.has_most_recent_for_sender<AdminCap>(), false);
        init(ts.ctx());
    };

    ts.next_tx(ADMIN);
    {
        let admin_cap = ts.take_from_sender<AdminCap>();

        let hero1 = create_hero(&admin_cap, b"Hero 1".to_string(), 100, ts.ctx());
        transfer::public_transfer(hero1, USER1);

        let hero2 = create_hero(&admin_cap, b"Hero 2".to_string(), 50, ts.ctx());
        transfer::public_transfer(hero2, USER2);

        create_arena(&admin_cap, ts.ctx());

        ts.return_to_sender(admin_cap);
    };

        ts.next_tx(USER1);
    {
        let mut arena = ts.take_shared<FightArena>();
        let hero1 = ts.take_from_sender<Hero>();
        add_hero_to_arena(&mut arena, USER1, hero1);
        ts::return_shared(arena);
    };

    ts.next_tx(USER2);
    {
        let mut arena = ts.take_shared<FightArena>();
        let hero2 = ts.take_from_sender<Hero>();
        add_hero_to_arena(&mut arena, USER2, hero2);
        ts::return_shared(arena);
    };

    ts.next_tx(ADMIN);
    {
        let arena = ts.take_shared<FightArena>();
        let admin_cap = ts.take_from_sender<AdminCap>();
        assert_eq(ts::has_most_recent_for_address<Hero>(USER1), false);
        fight(&admin_cap, arena);
        ts.return_to_sender(admin_cap);
    };

    ts.next_tx(USER1);
    {
        assert_eq(ts.has_most_recent_for_sender<Hero>(), true);
    };

    ts.next_tx(USER2);
    {
        assert_eq(ts.has_most_recent_for_sender<Hero>(), false);
    };

    ts.end();
}
