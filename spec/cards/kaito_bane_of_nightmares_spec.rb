# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KaitoBaneOfNightmares do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:kaito) { ResolvePermanent("Kaito Bane Of Nightmares", owner: p1) }

  def activate(index)
    p1.activate_loyalty_ability(ability: kaito.loyalty_abilities[index]) { yield _1 if block_given? }
    game.settle!
  end

  it "has 4 loyalty" do
    expect(kaito.loyalty).to eq(4)
  end

  describe "during your turn" do
    it "is a 3/4 Ninja creature with hexproof" do
      game.tick!

      expect(kaito).to be_planeswalker
      expect(kaito).to be_creature
      expect(kaito.type?("Ninja")).to be(true)
      expect([kaito.power, kaito.toughness]).to eq([3, 4])
      expect(kaito).to have_keyword(:hexproof)
    end

    it "stops being a creature on your opponent's turn" do
      game.next_turn
      go_to_main_phase!
      game.tick!

      expect(kaito).to be_planeswalker
      expect(kaito).not_to be_creature
      expect(kaito).not_to have_keyword(:hexproof)
    end
  end

  describe "+1" do
    it "gives you an emblem: Ninjas you control get +1/+1" do
      activate(0)
      game.tick!

      expect(kaito.loyalty).to eq(5)
      expect([kaito.power, kaito.toughness]).to eq([4, 5])
    end

    it "doesn't buff non-Ninjas" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      activate(0)
      game.tick!

      expect(bears.power).to eq(2)
    end
  end

  describe "0" do
    it "surveils 2, then draws a card for each opponent who lost life this turn" do
      p2.lose_life(2)
      hand_size = p1.hand.cards.count
      activate(1)
      expect(game.choices.last).to be_a(Magic::Choice::Surveil)
      game.resolve_choice!(graveyard: [], top: p1.library.first(2))

      expect(p1.hand.cards.count).to eq(hand_size + 1)
    end

    it "draws nothing if no opponent lost life" do
      hand_size = p1.hand.cards.count
      activate(1)
      game.resolve_choice!(graveyard: [], top: p1.library.first(2))

      expect(p1.hand.cards.count).to eq(hand_size)
    end
  end

  describe "-2" do
    it "taps target creature and puts two stun counters on it" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      activate(2) { _1.targeting(bears) }

      expect(kaito.loyalty).to eq(2)
      expect(bears).to be_tapped
      expect(bears.counters.of_type(Magic::Counters::Stun).count).to eq(2)
    end
  end

  describe "ninjutsu" do
    let(:ninja) { Card("Kaito Bane Of Nightmares", owner: p1).tap { p1.hand.add(_1) } }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    def attack!
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(bears, target: p2)
      current_turn.attackers_declared!
    end

    def ninjutsu!
      p1.add_mana(white: 0, blue: 1, black: 2)
      p1.ninjutsu(card: ninja, attacker: bears) { _1.pay_mana(generic: { black: 1 }, blue: 1, black: 1) }
      game.stack.resolve!
      game.settle!
    end

    it "returns the unblocked attacker to hand and puts the card onto the battlefield tapped and attacking" do
      attack!
      ninjutsu!

      expect(bears.zone).to be_nil
      expect(bears.card.zone).to be_hand
      entered = p1.permanents.find { _1.card == ninja }
      expect(entered).to be_tapped
      expect(current_turn.combat.attacking?(entered)).to be(true)
      expect(current_turn.combat.attack_for_attacker(entered).target).to eq(p2)
    end

    it "deals its combat damage to the player" do
      attack!
      ninjutsu!
      go_to_combat_damage!
      game.settle!

      expect(p2.life).to eq(17)
    end

    it "can't be activated for a blocked attacker" do
      blocker = ResolvePermanent("Grizzly Bears", owner: p2)
      attack!
      current_turn.declare_blocker(blocker, attacker: bears)
      action = Magic::Actions::Ninjutsu.new(game: game, player: p1, card: ninja, attacker: bears)

      expect(action.illegal_reason).to match(/blocked/)
    end

    it "can't be activated before blockers are declared" do
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(bears, target: p2)
      action = Magic::Actions::Ninjutsu.new(game: game, player: p1, card: ninja, attacker: bears)

      expect(action.illegal_reason).to match(/after blockers/)
    end

    it "is offered as a legal action for an unblocked attacker" do
      ninja
      attack!
      p1.add_mana(blue: 1, black: 2)

      expect(game.legal_actions(p1).grep(Magic::Actions::Ninjutsu).map(&:attacker)).to eq([bears])
    end
  end
end
