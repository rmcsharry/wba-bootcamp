module event::tickets {
  use std::option::{Self, Option};
  use std::string::{Self, String};
  
  use sui::transfer;
  use sui::object::{Self, UID, ID};
  use sui::tx_context::{Self, TxContext};
  use sui::object_table::{Self, ObjectTable};
  use sui::coin::{Self, Coin};
  use sui::sui::SUI;
  use sui::event;

  const NOT_THE_OWNER: u64 = 0;
  const INSUFFICIENT_FUNDS: u64 = 1;
  const MIN_TICKET_COST: u64 = 1;

  struct Ticket has key, store {
    id: UID,
    title: String,
    holder: String,
    description: Option<String>,
  }

  struct Event has key {
    id: UID,
    owner: address,
    counter: u64,
    tickets: ObjectTable<u64, Ticket>
  }

  struct TicketCreated has copy, drop {
    id: ID,
    title: String,
    holder: String,
  }

  struct DescriptionUpdate has copy, drop {
    title: String,
    holder: String,
    new_description: String,
  }

  fun init(ctx: &mut TxContext) {
    transfer::share_object(
      Event {
        id: object::new(ctx),
        owner: tx_context::sender(ctx),
        counter: 0,
        tickets: object_table::new(ctx),
      }
    )
  }

  public entry fun create_ticket(
    title: vector<u8>,
    holder: vector<u8>,
    payment: Coin<SUI>,
    event: &mut Event,
    ctx: &mut TxContext
  ) {
      let value = coin::value(&payment);
      assert!(value == MIN_TICKET_COST, INSUFFICIENT_FUNDS);
      transfer::public_transfer(payment, event.owner);

      event.counter = event.counter + 1;

      let id = object::new(ctx);

      event::emit(TicketCreated {
        id: object::uid_to_inner(&id),
        title: string::utf8(title),
        holder: string::utf8(holder),
      });

      let ticket = Ticket{
        id: id,
        title: string::utf8(title),
        holder: string::utf8(holder),
        description: option::none(),
      };

      object_table::add(&mut event.tickets, event.counter, ticket);
    }

  public entry fun update_description(event: &mut Event, new_description: vector<u8>, id: u64, ctx: &mut TxContext) {
    let user_ticket = object_table::borrow_mut(&mut event.tickets, id);
    assert!(tx_context::sender(ctx) == event.owner, NOT_THE_OWNER);

    let old_value = option::swap_or_fill(&mut user_ticket.description, string::utf8(new_description));

    event::emit(
      DescriptionUpdate {
        title: user_ticket.title,
        holder: user_ticket.holder,
        new_description: string::utf8(new_description),
      }
    );

    _ = old_value;
  }

  public fun get_ticket_info(event: &Event, id: u64): (
    String,
    String,
    Option<String>,
  ) {
    let ticket = object_table::borrow(&event.tickets, id);
    (
      ticket.title,
      ticket.holder,
      ticket.description,
    )
  }

  #[test_only]
  public fun init_for_testing(ctx: &mut TxContext) {
    init(ctx);
  }
}