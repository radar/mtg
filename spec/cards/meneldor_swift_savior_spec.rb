# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MeneldorSwiftSavior do
  include_context "two player game"

  let!(:meneldor) { ResolvePermanent("Meneldor, Swift Savior", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def hit_player!(attacker = meneldor)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p2)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!
  end

  def choice = game.choices.first

  it "is a legendary 3/3 flying Bird Soldier" do
    expect([meneldor.power, meneldor.toughness]).to eq([3, 3])
    expect(meneldor).to be_legendary
    expect(meneldor).to have_keyword(:flying)
    expect(meneldor.type?("Bird")).to eq(true)
    expect(meneldor.type?("Soldier")).to eq(true)
  end

  context "when it deals combat damage to a player" do
    it "offers creatures you own, including itself" do
      hit_player!

      expect(choice).to be_a(described_class::FlickerChoice)
      expect(choice.choices).to contain_exactly(meneldor, bears)
    end

    it "exiles the target and returns it to the battlefield as a new permanent" do
      hit_player!
      game.resolve_choice!(target: bears)

      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
      expect(p1.creatures).not_to include(bears)
      expect(game.exile.cards).to be_empty
    end

    it "returns a creature you own under your control" do
      stolen = ResolvePermanent("Grizzly Bears", owner: p1, controller: p2)
      expect(stolen.controller).to eq(p2)
      hit_player!
      game.resolve_choice!(target: stolen)

      expect(p2.creatures.map(&:name)).not_to include("Grizzly Bears")
      expect(p1.creatures.count { _1.name == "Grizzly Bears" }).to eq(2)
    end

    it "does not offer a creature you own but an opponent controls when hexproof" do
      ResolvePermanent("Gigantic Big Bear", owner: p1, controller: p2)
      hit_player!

      expect(choice.choices).to contain_exactly(meneldor, bears)
    end

    it "does not offer creatures an opponent owns" do
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      hit_player!

      expect(choice.choices).not_to include(theirs)
    end

    it "does not bring a token back" do
      token = ResolvePermanent("Grizzly Bears", owner: p1, token: true)
      hit_player!
      game.resolve_choice!(target: token)

      expect(p1.creatures.count { _1.name == "Grizzly Bears" }).to eq(1)
      expect(p1.creatures).not_to include(token)
    end

    it "may target nothing" do
      hit_player!
      game.skip_choice!

      expect(game.choices).to be_empty
      expect(p1.creatures).to contain_exactly(meneldor, bears)
    end

    it "targets at most one creature, and may target none" do
      hit_player!

      expect([choice.target_choices.min, choice.target_choices.max]).to eq([0, 1])
    end

    it "can flicker itself" do
      hit_player!
      game.resolve_choice!(target: meneldor)

      expect(p1.creatures.map(&:name)).to include("Meneldor, Swift Savior")
      expect(p1.creatures).not_to include(meneldor)
    end
  end

  context "when it does not deal combat damage to a player" do
    it "does not trigger when it deals damage to a creature" do
      game.notify!(Magic::Events::CombatDamageDealt.new(source: meneldor, target: bears, damage: 3))
      game.settle!

      expect(game.choices).to be_empty
    end

    it "does not trigger when another creature hits the player" do
      hit_player!(bears)

      expect(game.choices).to be_empty
      expect(p1.creatures).to contain_exactly(meneldor, bears)
    end
  end
end
