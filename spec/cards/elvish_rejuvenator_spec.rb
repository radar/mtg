# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ElvishRejuvenator do
  include_context "two player game"

  def p1_library
    [
      *Array.new(7) { Card("Island") },
      # End initial card draw
      Card("Grizzly Bears"),
      Card("Forest"),
      Card("Swamp"),
      Card("Elvish Warmaster"),
      Card("Plains"),
      Card("Mountain"),
    ]
  end

  let!(:creature) { ResolvePermanent("Elvish Rejuvenator", owner: p1) }
  let(:choice) { game.choices.last }

  it "is a 1/1 Elf Druid" do
    expect(creature.power).to eq(1)
    expect(creature.toughness).to eq(1)
    expect(creature.type?("Elf")).to eq(true)
    expect(creature.type?("Druid")).to eq(true)
  end

  it "looks at the top five and offers only lands" do
    expect(choice.looked_at.map(&:name)).to eq(%w[Grizzly\ Bears Forest Swamp Elvish\ Warmaster Plains])
    expect(choice.choices.map(&:name)).to eq(%w[Forest Swamp Plains])
  end

  it "puts the chosen land onto the battlefield tapped and the rest on the bottom" do
    forest = choice.choices.first
    game.resolve_choice!(target: forest)

    permanent = p1.permanents.by_name("Forest").first
    expect(permanent).to be_tapped
    expect(p1.library.first.name).to eq("Mountain")
    expect(p1.library.count).to eq(5)
    expect(p1.library.last(4).map(&:name)).to contain_exactly("Grizzly Bears", "Swamp", "Elvish Warmaster", "Plains")
  end

  it "may take no land" do
    game.resolve_choice!(target: nil)

    expect(p1.permanents.lands).to be_empty
    expect(p1.library.count).to eq(6)
    expect(p1.library.last(5).map(&:name)).to contain_exactly("Grizzly Bears", "Forest", "Swamp", "Elvish Warmaster", "Plains")
  end
end
