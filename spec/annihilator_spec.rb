# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Annihilator" do
  include_context "two player game"

  let(:annihilator_class) do
    Class.new(Magic::Cards::Creature) do
      const_set(:NAME, "Test Annihilator")
      creature_type "Eldrazi"
      power 5
      toughness 5
      keywords Magic::Cards::Keywords::Annihilator.new(2)
    end
  end

  let!(:attacker) do
    card = annihilator_class.new(game:, owner: p1)
    Magic::Permanent.put_onto_battlefield(game: game, card: card, controller: p1).tap { _1.controlled_since_turn = 0 }
  end
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def attack(creature, target: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: creature, target: target)
    current_turn.attackers_declared!
    game.settle!
    game.tick!
  end

  def theirs = p2.permanents.map(&:name)

  it "is a keyword with an amount" do
    expect(attacker.keywords.grep(Magic::Cards::Keywords::Annihilator).map(&:amount)).to eq([2])
  end

  context "when defending player controls more permanents than N" do
    before do
      ResolvePermanent("Grizzly Bears", owner: p2)
      ResolvePermanent("Serra Angel", owner: p2)
      ResolvePermanent("Island", owner: p2)
    end

    it "makes them sacrifice exactly N permanents of their choice" do
      attack(attacker)
      expect(game.choices.size).to eq(1)
      expect(game.choices.first.chooser).to eq(p2)

      island = p2.permanents.find { _1.name == "Island" }
      angel = p2.permanents.find { _1.name == "Serra Angel" }
      game.resolve_choice!(sacrifices: [island, angel])
      game.settle!

      expect(theirs).to eq(["Grizzly Bears"])
    end

    it "rejects the wrong number of permanents or another player's permanents" do
      attack(attacker)
      expect { game.resolve_choice!(sacrifices: [p2.permanents.first]) }.to raise_error(ArgumentError)
      expect { game.resolve_choice!(sacrifices: [bears, p2.permanents.first]) }.to raise_error(ArgumentError)
    end

    it "sacrifices the first N when the choice is skipped" do
      attack(attacker)
      game.skip_choice!
      game.settle!

      expect(p2.permanents.size).to eq(1)
    end
  end

  it "sacrifices everything without asking when they control N or fewer" do
    ResolvePermanent("Island", owner: p2)
    attack(attacker)

    expect(game.choices).to be_empty
    expect(p2.permanents).to be_empty
  end

  it "does not trigger when another creature attacks" do
    ResolvePermanent("Island", owner: p2)
    attack(bears)

    expect(theirs).to eq(["Island"])
  end
end
