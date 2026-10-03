# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KioraTheRisingTide do
  include_context "two player game"
  before { go_to_main_phase! }

  def scions(player = p1) = player.creatures.select { _1.name == "Scion of the Deep" }

  def fill_graveyard(count)
    count.times { p1.graveyard.add(Card("Island", owner: p1)) }
  end

  def attack!(kiora)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(kiora, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 3/2 legendary Merfolk Noble" do
    kiora = ResolvePermanent("Kiora, The Rising Tide", owner: p1)

    expect([kiora.power, kiora.toughness]).to eq([3, 2])
    expect(kiora.type?("Legendary")).to eq(true)
  end

  it "draws two cards then discards two when it enters" do
    hand_before = p1.hand.count
    ResolvePermanent("Kiora, The Rising Tide", owner: p1)
    expect(game.choices.size).to eq(2)
    expect(p1.hand.count).to eq(hand_before + 2)

    2.times { game.resolve_choice!(card: p1.hand.cards.first) }

    expect(p1.hand.count).to eq(hand_before)
  end

  describe "threshold attack trigger" do
    let!(:kiora) { ResolvePermanent("Kiora, The Rising Tide", owner: p1) }

    before { 2.times { game.skip_choice! } }

    it "may create Scion of the Deep, a legendary 8/8 blue Octopus, with seven cards in your graveyard" do
      fill_graveyard(7)
      attack!(kiora)
      game.resolve_choice!

      expect(scions.size).to eq(1)
      scion = scions.first
      expect([scion.power, scion.toughness]).to eq([8, 8])
      expect(scion.colors).to eq([:blue])
      expect(scion.type?("Legendary")).to eq(true)
      expect(scion.type?("Octopus")).to eq(true)
      expect(scion.token?).to eq(true)
    end

    it "creates nothing if you decline" do
      fill_graveyard(7)
      attack!(kiora)
      game.skip_choice!

      expect(scions).to be_empty
    end

    it "does not trigger with six cards in your graveyard" do
      fill_graveyard(6)
      attack!(kiora)

      expect(game.choices).to be_empty
      expect(scions).to be_empty
    end

    it "counts your graveyard only, not the opponent's" do
      fill_graveyard(3)
      7.times { p2.graveyard.add(Card("Island", owner: p2)) }
      attack!(kiora)

      expect(game.choices).to be_empty
    end
  end
end
