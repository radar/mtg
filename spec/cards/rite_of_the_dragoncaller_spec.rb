# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RiteOfTheDragoncaller do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:rite) { ResolvePermanent("Rite Of The Dragoncaller", owner: p1) }

  it "creates a 5/5 red Dragon token with flying whenever you cast an instant or sorcery spell" do
    p1.add_mana(red: 1)
    p1.cast(card: Card("Boltwave", owner: p1)) { |a| a.pay_mana(red: 1) }
    game.settle!
    dragon = p1.creatures.find { _1.name == "Dragon" }

    expect([dragon.power, dragon.toughness]).to eq([5, 5])
    expect(dragon).to be_flying
  end

  it "doesn't trigger on a creature spell" do
    p1.add_mana(green: 2)
    p1.cast(card: Card("Grizzly Bears", owner: p1)) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!

    expect(p1.creatures.select { _1.name == "Dragon" }).to be_empty
  end
end
