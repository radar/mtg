# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RuthlessWinnower do
  include_context "two player game"

  let!(:ruthless_winnower) { ResolvePermanent("Ruthless Winnower", owner: p2) }

  it "is a 4/4 Elf Rogue" do
    expect(ruthless_winnower.power).to eq(4)
    expect(ruthless_winnower.toughness).to eq(4)
    expect(ruthless_winnower.type?("Elf")).to be true
    expect(ruthless_winnower.type?("Rogue")).to be true
  end

  context "at the beginning of a player's upkeep" do
    let!(:grizzly_bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "offers that player a choice to sacrifice one of their non-Elf creatures" do
      game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))
      game.settle!

      choice = game.choices.last
      expect(choice).to be_a(described_class::SacrificeChoice)
      expect(choice.choices).to eq([grizzly_bears])

      game.resolve_choice!(target: grizzly_bears)

      expect(p1.permanents).not_to include(grizzly_bears)
    end

    it "also triggers on the opponent's upkeep" do
      opponent_bears = ResolvePermanent("Grizzly Bears", owner: p2)

      game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p2))
      game.settle!

      choice = game.choices.last
      expect(choice.choices).to eq([opponent_bears])

      game.resolve_choice!(target: opponent_bears)

      expect(p2.permanents).not_to include(opponent_bears)
      expect(p2.permanents).to include(ruthless_winnower)
    end

    it "does not offer a choice if the player controls only Elves" do
      llanowar_elves = ResolvePermanent("Llanowar Elves", owner: p2)
      grizzly_bears.sacrifice!

      expect { game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p2))
      game.settle! }
        .not_to change { game.choices.count }

      expect(p2.permanents).to include(ruthless_winnower, llanowar_elves)
    end
  end
end
