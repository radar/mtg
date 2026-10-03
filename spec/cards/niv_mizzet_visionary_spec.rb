# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NivMizzetVisionary do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:niv) { ResolvePermanent("Niv Mizzet Visionary", owner: p1) }

  def shock(player, target)
    spell = Card("Shock", owner: player)
    player.hand.add(spell)
    player.add_mana(red: 1)
    player.cast(card: spell) { |a| a.pay_mana(red: 1).targeting(target) }
    game.settle!
  end

  it "is a legendary 5/5 Dragon Wizard with flying and no maximum hand size" do
    expect([niv.power, niv.toughness]).to eq([5, 5])
    expect(niv).to be_flying
    expect(niv).to be_legendary
    expect(niv.card.no_maximum_hand_size?).to be(true)
  end

  it "draws that many cards when a source you control deals noncombat damage to an opponent" do
    hand = p1.hand.count
    shock(p1, p2)

    expect(p2.life).to eq(18)
    expect(p1.hand.count).to eq(hand + 2) # Shock deals 2, so two cards
  end

  it "doesn't trigger for damage dealt to a creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    hand = p1.hand.count
    shock(p1, bears)

    expect(p1.hand.count).to eq(hand)
  end

  it "doesn't trigger for damage to you" do
    hand = p1.hand.count
    shock(p1, p1)

    expect(p1.hand.count).to eq(hand)
  end

  it "doesn't trigger for an opponent's damage source" do
    hand = p1.hand.count
    shock(p2, p1)

    expect(p1.hand.count).to eq(hand)
  end

  it "doesn't trigger for combat damage" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(niv, target: p2)
    current_turn.attackers_declared!
    hand = p1.hand.count
    go_to_combat_damage!
    game.settle!

    expect(p2.life).to eq(15)
    expect(p1.hand.count).to eq(hand)
  end
end
