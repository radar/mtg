# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Reiterate do
  include_context "two player game"

  it "copies target instant or sorcery spell, offering new targets for the copy" do
    p1.add_mana(red: 4)
    shock_action = cast_action(player: p1, card: Card("Shock", owner: p1))
      .pay_mana(red: 1)
      .targeting(p2)
    shock_action.perform

    reiterate = Card("Reiterate", owner: p1)
    p1.hand.add(reiterate)
    action = cast_action(player: p1, card: reiterate)
      .pay_mana(generic: { red: 1 }, red: 2)
      .targeting(shock_action)
    action.perform

    game.stack.resolve!
    expect(game.choices).not_to be_empty

    game.skip_choice!
    expect(p2.life).to eq(18)

    game.stack.resolve!
    expect(p2.life).to eq(16)

    expect(reiterate.zone).to be_graveyard
  end

  it "lets you choose a new target for the copy" do
    # Created before casting Shock -- ResolvePermanent settles the stack as it
    # enters, which would otherwise resolve (and remove) the still-on-the-stack
    # Shock before Reiterate gets a chance to target it.
    bear = ResolvePermanent("Grizzly Bears", owner: p2)

    p1.add_mana(red: 4)
    shock_action = cast_action(player: p1, card: Card("Shock", owner: p1))
      .pay_mana(red: 1)
      .targeting(p2)
    shock_action.perform

    reiterate = Card("Reiterate", owner: p1)
    p1.hand.add(reiterate)
    action = cast_action(player: p1, card: reiterate)
      .pay_mana(generic: { red: 1 }, red: 2)
      .targeting(shock_action)
    action.perform

    game.stack.resolve!
    game.resolve_choice!
    game.resolve_choice!(target: bear)

    expect(bear.damage).to eq(2)
    expect(p2.life).to eq(20)

    game.stack.resolve!
    expect(p2.life).to eq(18)
  end

  it "returns to hand instead of the graveyard when its buyback cost is paid" do
    p1.add_mana(red: 7)
    shock_action = cast_action(player: p1, card: Card("Shock", owner: p1))
      .pay_mana(red: 1)
      .targeting(p2)
    shock_action.perform

    reiterate = Card("Reiterate", owner: p1)
    p1.hand.add(reiterate)
    action = cast_action(player: p1, card: reiterate)
      .pay_mana(generic: { red: 1 }, red: 2)
    action.pay_kicker(generic: { red: 3 })
    action.targeting(shock_action)
    action.perform

    game.stack.resolve!
    game.skip_choice!
    game.stack.resolve!

    expect(reiterate.zone).to be_hand
  end
end
