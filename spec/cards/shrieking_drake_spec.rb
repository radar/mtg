# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShriekingDrake do
  include_context "two player game"

  let(:card) { Card("Shrieking Drake", owner: p1) }

  def cast_drake
    go_to_main_phase!
    p1.hand.add(card)
    p1.add_mana(blue: 1)
    p1.cast(card:) { |a| a.pay_mana(blue: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 1/1 flyer" do
    drake = ResolvePermanent("Shrieking Drake", owner: p1)
    expect([drake.power, drake.toughness]).to eq([1, 1])
    expect(drake.flying?).to eq(true)
  end

  it "returns itself to hand when it is the only creature you control" do
    cast_drake
    expect(card.zone).to eq(p1.hand)
    expect(p1.creatures).to be_empty
  end

  it "lets you return another creature you control instead" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_drake
    expect(game.choices.last.choices).to contain_exactly(bear, p1.creatures.find { _1.name == "Shrieking Drake" })
    game.resolve_choice!(target: bear)
    expect(bear.card.zone).to eq(p1.hand)
    expect(p1.creatures.map(&:name)).to eq(["Shrieking Drake"])
  end

  it "does not offer an opponent's creature" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_drake
    expect(game.choices.last.choices).not_to include(theirs)
    expect(game.choices.last.choices).to include(mine)
  end

  it "returns the Drake when the choice is skipped" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    cast_drake
    game.skip_choice!
    expect(card.zone).to eq(p1.hand)
    expect(p1.creatures.map(&:name)).to eq(["Grizzly Bears"])
  end

  context "when the Drake leaves the battlefield before its trigger resolves" do
    def cast_drake_and_kill_it
      go_to_main_phase!
      p1.hand.add(card)
      p1.add_mana(blue: 1)
      p1.cast(card:) { |a| a.pay_mana(blue: 1) }
      game.stack.resolve!
      p1.creatures.find { _1.name == "Shrieking Drake" }.destroy!
    end

    it "does not return it from the graveyard when nothing else is controlled" do
      bear = ResolvePermanent("Grizzly Bears", owner: p1)
      cast_drake_and_kill_it
      bear.destroy!
      game.settle!
      hand_names = p1.hand.cards.map(&:name)
      game.skip_choice!
      expect(p1.graveyard.cards.map(&:name)).to contain_exactly("Shrieking Drake", "Grizzly Bears")
      expect(p1.hand.cards.map(&:name)).to eq(hand_names)
    end

    it "returns another creature instead of the dead Drake" do
      bears = 2.times.map { ResolvePermanent("Grizzly Bears", owner: p1) }
      cast_drake_and_kill_it
      game.settle!
      expect(game.choices).not_to be_empty
      expect(game.choices.last.choices).to contain_exactly(*bears)
      game.skip_choice!
      expect(p1.graveyard.cards.map(&:name)).to eq(["Shrieking Drake"])
      expect(p1.hand.cards.map(&:name).count("Grizzly Bears")).to eq(1)
      expect(p1.hand.cards.map(&:name)).not_to include("Shrieking Drake")
    end
  end
end
