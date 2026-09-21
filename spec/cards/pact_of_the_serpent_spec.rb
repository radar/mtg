# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PactOfTheSerpent do
  include_context "two player game"
  before { go_to_main_phase! }
  subject(:pact_of_the_serpent) { Card("Pact Of The Serpent") }

  it "target player draws X cards and loses X life, where X is the number of creatures of the chosen type they control" do
    2.times { ResolvePermanent("Bloom Tender", owner: p2) }
    ResolvePermanent("Bloom Tender", owner: p1)

    pact_of_the_serpent.chosen_creature_type = "Elf"

    library_count_before = p2.library.count
    life_before = p2.life

    p1.add_mana(black: 3)
    p1.cast(card: pact_of_the_serpent) do |a|
      a.targeting(p2)
      a.pay_mana(generic: { black: 1 }, black: 2)
    end
    game.stack.resolve!

    expect(p2.library.count).to eq(library_count_before - 2)
    expect(p2.life).to eq(life_before - 2)
  end

  it "only counts creatures of the chosen type the target player controls" do
    ResolvePermanent("Bloom Tender", owner: p2)

    pact_of_the_serpent.chosen_creature_type = "Human"

    library_count_before = p2.library.count
    life_before = p2.life

    p1.add_mana(black: 3)
    p1.cast(card: pact_of_the_serpent) do |a|
      a.targeting(p2)
      a.pay_mana(generic: { black: 1 }, black: 2)
    end
    game.stack.resolve!

    expect(p2.library.count).to eq(library_count_before)
    expect(p2.life).to eq(life_before)
  end
end
