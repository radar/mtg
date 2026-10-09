# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GiantsBoulder do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:boulder) { ResolvePermanent("Giant's Boulder", owner: p1) }

  it "scries 2 when it enters" do
    expect(game.choices.last).to be_a(Magic::Choice::Scry)
  end

  context "after scrying" do
    before { game.skip_choice! if game.choices.any? }

    it "taps with {1} for one mana of any color" do
      p1.add_mana(colorless: 1)
      p1.activate_ability(ability: boulder.activated_abilities.first) do
        _1.pay_mana(generic: { colorless: 1 })
        _1.choose(:red)
      end
      expect(p1.mana_pool[:red]).to eq(1)
      expect(boulder).to be_tapped
    end

    it "sacrifices for {7} to destroy target permanent" do
      victim = ResolvePermanent("Grizzly Bears", owner: p2)
      p1.add_mana(green: 7)
      p1.activate_ability(ability: boulder.activated_abilities.last) do
        _1.targeting(victim)
        _1.pay_mana(generic: { green: 7 })
      end
      game.stack.resolve!
      game.settle!

      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
      expect(p1.graveyard.cards.map(&:name)).to include("Giant's Boulder")
    end
  end
end
