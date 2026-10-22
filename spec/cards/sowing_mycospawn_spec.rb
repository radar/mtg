# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SowingMycospawn do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spawn_card) { Card("Sowing Mycospawn", owner: p1) }
  let!(:forest) { Card("Forest", owner: p1) }
  let!(:bolt) { Card("Lightning Bolt", owner: p1) }
  let!(:opp_island) { ResolvePermanent("Island", owner: p2) }

  def cast_mycospawn(kicked:)
    p1.library.add(bolt)
    p1.library.add(forest)
    p1.hand.add(spawn_card)
    p1.add_mana(green: 1, colorless: 5)
    action = cast_action(card: spawn_card, player: p1)
    action.pay_mana(green: 1, generic: { colorless: 3 })
    action.pay_kicker(generic: { colorless: 1 }, colorless: 1) if kicked
    game.take_action(action)
    game.settle!
  end

  it "is a devoid 3/3 Eldrazi Fungus" do
    permanent = ResolvePermanent("Sowing Mycospawn", owner: p1)

    expect(spawn_card.colors).to be_empty
    expect([permanent.power, permanent.toughness]).to eq([3, 3])
  end

  it "searches for a land and puts it onto the battlefield when cast" do
    cast_mycospawn(kicked: false)
    choice = game.choices.last

    expect(choice).to be_a(Magic::Choice::SearchLibrary)
    expect(choice.choices).to include(forest)
    expect(choice.choices).not_to include(bolt)

    game.resolve_choice!(targets: [forest])

    expect(forest.zone).to eq(game.battlefield)
  end

  it "may fail to find a land" do
    cast_mycospawn(kicked: false)
    game.skip_choice!

    expect(forest.zone).to eq(p1.library)
  end

  it "does not offer to exile a land when not kicked" do
    cast_mycospawn(kicked: false)
    game.resolve_choice!(targets: [forest])

    expect(game.choices).to be_empty
    expect(opp_island.zone).to eq(game.battlefield)
  end

  it "exiles the only land when kicked (the searched land is not yet a legal target)" do
    cast_mycospawn(kicked: true)
    game.resolve_choice!(targets: [forest])

    expect(game.exile.cards.map(&:name)).to eq(["Island"])
    expect(forest.zone).to eq(game.battlefield)
  end

  context "with several lands to choose from" do
    let!(:my_land) { ResolvePermanent("Plains", owner: p1) }

    it "lets you choose which land to exile when kicked" do
      cast_mycospawn(kicked: true)
      choice = game.choices.find { _1.is_a?(described_class::ExileLandChoice) }

      expect(choice.choices).to contain_exactly(opp_island, my_land)
      game.resolve_choice!(target: opp_island)
      game.settle!
      game.resolve_choice!(targets: [forest])

      expect(game.exile.cards.map(&:name)).to eq(["Island"])
      expect(forest.zone).to eq(game.battlefield)
      expect(my_land.zone).to eq(game.battlefield)
    end
  end
end
