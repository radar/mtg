# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EscapeTunnel do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:tunnel) { ResolvePermanent("Escape Tunnel", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "has two activated abilities" do
    expect(tunnel.activated_abilities.size).to eq(2)
  end

  describe "{T}, Sacrifice: target creature with power 2 or less can't be blocked" do
    let(:ability) { tunnel.activated_abilities.last }

    before { tunnel.untap! }

    it "makes the creature unblockable this turn and sacrifices the land" do
      p1.activate_ability(ability:) { |a| a.targeting(bears) }
      game.stack.resolve!
      game.tick!

      expect(bears.has_keyword?(Magic::Cards::Keywords::CANT_BE_BLOCKED)).to eq(true)
      expect(p1.graveyard.cards.map(&:name)).to include("Escape Tunnel")
    end

    it "can't target a creature with power greater than 2" do
      big = ResolvePermanent("Serra Angel", owner: p1)

      expect { p1.activate_ability(ability:) { |a| a.targeting(big) } }.to raise_error(StandardError)
    end
  end
end
