# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EclipsedBoggart do
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
      Card("Island"),
      Card("Swamp"),
      Card("Plains"),
      Card("Mountain"),
      Card("Forest"),
    ]
  end

  let!(:boggart) { ResolvePermanent("Eclipsed Boggart", owner: p1) }
  let(:choice) { game.choices.last }

  it "is a 2/3 Goblin Scout" do
    expect(boggart.power).to eq(2)
    expect(boggart.toughness).to eq(3)
    expect(boggart.type?("Goblin")).to eq(true)
    expect(boggart.type?("Scout")).to eq(true)
  end

  it "looks at the top four cards and offers only Goblin, Swamp and Mountain cards" do
    expect(choice).to be_a(Magic::Choice::LookAtTopCards)
    expect(choice.looked_at.map(&:name)).to eq(%w[Island Swamp Plains Mountain])
    expect(choice.choices.map(&:name)).to eq(%w[Swamp Mountain])
  end

  it "puts the chosen card into your hand and the rest on the bottom of the library" do
    swamp = choice.choices.first
    expect { game.resolve_choice!(target: swamp) }.to change { p1.hand.count }.by(1)

    expect(p1.hand.cards).to include(swamp)
    expect(p1.library.count).to eq(4)
    expect(p1.library.first.name).to eq("Forest")
    expect(p1.library.last(3).map(&:name)).to contain_exactly("Island", "Plains", "Mountain")
  end

  it "may take no card, putting all four on the bottom" do
    expect { game.resolve_choice!(target: nil) }.not_to(change { p1.hand.count })
    expect(p1.library.count).to eq(5)
    expect(p1.library.last(4).map(&:name)).to contain_exactly("Island", "Swamp", "Plains", "Mountain")
  end

  it "rejects a card that isn't a valid choice" do
    expect { choice.resolve!(target: choice.looked_at.find { _1.name == "Island" }) }.to raise_error(ArgumentError)
  end
end
