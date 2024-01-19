#[test_only]
module event::event_tests {
  use event::tickets::{Self, Event, Ticket};
  use sui::test_scenario;
  use sui::coin::{Self, Coin};

  #[test]
  fun test_create() {
    let owner = @0xA;
    let user1 = @0xB;
    let user2 = @0xC;
    let payment: sui::coin::Coin<sui::sui::SUI> = sui::coin(100);

    let scenario_val = test_scenario::begin(owner);
    let scenario = &mut scenario_val;

    test_scenario::next_tx(scenario, owner);
    {
      tickets::init_for_testing(test_scenario::ctx(scenario));
    };

    test_scenario::next_tx(scenario, owner);
    {
      let event = test_scenario::take_from_sender<Event>(scenario);
      tickets::create_ticket(b"WBA Cohort 1", b"Richard Move", payment, &mut event, test_scenario::ctx(scenario));
      assert!(!test_scenario::has_most_recent_for_sender<Event>(scenario), 0);

      test_scenario::return_to_sender(scenario, event);
    };

    test_scenario::next_tx(scenario, user2);
    {
      assert!(test_scenario::has_most_recent_for_sender<Event>(scenario), 0);
    };

    test_scenario::end(scenario_val);
  }
}


