# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TobyBeastieBefriender do
  include_context "two player game"

  let!(:toby) { ResolvePermanent("Toby Beastie Befriender", owner: p1) }

  def beasts(player) = player.creatures.select { _1.type?("Beast") }

  def attack_with(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { current_turn.declare_attacker(_1, target: p2) }
    current_turn.attackers_declared!
  end

  it "is a legendary 1/1 Human Wizard" do
    expect([toby.power, toby.toughness]).to eq([1, 1])
    expect(toby.card).to be_legendary
  end

  it "creates a 4/4 white Beast token when it enters" do
    expect(beasts(p1).size).to eq(1)
    beast = beasts(p1).first
    expect([beast.power, beast.toughness]).to eq([4, 4])
    expect(beast.colors).to eq([:white])
    expect(beast).to be_token
  end

  describe "the Beast" do
    let(:beast) { beasts(p1).first }

    it "can't attack alone" do
      expect { attack_with(beast) }.to raise_error(Magic::Game::CombatPhase::IllegalAttack, /can't attack alone/)
    end

    it "can attack with another creature" do
      attack_with(beast, toby)

      expect(current_turn.attacks.map(&:attacker)).to contain_exactly(beast, toby)
    end

    it "can't block alone" do
      ResolvePermanent("Toby Beastie Befriender", owner: p2)
      their_beast = beasts(p2).first
      attack_with(toby)
      current_turn.declare_blocker(their_beast, attacker: toby)

      expect { current_turn.combat_damage! }.to raise_error(Magic::Game::CombatPhase::IllegalBlock, /can't block alone/)
    end

    it "can block together with another creature" do
      ResolvePermanent("Toby Beastie Befriender", owner: p2)
      their_beast = beasts(p2).first
      friend = ResolvePermanent("Grizzly Bears", owner: p2)
      attack_with(beast, toby)
      current_turn.declare_blocker(their_beast, attacker: toby)
      current_turn.declare_blocker(friend, attacker: beast)

      expect { current_turn.combat_damage! }.not_to raise_error
    end
  end

  describe "four creature tokens" do
    it "gives creature tokens you control flying" do
      beast = beasts(p1).first
      expect(beast).not_to be_flying

      3.times { toby.trigger_effect(:create_token, token_class: described_class::BeastToken) }
      game.tick!

      expect(beast).to be_flying
      expect(toby).not_to be_flying
    end

    it "doesn't give flying to an opponent's tokens" do
      4.times { toby.trigger_effect(:create_token, token_class: described_class::BeastToken) }
      theirs = Magic::Cards::MidnightMayhem::GremlinToken.new(game: game, owner: p2).resolve!
      game.tick!

      expect(theirs).not_to be_flying
    end
  end
end
