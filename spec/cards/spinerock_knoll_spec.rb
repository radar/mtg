# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SpinerockKnoll do
  include_context "two player game"

  before { go_to_main_phase! }

  def enter_knoll!
    knoll = ResolvePermanent("Spinerock Knoll", owner: p1)
    game.settle!
    knoll
  end

  it "enters tapped and taps for {R}" do
    knoll = enter_knoll!
    game.skip_choice! while game.choices.any?
    expect(knoll).to be_tapped
    expect(knoll.activated_abilities.first.choices).to eq([:red])
  end

  it "exiles one of the top four cards face down and puts the rest on the bottom" do
    top = p1.library.first(4)
    size = p1.library.count
    knoll = enter_knoll!
    chosen = top.last
    game.resolve_choice!(target: chosen)

    expect(chosen.zone).to be_exile
    expect(knoll.exiled_cards).to include(chosen)
    expect(p1.library.count).to eq(size - 1)
    # The three that were not chosen are now at the bottom (compared by identity: they are all Forests).
    expect(p1.library.first(3).none? { |card| top.first(3).any? { _1.equal?(card) } }).to be(true)
  end

  describe "the payoff" do
    let(:bolt) { Card("Lightning Bolt", owner: p1) }
    let(:knoll) do
      p1.library.add(bolt)
      enter_knoll!.tap do
        game.resolve_choice!(target: bolt)
        _1.untap!
      end
    end

    def activate!
      ability = knoll.activated_abilities.last
      p1.add_mana(red: 1)
      p1.activate_ability(ability: ability) { _1.pay_mana(red: 1) }
      game.stack.resolve!
    end

    it "can't be activated unless an opponent was dealt 7 or more damage this turn" do
      expect(knoll.activated_abilities.last).not_to be_requirements_met
    end

    it "lets you play the exiled card for free once an opponent was dealt 7 or more damage" do
      knoll
      game.notify!(Magic::Events::DamageDealt.new(source: p1, target: p2, damage: 7))
      activate!

      expect(game.play_permissions.free_cast?(bolt, p1)).to be(true)
    end

    it "doesn't count damage dealt to you" do
      knoll
      game.notify!(Magic::Events::DamageDealt.new(source: p2, target: p1, damage: 7))

      expect(knoll.activated_abilities.last).not_to be_requirements_met
    end
  end
end
