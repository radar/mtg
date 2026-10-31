# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GrishnkhBrashInstigator do
  include_context "two player game"
  before { go_to_main_phase! }

  def army = p1.creatures.find { _1.type?("Army") }

  def enter_grishnakh
    ResolvePermanent("Grishnákh, Brash Instigator", owner: p1)
    game.settle!
  end

  it "is a legendary 1/1 Goblin Soldier" do
    g = ResolvePermanent("Grishnákh, Brash Instigator", owner: p1)
    expect([g.power, g.toughness]).to eq([1, 1])
    expect(g.type?("Goblin")).to eq(true)
    expect(g.type?("Soldier")).to eq(true)
    expect(g.legendary?).to eq(true)
  end

  it "amasses Orcs 2 when it enters" do
    enter_grishnakh
    expect(army.type?("Orc")).to eq(true)
    expect([army.power, army.toughness]).to eq([2, 2])
    expect(game.choices).to be_empty
  end

  context "with opposing creatures" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
    let!(:bears2) { ResolvePermanent("Grizzly Bears", owner: p2) }
    let!(:giant) { ResolvePermanent("Axegrinder Giant", owner: p2) }
    let!(:legend) { ResolvePermanent("Gríma Wormtongue", owner: p2) }
    let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "offers only nonlegendary opposing creatures with power <= the Army's power" do
      enter_grishnakh
      expect(game.choices.last.choices).to contain_exactly(bears, bears2)
    end

    it "includes a creature whose power equals the Army's power" do
      two_power = ResolvePermanent("Grizzly Bears", owner: p2)
      expect(two_power.power).to eq(2)
      enter_grishnakh
      expect(game.choices.last.choices).to include(two_power)
    end

    it "gains control, untaps and gives haste until end of turn" do
      bears.tap!
      enter_grishnakh
      game.resolve_choice!(target: bears)
      game.settle!
      expect(p1.creatures).to include(bears)
      expect(p2.creatures).not_to include(bears)
      expect(bears.tapped?).to eq(false)
      expect(bears).to be_haste
      expect(p2.creatures).to include(bears2)
    end

    it "returns the creature at end of turn" do
      enter_grishnakh
      game.resolve_choice!(target: bears)
      game.settle!
      current_turn.end!
      current_turn.cleanup!
      game.settle!
      expect(p2.creatures).to include(bears)
      expect(p1.creatures).not_to include(bears)
      expect(bears).not_to be_haste
    end

    it "uses the Army's power after counters when an Army already exists" do
      Magic::Amass.call(source: mine.card, controller: p1, amount: 1, subtype: "Orc")
      game.tick!
      enter_grishnakh
      expect(army.power).to eq(3)
      expect(p1.creatures.count { _1.type?("Army") }).to eq(1)
      expect(game.choices.last.choices).to contain_exactly(bears, bears2)
    end

    it "still steals a legal creature when the choice is skipped (target is mandatory)" do
      enter_grishnakh
      game.skip_choice!
      game.settle!
      expect(game.choices).to be_empty
      stolen = [bears, bears2].select { p1.creatures.include?(_1) }
      expect(stolen.size).to eq(1)
      expect(p2.creatures).to include(giant, legend)
      expect(p1.creatures).not_to include(giant, legend)
    end

    it "does not offer a hexproof creature" do
      p2.add_mana(blue: 1)
      p2.cast(card: Card("Dive Down", owner: p2)) { |a| a.pay_mana(blue: 1).targeting(bears) }
      game.stack.resolve!
      game.tick!
      expect(bears).to be_hexproof
      ResolvePermanent("Grizzly Bears", owner: p2)
      enter_grishnakh
      expect(game.choices.last.choices).not_to include(bears)
      expect(game.choices.last.choices).to include(bears2)
    end
  end

  it "offers no choice when no opposing creature is legal, but still amasses" do
    ResolvePermanent("Gríma Wormtongue", owner: p2)
    ResolvePermanent("Axegrinder Giant", owner: p2)
    enter_grishnakh
    expect(game.choices).to be_empty
    expect(army.power).to eq(2)
  end
end
