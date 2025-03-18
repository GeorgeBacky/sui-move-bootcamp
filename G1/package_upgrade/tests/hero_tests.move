#[test_only]
module package_upgrade::hero_tests;

use sui::dynamic_field as df;
use sui::dynamic_object_field as dof;

use sui::coin;
use sui::package::Publisher;
use sui::sui::SUI;
use sui::test_scenario;

use package_upgrade::blacksmith;
use package_upgrade::hero::{Self, PowerKey, SwordKey};
use package_upgrade::version::{Self, Version};

const EShouldHaveFailed: u64 = 0x100;

#[test]
#[expected_failure(abort_code=version::EInvalidPackageVersion)]
fun hero_mint_should_fail() {
    let sender = @0x11111;
    let mut scenario = test_scenario::begin(sender);
    hero::init_for_testing(scenario.ctx());
    version::init_for_testing(scenario.ctx());

    scenario.next_tx(sender);
    let version = scenario.take_shared<Version>();
    let _hero = hero::mint_hero(&version, scenario.ctx());
    abort(EShouldHaveFailed)
}

#[test]
fun dfs_should_use_custom_keys() {

    let sender = @0x11111;
    let mut scenario = test_scenario::begin(sender);
    hero::init_for_testing(scenario.ctx());
    version::init_for_testing(scenario.ctx());

    scenario.next_tx(sender);
    let publisher = scenario.take_from_sender<Publisher>();
    let blacksmith = blacksmith::new_blacksmith(&publisher, 100, scenario.ctx());
    let sword = blacksmith.new_sword(80, scenario.ctx());
    let attack = sword.attack();
    assert!(attack == 80);

    let version = scenario.take_shared<Version>();

    let coin = coin::mint_for_testing<SUI>(5_000_000_000, scenario.ctx());
    let mut hero = hero::mint_hero_v2(&version, coin, scenario.ctx());
    hero.equip_sword(&version, sword);
    assert!(!dof::exists_(hero.uid_mut_for_testing(), b"sword".to_string()));
    assert!(dof::exists_(&hero.id, SwordKey()));
    assert!(*df::borrow(&hero.id, PowerKey()) == attack);

    
    transfer::public_transfer(blacksmith, sender);
    transfer::public_transfer(hero, sender);
    scenario.return_to_sender(publisher);
    test_scenario::return_shared(version);

    scenario.end();
}

