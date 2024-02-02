require "spec_helper"

RSpec.describe Magic::Cards::Meteorite do
  include_context "two player game"

  let(:card) { Card("Meteorite") }

  it "deals 2 damage to any target" do
    cast_and_resolve(card: card)

    choice = game.choices.last
    expect(choice).to be_a(described_class::Choice)

    game.resolve_choice!(target: p2)

    expect(p2.life).to eq(18)
  end

  context "mana ability" do
    subject { ResolvePermanent("Meteorite") }
    let(:mana_ability) { subject.activated_abilities.first }

    it "lets player choose which mana" do
      p1.activate_mana_ability(ability: mana_ability) do
        _1.choose(:green)
      end

      expect(p1.mana_pool[:green]).to eq(1)
    end
  end
end
