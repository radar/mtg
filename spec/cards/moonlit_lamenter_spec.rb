# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MoonlitLamenter do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:lamenter) { ResolvePermanent("Moonlit Lamenter", owner: p1) }

  it "is a 2/5 treefolk cleric that enters with a -1/-1 counter" do
    expect(lamenter.card.types).to include("Treefolk", "Cleric")
    expect(lamenter.power).to eq(1)
    expect(lamenter.toughness).to eq(4)
  end

  it "draws a card for {1}{W}, remove a counter, as a sorcery" do
    p1.add_mana(white: 2)
    library_count = p1.library.count

    p1.activate_ability(ability: lamenter.activated_abilities.first) { |a| a.pay_mana(generic: { white: 1 }, white: 1) }
    game.stack.resolve!

    expect(p1.library.count).to eq(library_count - 1)
    expect(lamenter.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(0)
  end
end
