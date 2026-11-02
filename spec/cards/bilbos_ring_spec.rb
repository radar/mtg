# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BilbosRing do
  include_context "two player game"

  let!(:ring) { ResolvePermanent("Bilbos Ring", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:other) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:saradoc) { ResolvePermanent("Saradoc Master Of Buckland", owner: p1) }
  before { go_to_main_phase! }

  def halfling_equip = ring.activated_abilities.first
  def any_equip = ring.activated_abilities.last

  def equip(creature, ability: any_equip, mana: 4)
    p1.add_mana(colorless: mana)
    p1.activate_ability(ability: ability) do |a|
      a.pay_mana(generic: { colorless: mana })
      a.targeting(creature)
    end
    game.stack.resolve!
    game.tick!
  end

  def attack_with(*creatures)
    skip_to_combat!
    current_turn.declare_attackers!
    creatures.each { |c| p1.declare_attacker(attacker: c, target: p2) }
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a legendary {3} Equipment" do
    expect(ring.card).to be_a(Magic::Cards::Equipment)
    expect(ring.legendary?).to be true
    expect(ring.card.mana_value).to eq(3)
    expect(ring.activated_abilities.size).to eq(2)
  end

  describe "equip Halfling {1}" do
    it "attaches to a Halfling you control for {1}" do
      equip(saradoc, ability: halfling_equip, mana: 1)

      expect(ring.attached_to).to eq(saradoc)
    end

    it "cannot target a non-Halfling" do
      p1.add_mana(colorless: 1)

      expect do
        p1.activate_ability(ability: halfling_equip) do |a|
          a.pay_mana(generic: { colorless: 1 })
          a.targeting(bears)
        end
      end.to raise_error(StandardError, /Invalid target/)
    end

    it "can only be activated as a sorcery" do
      go_to_main_phase_for!(p2)
      p1.add_mana(colorless: 1)

      expect do
        p1.activate_ability(ability: halfling_equip) do |a|
          a.pay_mana(generic: { colorless: 1 })
          a.targeting(saradoc)
        end
      end.to raise_error(Magic::IllegalAction, /requirements to activate/)
    end
  end

  describe "equip {4}" do
    it "attaches to any creature you control for {4}" do
      equip(bears)

      expect(ring.attached_to).to eq(bears)
    end

    it "cannot be paid with only {1}" do
      p1.add_mana(colorless: 1)

      expect do
        p1.activate_ability(ability: any_equip) do |a|
          a.pay_mana(generic: { colorless: 1 })
          a.targeting(bears)
        end
      end.to raise_error(Magic::Costs::Mana::CannotPay)
    end

    it "can only be activated as a sorcery" do
      go_to_main_phase_for!(p2)
      p1.add_mana(colorless: 4)

      expect do
        p1.activate_ability(ability: any_equip) do |a|
          a.pay_mana(generic: { colorless: 4 })
          a.targeting(bears)
        end
      end.to raise_error(Magic::IllegalAction, /requirements to activate/)
    end
  end

  describe "during your turn, equipped creature has hexproof and can't be blocked" do
    it "grants both on your turn, to the equipped creature only" do
      equip(bears)

      expect(bears).to have_keyword(:hexproof)
      expect(bears).to have_keyword(:cant_be_blocked)
      expect(other).not_to have_keyword(:hexproof)
      expect(other).not_to have_keyword(:cant_be_blocked)
    end

    it "rejects an opponent's targeting on your turn" do
      equip(bears)
      p2.add_mana(red: 1)

      expect do
        p2.cast(card: Card("Shock", owner: p2)) do |a|
          a.pay_mana(red: 1)
          a.targeting(bears)
        end
      end.to raise_error(Magic::Actions::Cast::InvalidTarget)
    end

    it "means the creature cannot be blocked" do
      equip(bears)
      blocker = ResolvePermanent("Grizzly Bears", owner: p2)
      skip_to_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: bears, target: p2)
      current_turn.attackers_declared!

      expect(current_turn.can_block?(attacker: bears, blocker: blocker)).to eq(false)
    end

    it "does not grant either during the opponent's turn" do
      equip(bears)
      go_to_main_phase_for!(p2)
      game.tick!

      expect(bears).not_to have_keyword(:hexproof)
      expect(bears).not_to have_keyword(:cant_be_blocked)
    end

    it "allows the opponent to target it during their turn" do
      equip(bears)
      go_to_main_phase_for!(p2)
      game.tick!
      p2.add_mana(red: 1)

      expect do
        p2.cast(card: Card("Shock", owner: p2)) do |a|
          a.pay_mana(red: 1)
          a.targeting(bears)
        end
      end.not_to raise_error
    end

    it "is lost when the Ring leaves the battlefield" do
      equip(bears)
      ring.destroy!
      game.settle!
      game.tick!

      expect(bears).not_to have_keyword(:hexproof)
      expect(bears).not_to have_keyword(:cant_be_blocked)
    end
  end

  describe "whenever equipped creature attacks alone" do
    it "draws a card and loses 1 life" do
      equip(bears)
      hand = p1.hand.count
      life = p1.life
      attack_with(bears)

      expect(p1.hand.count).to eq(hand + 1)
      expect(p1.life).to eq(life - 1)
    end

    it "does not trigger when it attacks with another creature" do
      equip(bears)
      hand = p1.hand.count
      attack_with(bears, other)

      expect(p1.hand.count).to eq(hand)
      expect(p1.life).to eq(20)
      expect(game.choices).to be_empty
    end

    it "does not trigger when an unequipped creature attacks alone" do
      equip(bears)
      hand = p1.hand.count
      attack_with(other)

      expect(p1.hand.count).to eq(hand)
      expect(p1.life).to eq(20)
      expect(game.choices).to be_empty
    end

    it "still resolves if the Ring leaves before the trigger resolves" do
      equip(bears)
      hand = p1.hand.count
      skip_to_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: bears, target: p2)
      current_turn.attackers_declared!
      ring.destroy!
      game.settle!

      expect(p1.hand.count).to eq(hand + 1)
      expect(p1.life).to eq(19)
    end
  end
end
