# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OkoLorwynLiege do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:oko) { ResolvePermanent("Oko, Lorwyn Liege", owner: p1) }

  def first_main_phase!
    game.notify!(Magic::Events::FirstMainPhase.new(active_player: p1))
    game.settle!
  end

  def activate(index, **targets)
    p1.activate_loyalty_ability(ability: oko.loyalty_abilities[index]) { |action| action.targeting(targets[:target]) if targets[:target] }
    game.stack.resolve!
    game.settle!
  end

  it "is a legendary Oko planeswalker with 3 loyalty and a back face" do
    expect(oko.loyalty).to eq(3)
    expect(oko).to be_planeswalker
    expect(oko.card).to be_double_faced
  end

  describe "+2: up to one target creature gains all creature types" do
    it "gives the creature every creature type, permanently" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      activate(0, target: bears)

      expect(oko.loyalty).to eq(5)
      expect(bears.type?("Elf")).to be(true)
      expect(bears.type?("Goblin")).to be(true)
      game.next_turn
      go_to_main_phase!
      expect(bears.type?("Merfolk")).to be(true)
    end

    it "may be activated with no target" do
      activate(0)

      expect(oko.loyalty).to eq(5)
    end
  end

  describe "+1: target creature gets -2/-0 until your next turn" do
    it "shrinks the creature until your next turn begins" do
      courser = ResolvePermanent("Courser Of Kruphix", owner: p2)
      activate(1, target: courser)
      game.tick!

      expect([courser.power, courser.toughness]).to eq([0, 4])
      game.next_turn # the opponent's turn
      go_to_main_phase!
      game.tick!
      expect(courser.power).to eq(0)

      game.next_turn # your turn
      go_to_main_phase!
      game.tick!
      expect(courser.power).to eq(2)
    end
  end

  describe "transforming" do
    it "may pay {G} at the beginning of your first main phase to transform into Oko, Shadowmoor Scion" do
      oko
      p1.add_mana(green: 1)
      first_main_phase!
      game.resolve_choice!(payment: nil)

      expect(oko.transformed?).to be(true)
      expect(oko.name).to eq("Oko, Shadowmoor Scion")
      expect(oko.colors).to eq([:green])
      expect(oko.mana_value).to eq(3)
      expect(oko.loyalty).to eq(3) # loyalty counters carry over
    end
  end

  describe "Oko, Shadowmoor Scion" do
    before do
      oko.transform!
      game.settle!
    end

    def activate_back(index)
      ability = oko.loyalty_abilities[index]
      p1.activate_loyalty_ability(ability:)
      game.stack.resolve!
    end

    it "-1: mills three cards, and you may put a permanent card from among them into your hand" do
      3.times { p1.library.add(Card("Forest")) }
      activate_back(0)
      forest = p1.graveyard.cards.find { _1.name == "Forest" }
      choice = game.choices.last
      game.resolve_choice!(target: forest)

      expect(choice).to be_a(Magic::Choice::ReturnFromAmong)
      expect(forest.zone).to be_hand
      expect(oko.loyalty).to eq(2)
    end

    it "-3: creates two 3/3 green Elk tokens" do
      oko.change_loyalty!(3)
      activate_back(1)
      elks = p1.creatures.select { _1.name == "Elk" }

      expect(elks.size).to eq(2)
      expect(elks.map { [_1.power, _1.toughness, _1.colors] }).to all(eq([3, 3, [:green]]))
    end

    it "-6: gets an emblem giving creatures of the chosen type +3/+3, vigilance and hexproof" do
      oko.change_loyalty!(6)
      elf = ResolvePermanent("Skyway Sniper", owner: p1)
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      theirs = ResolvePermanent("Skyway Sniper", owner: p2)
      activate_back(2)
      game.resolve_choice!(creature_type: "Elf")
      game.tick!

      expect([elf.power, elf.toughness]).to eq([elf.card.class::POWER + 3, elf.card.class::TOUGHNESS + 3])
      expect(elf).to be_vigilant
      expect(elf).to be_hexproof
      expect(bears.power).to eq(2)
      expect(theirs.power).to eq(theirs.card.class::POWER)
    end

    it "may pay {U} to transform back" do
      p1.add_mana(blue: 1)
      first_main_phase!
      game.resolve_choice!(payment: nil)

      expect(oko.transformed?).to be(false)
      expect(oko.name).to eq("Oko, Lorwyn Liege")
    end
  end
end
