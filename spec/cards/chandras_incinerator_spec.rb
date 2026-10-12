# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChandrasIncinerator do
  include_context "two player game"
  before { go_to_main_phase! }

  def shock(player, target)
    spell = Card("Shock", owner: player)
    player.hand.add(spell)
    player.add_mana(red: 1)
    player.cast(card: spell) { |a| a.pay_mana(red: 1).targeting(target) }
    game.settle!
  end

  it "is a 6/6 trampling Elemental" do
    incinerator = ResolvePermanent("Chandra's Incinerator", owner: p1)

    expect([incinerator.power, incinerator.toughness]).to eq([6, 6])
    expect(incinerator.has_keyword?(Magic::Cards::Keywords::TRAMPLE)).to eq(true)
  end

  describe "cost reduction" do
    def cast_with(mana)
      card = Card("Chandra's Incinerator", owner: p1)
      p1.hand.add(card)
      p1.add_mana(red: mana[:generic][:red] + mana[:red])
      p1.cast(card:) { |a| a.pay_mana(**mana) }
      game.stack.resolve!
      game.settle!
      card
    end

    it "costs {X} less, X being the noncombat damage dealt to your opponents this turn" do
      shock(p1, p2)
      card = cast_with(generic: { red: 3 }, red: 1)

      expect(card.zone).to be_battlefield
    end

    it "costs full price with no damage dealt" do
      expect { cast_with(generic: { red: 3 }, red: 1) }.to raise_error(StandardError)
    end
  end

  describe "when a source you control deals noncombat damage to an opponent" do
    let!(:incinerator) { ResolvePermanent("Chandra's Incinerator", owner: p1) }
    let!(:victim) { ResolvePermanent("Serra Angel", owner: p2) } # 4/4

    it "deals that much damage to a creature that player controls" do
      other = ResolvePermanent("Baneslayer Angel", owner: p2) # a second target, so there is a real choice
      shock(p1, p2)
      game.resolve_choice!(target: victim)
      game.settle!

      expect(victim.damage).to eq(2)
      expect(other.damage).to eq(0)
    end

    it "picks the only legal target automatically" do
      shock(p1, p2)
      game.settle!

      expect(victim.damage).to eq(2)
    end

    it "doesn't trigger when your own creature would be the only target" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      victim.destroy!
      game.settle!
      shock(p1, p2)

      expect(game.choices).to be_empty
    end
  end
end
