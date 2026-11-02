# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::QuickbeamUpstartEnt do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:elves) { ResolvePermanent("Wood Elves", owner: p1) }
  let!(:enemy) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def stats(creature) = [creature.power, creature.toughness]

  it "is a legendary 5/6 Treefolk" do
    quickbeam = ResolvePermanent("Quickbeam Upstart Ent", owner: p1)
    game.skip_choice!

    expect(stats(quickbeam)).to eq([5, 6])
    expect(quickbeam.type?("Treefolk")).to be(true)
  end

  describe "when Quickbeam enters" do
    let!(:quickbeam) do
      ResolvePermanent("Quickbeam Upstart Ent", owner: p1)
    end

    it "gives up to two target creatures +2/+2 and trample" do
      game.resolve_choice!(targets: [bears, enemy])
      game.tick!

      expect(stats(bears)).to eq([4, 4])
      expect(stats(enemy)).to eq([4, 4])
      expect([bears, enemy]).to all(have_keyword(:trample))
      expect(stats(elves)).to eq([elves.base_power, elves.base_toughness])
      expect(elves).not_to have_keyword(:trample)
    end

    it "can target Quickbeam himself" do
      game.resolve_choice!(targets: [quickbeam])
      game.tick!

      expect(stats(quickbeam)).to eq([7, 8])
      expect(quickbeam).to have_keyword(:trample)
    end

    it "may target just one creature" do
      game.resolve_choice!(targets: [bears])
      game.tick!

      expect(stats(bears)).to eq([4, 4])
      expect(stats(enemy)).to eq([2, 2])
    end

    it "may target no creatures" do
      game.skip_choice!
      game.tick!

      expect(stats(bears)).to eq([2, 2])
      expect(bears).not_to have_keyword(:trample)
      expect(game.choices).to be_empty
    end

    it "rejects a third target" do
      expect { game.resolve_choice!(targets: [bears, enemy, elves]) }.to raise_error(ArgumentError)
      expect(stats(elves)).not_to eq([4, 4])
    end

    it "lasts until end of turn" do
      game.resolve_choice!(targets: [bears])
      game.tick!
      current_turn.end!
      current_turn.cleanup!
      game.tick!

      expect(stats(bears)).to eq([2, 2])
      expect(bears).not_to have_keyword(:trample)
    end
  end

  context "with Quickbeam already on the battlefield" do
    before do
      ResolvePermanent("Quickbeam Upstart Ent", owner: p1)
      game.skip_choice!
    end

    it "triggers when another Treefolk you control enters" do
      ResolvePermanent("Gnarled Sage", owner: p1)

      expect(game.choices.first.choices).to include(bears, elves, enemy)
      game.resolve_choice!(targets: [bears])
      game.tick!

      expect(stats(bears)).to eq([4, 4])
    end

    it "does not trigger for a non-Treefolk entering" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      expect(game.choices).to be_empty
    end

    it "does not trigger for an opponent's Treefolk" do
      ResolvePermanent("Gnarled Sage", owner: p2)
      expect(game.choices).to be_empty
    end

    it "does not offer a hexproof creature" do
      p2.add_mana(blue: 1)
      p2.cast(card: Card("Dive Down", owner: p2)) { |a| a.pay_mana(blue: 1).targeting(enemy) }
      game.stack.resolve!
      game.tick!
      expect(enemy).to be_hexproof

      ResolvePermanent("Gnarled Sage", owner: p1)

      expect(game.choices.first.choices).not_to include(enemy)
      expect(game.choices.first.choices).to include(bears)
    end
  end
end
