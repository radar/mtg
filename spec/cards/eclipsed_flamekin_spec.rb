# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EclipsedFlamekin do
  include_context "two player game"

  def p1_library
    [
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      # End initial card draw
      Card("Plains"),
      Card("Island"),
      Card("Swamp"),
      Card("Mountain"),
      Card("Forest"),
    ]
  end

  let!(:creature) { ResolvePermanent("Eclipsed Flamekin", owner: p1) }
  let(:choice) { game.choices.last }

  it "is a 1/4 Elemental Scout" do
    expect(creature.power).to eq(1)
    expect(creature.toughness).to eq(4)
    expect(creature.type?("Elemental")).to eq(true)
    expect(creature.type?("Scout")).to eq(true)
  end

  it "looks at the top four cards and offers only Island, Mountain cards" do
    expect(choice).to be_a(Magic::Choice::LookAtTopCards)
    expect(choice.looked_at.map(&:name)).to eq(%w[Plains Island Swamp Mountain])
    expect(choice.choices.map(&:name)).to eq(%w[Island Mountain])
  end

  it "puts the chosen card into your hand and the rest on the bottom of the library" do
    picked = choice.choices.first
    expect { game.resolve_choice!(target: picked) }.to change { p1.hand.count }.by(1)

    expect(p1.hand.cards).to include(picked)
    expect(p1.library.count).to eq(4)
    expect(p1.library.first.name).to eq("Forest")
    expect(p1.library.last(3).map(&:name)).to contain_exactly("Plains", "Swamp", "Mountain")
  end

  it "may take no card, putting all four on the bottom" do
    expect { game.resolve_choice!(target: nil) }.not_to(change { p1.hand.count })
    expect(p1.library.count).to eq(5)
    expect(p1.library.last(4).map(&:name)).to contain_exactly("Plains", "Island", "Swamp", "Mountain")
  end
end
