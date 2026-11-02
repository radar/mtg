# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Glamdring do
  include_context "two player game"

  let!(:glamdring) { ResolvePermanent("Glamdring", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:other) { ResolvePermanent("Grizzly Bears", owner: p1) }
  before { go_to_main_phase! }

  def equip(creature)
    p1.add_mana(colorless: 3)
    p1.activate_ability(ability: glamdring.activated_abilities.first) do |a|
      a.pay_mana(generic: { colorless: 3 })
      a.targeting(creature)
    end
    game.stack.resolve!
    game.tick!
  end

  def add_to_graveyard(*names)
    names.each { p1.graveyard.add(Card(_1)) }
    game.tick!
  end

  def attack_and_deal_damage(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
    go_to_combat_damage!
    game.settle!
  end

  it "is a legendary {2} Equipment with equip {3}" do
    expect(glamdring.card).to be_a(Magic::Cards::Equipment)
    expect(glamdring.legendary?).to be true
    expect(glamdring.card.mana_value).to eq(2)
    ability = glamdring.activated_abilities.first
    expect(ability.costs.size).to eq(1)
    expect(ability.costs.first.cost[:generic]).to eq(3)
  end

  it "can only be equipped at sorcery speed" do
    go_to_main_phase_for!(p2)
    p1.add_mana(colorless: 3)

    expect do
      p1.activate_ability(ability: glamdring.activated_abilities.first) do |a|
        a.pay_mana(generic: { colorless: 3 })
        a.targeting(bears)
      end
    end.to raise_error(Magic::IllegalAction, /requirements to activate/)
  end

  describe "equipped creature" do
    it "has first strike and +1/+0 per instant and sorcery card in your graveyard, and others do not" do
      add_to_graveyard("Shock", "Mind Rot", "Grizzly Bears")
      equip(bears)

      expect(bears).to have_keyword(:first_strike)
      expect([bears.power, bears.toughness]).to eq([4, 2])
      expect(other).not_to have_keyword(:first_strike)
      expect([other.power, other.toughness]).to eq([2, 2])
    end

    it "does not count the opponent's graveyard" do
      p2.graveyard.add(Card("Shock", owner: p2))
      equip(bears)
      game.tick!

      expect(bears.power).to eq(2)
    end

    it "loses first strike and the bonus when Glamdring leaves the battlefield" do
      add_to_graveyard("Shock")
      equip(bears)
      glamdring.destroy!
      game.settle!
      game.tick!

      expect(bears).not_to have_keyword(:first_strike)
      expect(bears.power).to eq(2)
    end
  end

  describe "when equipped creature deals combat damage to a player" do
    let!(:shock) { Card("Shock").tap { p1.hand.add(_1) } }
    let!(:mind_rot) { Card("Mind Rot").tap { p1.hand.add(_1) } }
    let!(:bear_card) { Card("Grizzly Bears").tap { p1.hand.add(_1) } }

    before { equip(bears) }

    it "lets you cast an instant with mana value at most the damage for free" do
      attack_and_deal_damage(bears)

      expect(p2.life).to eq(18)
      expect(game.choices.first).to be_a(Magic::Cards::Glamdring::MayCast)
      game.resolve_choice!
      # Shock is the only legal card (Mind Rot costs 3), so it is picked for you and asks for its target.
      expect(game.choices.first.choices).to include(p2)
      game.resolve_choice!(target: p2)
      game.stack.resolve!

      expect(p2.life).to eq(16)
      expect(p1.hand.cards).not_to include(shock)
      expect(p1.graveyard.cards).to include(shock)
      expect(p1.hand.cards).to include(mind_rot, bear_card)
    end

    it "does nothing when the may choice is declined" do
      attack_and_deal_damage(bears)
      game.skip_choice!

      expect(game.choices).to be_empty
      expect(p1.hand.cards).to include(shock)
      expect(p2.life).to eq(18)
    end

    it "skips the card pick when declined" do
      attack_and_deal_damage(bears)
      game.resolve_choice!
      game.skip_choice!

      expect(game.choices).to be_empty
      expect(p1.hand.cards).to include(shock)
    end

    it "offers a higher mana value sorcery when the damage is large enough" do
      add_to_graveyard("Shock", "Shock", "Mind Rot")
      attack_and_deal_damage(bears)
      game.resolve_choice!

      expect(game.choices.first.choices).to contain_exactly(shock, mind_rot)
    end

    it "does not trigger when an unequipped creature deals combat damage" do
      attack_and_deal_damage(other)

      expect(game.choices).to be_empty
      expect(p2.life).to eq(18)
    end

    it "does not trigger when the damage is dealt to a creature" do
      blocker = ResolvePermanent("Grizzly Bears", owner: p2)
      skip_to_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: bears, target: p2)
      current_turn.attackers_declared!
      current_turn.declare_blocker(blocker, attacker: bears)
      game.settle!
      go_to_combat_damage!
      game.settle!

      expect(game.choices).to be_empty
    end

    it "still lets you cast if Glamdring left before the trigger resolved" do
      skip_to_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: bears, target: p2)
      current_turn.attackers_declared!
      game.settle!
      go_to_combat_damage!
      glamdring.destroy!
      game.settle!

      expect(game.choices.first).to be_a(Magic::Cards::Glamdring::MayCast)
    end
  end

  it "offers nothing when no instant or sorcery in hand fits" do
    Card("Mind Rot").tap { p1.hand.add(_1) }
    equip(bears)
    attack_and_deal_damage(bears)

    expect(game.choices).to be_empty
  end
end
