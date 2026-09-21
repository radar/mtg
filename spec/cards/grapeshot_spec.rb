# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Grapeshot do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:grapeshot) { Card("Grapeshot", owner: p1) }

  before { p1.hand.add(grapeshot) }

  it "deals 1 damage to any target" do
    p1.add_mana(red: 2)
    p1.cast(card: grapeshot) { |a| a.pay_mana(generic: { red: 1 }, red: 1); a.targeting(p2) }
    game.stack.resolve!

    expect(p2.life).to eq(19)
  end

  it "copies itself for each spell cast before it this turn" do
    shock_one = Card("Shock", owner: p1)
    shock_two = Card("Shock", owner: p1)
    p1.hand.add(shock_one)
    p1.hand.add(shock_two)
    p1.add_mana(red: 4)

    p1.cast(card: shock_one) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    game.stack.resolve!
    p1.cast(card: shock_two) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    game.stack.resolve!

    p1.cast(card: grapeshot) { |a| a.pay_mana(generic: { red: 1 }, red: 1); a.targeting(p2) }
    game.stack.resolve!
    game.skip_choice!

    expect(p2.life).to eq(13)
  end

  it "may choose new targets for each copy" do
    shock = Card("Shock", owner: p1)
    p1.hand.add(shock)
    p1.add_mana(red: 3)

    p1.cast(card: shock) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    game.stack.resolve!

    p1.cast(card: grapeshot) { |a| a.pay_mana(generic: { red: 1 }, red: 1); a.targeting(p2) }
    game.stack.resolve!
    game.resolve_choice!
    game.resolve_choice!(target: p1)

    expect(p1.life).to eq(19)
    expect(p2.life).to eq(17)
  end
end
