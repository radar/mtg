require 'spec_helper'

RSpec.describe Magic::Cards::NineLives do
  include_context "two player game"
  let(:card) { Card("Nine Lives") }

  it "has hexproof" do
    expect(card.hexproof?).to eq(true)
  end

  context "when replacement creates a new replaceable effect" do
    let!(:nine_lives) { ResolvePermanent("Nine Lives", owner: p1) }
    let!(:doubling_season) { ResolvePermanent("Doubling Season", owner: p1) }
    let!(:attacker) { ResolvePermanent("Wood Elves", owner: p2) }

    it "re-checks replacement effects and doubles the Nine Lives counter" do
      effect = Magic::Effects::DealDamage.new(
        source: attacker,
        target: p1,
        damage: 1,
      )

      game.add_effect(effect)

      incarnation_counters = nine_lives.counters.of_type(Magic::Counters::Incarnation).count
      expect(incarnation_counters).to eq(2)
      expect(p1.life).to eq(20)
    end
  end
end
