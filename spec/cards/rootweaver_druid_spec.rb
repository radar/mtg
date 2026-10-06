# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RootweaverDruid do
  include_context "two player game"

  def p2_library
    [
      *Array.new(7) { Card("Grizzly Bears") },
      Card("Forest"),
      Card("Swamp"),
      Card("Island"),
      Card("Mountain"),
      Card("Grizzly Bears"),
    ]
  end

  let!(:druid) { ResolvePermanent("Rootweaver Druid", owner: p1) }
  let(:choice) { game.choices.last }

  it "is a 2/1 Elf Druid" do
    expect(druid.power).to eq(2)
    expect(druid.toughness).to eq(1)
    expect(druid.type?("Druid")).to be true
  end

  it "lets the opponent pick up to three basic lands, one for you and the rest for them" do
    forest, swamp, island = p2.library.select { _1.name.match?(/Forest|Swamp|Island/) }
    game.resolve_choice!(targets: [forest, swamp, island], for_you: swamp)

    expect(p1.permanents.lands.map(&:name)).to eq(["Swamp"])
    expect(p2.permanents.lands.map(&:name)).to contain_exactly("Forest", "Island")
    expect(p1.permanents.lands + p2.permanents.lands).to all(be_tapped)
  end

  context "when the opponent finds several lands without saying which one is for you" do
    let(:lands) { p2.library.select { _1.name.match?(/Forest|Swamp|Island/) } }
    let(:swamp) { lands.find { _1.name == "Swamp" } }

    before { game.resolve_choice!(targets: lands) }

    it "asks the opponent which one goes under your control, before any land is put onto the battlefield" do
      expect(choice).to be_a(Magic::Cards::RootweaverDruid::GiveChoice)
      expect(choice.controller).to eq(p2)
      expect(choice.choices).to match_array(lands)
      expect(choice.prompt).to include("under #{p1.name}'s control")
      expect(p1.permanents.lands + p2.permanents.lands).to be_empty
    end

    it "puts the one they pick under your control and the rest under theirs, all tapped" do
      game.resolve_choice!(target: swamp)

      expect(p1.permanents.lands.map(&:name)).to eq(["Swamp"])
      expect(p2.permanents.lands.map(&:name)).to contain_exactly("Forest", "Island")
      expect(p1.permanents.lands + p2.permanents.lands).to all(be_tapped)
    end

    it "does not offer a land that wasn't found" do
      other = Card("Mountain", owner: p2)

      expect { choice.resolve!(target: other) }.to raise_error(ArgumentError)
    end
  end

  it "puts a single land found under your control without asking" do
    forest = p2.library.find { _1.name == "Forest" }
    game.resolve_choice!(targets: [forest])

    expect(game.choices).to be_empty
    expect(p1.permanents.lands.map(&:name)).to eq(["Forest"])
    expect(p2.permanents.lands).to be_empty
  end

  it "prompts to search for up to three basic lands" do
    expect(choice.prompt).to include("up to three basic land cards")
  end

  it "lets the opponent search for nothing" do
    game.skip_choice!

    expect(p1.permanents.lands).to be_empty
    expect(p2.permanents.lands).to be_empty
  end

  it "rejects more than three cards" do
    lands = p2.library.select(&:basic_land?)
    expect { choice.resolve!(targets: lands + lands) }.to raise_error(ArgumentError)
  end
end
