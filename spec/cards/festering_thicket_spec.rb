require "spec_helper"

RSpec.describe Magic::Cards::FesteringThicket do
  include_context "two player game"

  it "enters tapped and produces black or green" do
    land = ResolvePermanent("Festering Thicket", owner: p1)
    land.untap!
    p1.activate_ability(ability: land.activated_abilities.first) { _1.choose(:green) }

    expect(land).to be_tapped
    expect(p1.mana_pool[:green]).to eq(1)
  end

  describe "cycling {2}" do
    let(:card) { Card("Festering Thicket", owner: p1) }

    it "can be cycled from hand" do
      p1.hand.add(card)
      p1.add_mana(black: 2)

      expect { p1.cycle(card: card) { _1.pay_mana(generic: { black: 2 }) } }.to change { p1.hand.count }.by(0)
      expect(p1.graveyard.cards).to include(card)
    end

    it "can't be cycled from the battlefield" do
      land = ResolvePermanent("Festering Thicket", owner: p1)

      expect(land.activated_abilities.map { _1.class.name }).not_to include(a_string_matching(/Cycling/))
    end
  end
end