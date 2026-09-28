# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GlenElendraGuardian do
  include_context "two player game"

  let!(:guardian) { ResolvePermanent("Glen Elendra Guardian", owner: p1) }

  it "is a 3/4 flash flying faerie wizard that enters with a -1/-1 counter" do
    expect(guardian.card.types).to include("Faerie", "Wizard")
    expect(guardian.power).to eq(2)
    expect(guardian.toughness).to eq(3)
    expect(guardian.card.flash?).to be(true)
    expect(guardian.flying?).to be(true)
  end

  it "counters target noncreature spell, and its controller draws a card" do
    p2.add_mana(red: 1)
    p2.cast(card: Card("Lightning Bolt", owner: p2)) { |a| a.pay_mana(red: 1).targeting(p1) }
    p1.add_mana(blue: 2)
    library_count = p2.library.count

    p1.activate_ability(ability: guardian.activated_abilities.first) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1).targeting(game.stack.spells.first) }
    game.stack.resolve!

    expect(game.stack).to be_empty
    expect(p1.life).to eq(20)
    expect(p2.library.count).to eq(library_count - 1)
  end

  it "cannot target a creature spell" do
    go_to_main_phase_for!(p2)
    p2.add_mana(green: 2)
    p2.cast(card: Card("Grizzly Bears", owner: p2)) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    p1.add_mana(blue: 2)

    expect { p1.activate_ability(ability: guardian.activated_abilities.first) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1).targeting(game.stack.spells.first) } }
      .to raise_error(/Invalid target/)
  end
end
