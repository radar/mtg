# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheOneRing do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:burden) { Magic::Counters::Burden }

  def burdens(ring) = ring.counters.of_type(burden).count

  def cast_ring
    card = Card("The One Ring", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 4)
    p1.cast(card: card) { |a| a.pay_mana(generic: { black: 4 }) }
    game.stack.resolve!
    game.settle!
    p1.permanents.find { _1.name == "The One Ring" }
  end

  def bolt_p1_from_bears
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    game.add_effect(Magic::Effects::DealDamage.new(source: bears, target: p1, damage: 3))
    game.settle!
  end

  it "is a legendary indestructible artifact" do
    ring = ResolvePermanent("The One Ring", owner: p1)
    expect(ring).to be_legendary
    expect(ring.type?("Artifact")).to eq(true)
    expect(ring).to be_indestructible
    ring.destroy!
    game.settle!
    expect(ring.zone).to eq(game.battlefield)
  end

  context "when it enters" do
    it "gives you protection from everything until your next turn if you cast it" do
      ring = cast_ring
      expect(ring.zone).to eq(game.battlefield)
      bolt_p1_from_bears
      expect(p1.life).to eq(20)
      bolt = Card("Lightning Bolt", owner: p2)
      expect(p1.can_be_targeted_by?(bolt)).to eq(false)
    end

    it "lasts through the opponent's turn and ends on your next turn" do
      cast_ring
      game.next_turn
      expect(p1).to be_protected_from_everything
      game.next_turn
      expect(current_turn.active_player).to eq(p1)
      expect(p1).not_to be_protected_from_everything
      bolt_p1_from_bears
      expect(p1.life).to eq(17)
    end

    it "does nothing if it was not cast" do
      ResolvePermanent("The One Ring", owner: p1, cast: false)
      game.settle!
      expect(p1).not_to be_protected_from_everything
      bolt_p1_from_bears
      expect(p1.life).to eq(17)
      expect(game.choices).to be_empty
    end
  end

  context "at the beginning of your upkeep" do
    let!(:ring) { ResolvePermanent("The One Ring", owner: p1) }

    def p1_upkeep
      2.times { game.next_turn }
      current_turn.untap!
      current_turn.upkeep!
      game.settle!
    end

    it "loses 1 life for each burden counter" do
      2.times { ring.add_counter(burden) }
      p1_upkeep
      expect(p1.life).to eq(18)
    end

    it "loses no life with no burden counters" do
      p1_upkeep
      expect(p1.life).to eq(20)
    end

    it "does not trigger on the opponent's upkeep" do
      2.times { ring.add_counter(burden) }
      game.next_turn
      current_turn.untap!
      current_turn.upkeep!
      game.settle!
      expect(p1.life).to eq(20)
      expect(game.choices).to be_empty
    end
  end

  context "the tap ability" do
    let!(:ring) { ResolvePermanent("The One Ring", owner: p1) }

    def activate
      p1.activate_ability(ability: ring.activated_abilities.first)
      game.stack.resolve!
      game.settle!
    end

    it "puts a burden counter then draws that many cards" do
      expect { activate }.to change { p1.hand.count }.by(1)
      expect(burdens(ring)).to eq(1)
      expect(ring).to be_tapped
    end

    it "draws a card for each burden counter including the new one" do
      2.times { ring.add_counter(burden) }
      expect { activate }.to change { p1.hand.count }.by(3)
      expect(burdens(ring)).to eq(3)
    end

    it "cannot be activated while tapped" do
      activate
      expect { p1.activate_ability(ability: ring.activated_abilities.first) }.to raise_error(StandardError)
      expect(burdens(ring)).to eq(1)
    end
  end
end
