# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChandraHeartOfFire do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:chandra) { ResolvePermanent("Chandra, Heart Of Fire", owner: p1) }

  def activate(index, &block)
    p1.activate_loyalty_ability(ability: chandra.loyalty_abilities[index], &block)
    game.stack.resolve!
    game.settle!
  end

  it "enters with 5 loyalty" do
    expect(chandra.loyalty).to eq(5)
  end

  it "+1: discards your hand, exiles the top three cards, and lets you play them this turn" do
    top_three = p1.library.cards.first(3)
    activate(0)

    expect(p1.hand.count).to eq(0)
    expect(top_three.map(&:zone)).to all(be_exile)
    expect(game.play_permissions.permits?(top_three.first, p1)).to eq(true)
    expect(chandra.loyalty).to eq(6)
  end

  it "+1: deals 2 damage to any target" do
    activate(1) { _1.targeting(p2) }

    expect(p2.life).to eq(18)
    expect(chandra.loyalty).to eq(6)
  end

  describe "-9" do
    before { chandra.change_loyalty!(9) }

    it "exiles every red instant and sorcery from your graveyard and library, lets you cast them, and adds {R}{R}{R}{R}{R}{R}" do
      bolt = Card("Lightning Bolt", owner: p1)
      shock = Card("Shock", owner: p1)
      green_spell = Card("Blossoming Defense", owner: p1)
      p1.graveyard.add(bolt)
      p1.library.add(shock)
      p1.graveyard.add(green_spell)
      activate(2)

      expect([bolt, shock].map(&:zone)).to all(be_exile)
      expect(green_spell.zone).to be_graveyard
      expect(game.play_permissions.permits?(bolt, p1)).to eq(true)
      expect(p1.mana_pool[:red]).to eq(6)
    end
  end
end
