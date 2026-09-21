# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RepeatedReverberation do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast_repeated_reverberation
    p1.add_mana(red: 4)
    cast_action(player: p1, card: Card("Repeated Reverberation", owner: p1))
      .pay_mana(generic: { red: 2 }, red: 2)
      .perform
    game.stack.resolve!
  end

  it "copies the next instant spell you cast this turn twice, declining new targets" do
    cast_repeated_reverberation

    p1.add_mana(red: 1)
    cast_action(player: p1, card: Card("Shock", owner: p1))
      .pay_mana(red: 1)
      .targeting(p2)
      .perform

    game.skip_choice!
    expect(p2.life).to eq(16)

    game.stack.resolve!
    expect(p2.life).to eq(14)
  end

  it "doesn't copy a second instant spell cast the same turn" do
    cast_repeated_reverberation

    p1.add_mana(red: 2)
    cast_action(player: p1, card: Card("Shock", owner: p1))
      .pay_mana(red: 1)
      .targeting(p2)
      .perform
    game.skip_choice!
    game.stack.resolve!

    cast_action(player: p1, card: Card("Shock", owner: p1))
      .pay_mana(red: 1)
      .targeting(p2)
      .perform

    expect(game.choices).to be_empty
    game.stack.resolve!

    expect(p2.life).to eq(12)
  end

  it "doesn't trigger for a creature spell" do
    cast_repeated_reverberation

    p1.add_mana(green: 2)
    cast_action(player: p1, card: Card("Grizzly Bears", owner: p1))
      .pay_mana(generic: { green: 1 }, green: 1)
      .perform

    expect(game.choices).to be_empty
  end

  it "doesn't trigger the following turn if nothing qualified this turn" do
    cast_repeated_reverberation
    game.next_turn

    p1.add_mana(red: 1)
    cast_action(player: p1, card: Card("Shock", owner: p1))
      .pay_mana(red: 1)
      .targeting(p2)
      .perform

    expect(game.choices).to be_empty
  end

  it "copies a loyalty ability activated this turn" do
    cast_repeated_reverberation

    planeswalker = Magic::Permanent.resolve(game: game, owner: p1, card: Card("Ob Nixilis Reignited", owner: p1))
    ability = planeswalker.loyalty_abilities.first

    starting_hand_size = p1.hand.count
    p1.activate_loyalty_ability(ability: ability)

    expect(game.choices).to be_empty
    expect(p1.hand.count).to eq(starting_hand_size + 2)

    game.stack.resolve!
    expect(p1.hand.count).to eq(starting_hand_size + 3)
  end
end
