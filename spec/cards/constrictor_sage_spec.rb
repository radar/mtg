# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ConstrictorSage do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Constrictor Sage", owner: p1) }
  let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "taps target creature an opponent controls and stuns it when it enters" do
    ResolvePermanent("Constrictor Sage", owner: p1)
    game.settle!

    expect(bear).to be_tapped
    expect(bear.counters.of_type(Magic::Counters::Stun).count).to eq(1)
  end

  it "renews for {2}{U}: taps target creature an opponent controls and stuns it" do
    p1.graveyard.add(card)
    p1.add_mana(blue: 3)

    p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(generic: { blue: 2 }, blue: 1).targeting(bear) }
    game.stack.resolve!

    expect(card.zone).to be_exile
    expect(bear).to be_tapped
    expect(bear.counters.of_type(Magic::Counters::Stun).count).to eq(1)
  end
end
