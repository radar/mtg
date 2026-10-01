# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChampionOfDusan do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Champion Of Dusan", owner: p1) }

  it "is a 4/2 Human Warrior with trample" do
    permanent = ResolvePermanent("Champion Of Dusan", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([4, 2])
    expect(permanent).to be_trample
  end

  it "renews for {1}{G}: a +1/+1 counter and a trample counter on target creature" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.graveyard.add(card)
    p1.add_mana(green: 2)

    p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(generic: { green: 1 }, green: 1).targeting(bear) }
    game.stack.resolve!
    game.tick!

    expect(card.zone).to be_exile
    expect(bear.power).to eq(3)
    expect(bear).to be_trample
  end
end
