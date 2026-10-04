# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HaraldKingOfSkemfar do
  include_context "two player game"

  def p1_library
    [
      *Array.new(7) { Card("Forest") },
      # End initial card draw
      Card("Grizzly Bears"),
      Card("Elvish Warmaster"),
      Card("Morcant's Loyalist"),
      Card("Island"),
      Card("Plains"),
      Card("Swamp"),
    ]
  end

  let!(:creature) { ResolvePermanent("Harald, King Of Skemfar", owner: p1) }
  let(:choice) { game.choices.last }

  it "is a 3/2 Elf Warrior with menace" do
    expect(creature.power).to eq(3)
    expect(creature.toughness).to eq(2)
    expect(creature.type?("Elf")).to eq(true)
    expect(creature.type?("Warrior")).to eq(true)
    expect(creature.menace?).to eq(true)
  end

  it "looks at the top five cards and offers only Elf, Warrior or Tyvar cards" do
    expect(choice.looked_at.map(&:name)).to eq(["Grizzly Bears", "Elvish Warmaster", "Morcant's Loyalist", "Island", "Plains"])
    expect(choice.choices.map(&:name)).to eq(["Elvish Warmaster", "Morcant's Loyalist"])
  end

  it "puts the chosen card into hand and the rest on the bottom of the library" do
    picked = choice.choices.last
    expect { game.resolve_choice!(target: picked) }.to change { p1.hand.count }.by(1)

    expect(p1.hand.cards).to include(picked)
    expect(p1.library.first.name).to eq("Swamp")
    expect(p1.library.last(4).map(&:name)).to contain_exactly("Grizzly Bears", "Elvish Warmaster", "Island", "Plains")
  end

  it "may take no card" do
    expect { game.resolve_choice!(target: nil) }.not_to(change { p1.hand.count })
    expect(p1.library.last(5).map(&:name)).to contain_exactly("Grizzly Bears", "Elvish Warmaster", "Morcant's Loyalist", "Island", "Plains")
  end
end
