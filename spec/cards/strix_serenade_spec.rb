# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StrixSerenade do
  include_context "two player game"

  before { go_to_main_phase! }

  it "counters a creature spell and gives its controller a 2/2 flying Bird" do
    p1.add_mana(green: 2)
    p1.cast(card: Card("Grizzly Bears", owner: p1)) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }

    p1.add_mana(blue: 1)
    p1.cast(card: Card("Strix Serenade", owner: p1)) { |a| a.pay_mana(blue: 1).targeting(game.stack.spells.first) }
    game.stack.resolve!
    game.settle!

    expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    bird = p1.creatures.find { _1.name == "Bird" }
    expect(bird).not_to be_nil
    expect([bird.power, bird.toughness]).to eq([2, 2])
    expect(bird.flying?).to eq(true)
  end

  it "has no targets when the stack holds no artifact, creature or planeswalker spell" do
    expect(Card("Strix Serenade", owner: p1).target_choices).to be_empty
  end
end
