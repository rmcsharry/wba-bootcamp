# wba-bootcamp - prereqs
A Web3 Builders Alliance bootcamp project

# Explainer
It's a smart contract that mimics a simple real-world event with tickets, so basically it manages a collection of tickets for that event.

The event keeps track only of the number of tickets created.
Each ticket has a price (and min price), a holder and a title. It also has a description and a method to update it (which in the real world we probably would not want, we'd rather need a way for a ticket holder to simply "sell" a ticket to a new holder)

The contract also emits events when a ticket is created and when a ticket's description is updated (although probably we'd want an event that emits if a ticket is sold on to a new holder, not sure, needs more thought!)

# Setup
It can be setup by following the steps here:
https://docs.sui.io/devnet/build/install

# Test
In a terminal, run `sui move test` (NOTE - test will fail, as I don't know how to mimic a coin transfer)

# Devnet address
TBD