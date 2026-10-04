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
