# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GnarlbarkElm do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:elm) { ResolvePermanent("Gnarlbark Elm", owner: p1) }

  it "is a 3/4 treefolk warlock that enters with two -1/-1 counters" do
    expect(elm.card.types).to include("Treefolk", "Warlock")
    expect(elm.power).to eq(1)
    expect(elm.toughness).to eq(2)
  end

  it "gives target creature -2/-2 until end of turn for {2}{B}, remove two counters, as a sorcery" do
    berserker = ResolvePermanent("Boneclub Berserker", owner: p2) # 2/4, survives -2/-2
    p1.add_mana(black: 3)

    p1.activate_ability(ability: elm.activated_abilities.first) { |a| a.pay_mana(generic: { black: 2 }, black: 1).targeting(berserker) }
    game.stack.resolve!

    expect(berserker.power).to eq(0)
    expect(berserker.toughness).to eq(2)
    expect(elm.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(0)
  end
end
