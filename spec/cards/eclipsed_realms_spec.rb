# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EclipsedRealms do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:realms) { ResolvePermanent("Eclipsed Realms", owner: p1) }

  def tap_for(color)
    realms.untap!
    ability = realms.activated_abilities.find { |a| a.is_a?(described_class::ChosenTypeManaAbility) }
    p1.activate_ability(ability: ability) { |a| a.choose(color) }
  end

  it "only offers its listed creature types" do
    expect(game.choices.last.choices).to eq(described_class::TYPES)
    expect { game.resolve_choice!(creature_type: "Human") }.to raise_error(ArgumentError)
  end

  context "with Elf chosen" do
    before { game.resolve_choice!(creature_type: "Elf") }

    it "taps for {C}" do
      ability = realms.activated_abilities.find { |a| a.is_a?(described_class::ColorlessManaAbility) }
      p1.activate_ability(ability: ability)

      expect(p1.mana_pool[:colorless]).to eq(1)
    end

    it "adds restricted mana of any color, not plain pool mana" do
      tap_for(:green)

      expect(p1.mana_pool[:green]).to eq(0)
      expect(p1.restricted_mana.map(&:color)).to eq([:green])
    end

    it "pays for a spell of the chosen type" do
      tap_for(:green)
      elf = Card("Llanowar Elves", owner: p1)
      p1.hand.add(elf)

      p1.cast(card: elf) { |a| a.pay_mana(green: 1) }
      game.settle!

      expect(elf.zone).to be_a(Magic::Zones::Battlefield)
      expect(p1.restricted_mana).to be_empty
    end

    it "cannot pay for a spell of another type" do
      tap_for(:green)
      bears = Card("Grizzly Bears", owner: p1)
      p1.hand.add(bears)
      action = Magic::Actions::Cast.new(card: bears, player: p1, game: game)

      expect(action.mana_cost.can_pay?(p1)).to eq(false)
      expect(p1.restricted_mana.count).to eq(1)
    end

    it "counts toward the generic part of a cost, and is spent before plain mana" do
      tap_for(:white)
      elf = Card("Llanowar Elves", owner: p1)
      p1.hand.add(elf)
      p1.add_mana(green: 1)
      cost = Magic::Actions::Cast.new(card: elf, player: p1, game: game).mana_cost
      cost.adjusted_by(generic: 1)

      expect(cost.can_pay?(p1)).to eq(true)
      cost.pay(player: p1, payment: { generic: { white: 1 }, green: 1 })
      cost.finalize!(p1)

      expect(p1.restricted_mana).to be_empty
      expect(p1.mana_pool[:green]).to eq(0)
    end

    it "pays for an ability of a source of the chosen type" do
      tap_for(:green)
      elf = ResolvePermanent("Llanowar Elves", owner: p1)
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      cost = Magic::Costs::Mana.new(green: 1)

      cost.for_use = bears
      expect(cost.can_pay?(p1)).to eq(false)
      cost.for_use = elf
      expect(cost.can_pay?(p1)).to eq(true)
    end
  end
end
