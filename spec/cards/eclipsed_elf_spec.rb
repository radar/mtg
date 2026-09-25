# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EclipsedElf do
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
      Card("Forest"),
      Card("Forest"),
    ]
  end

  let!(:creature) { ResolvePermanent("Eclipsed Elf", owner: p1) }
  let(:choice) { game.choices.last }

  it "is a 3/2 Elf Scout" do
    expect(creature.power).to eq(3)
    expect(creature.toughness).to eq(2)
    expect(creature.type?("Elf")).to eq(true)
    expect(creature.type?("Scout")).to eq(true)
  end

  it "looks at the top four cards and offers only Swamp, Forest cards" do
    expect(choice).to be_a(Magic::Choice::LookAtTopCards)
    expect(choice.looked_at.map(&:name)).to eq(%w[Island Swamp Plains Forest])
    expect(choice.choices.map(&:name)).to eq(%w[Swamp Forest])
  end

  it "puts the chosen card into your hand and the rest on the bottom of the library" do
    picked = choice.choices.first
    expect { game.resolve_choice!(target: picked) }.to change { p1.hand.count }.by(1)

    expect(p1.hand.cards).to include(picked)
    expect(p1.library.count).to eq(4)
    expect(p1.library.first.name).to eq("Forest")
    expect(p1.library.last(3).map(&:name)).to contain_exactly("Island", "Plains", "Forest")
  end

  it "may take no card, putting all four on the bottom" do
    expect { game.resolve_choice!(target: nil) }.not_to(change { p1.hand.count })
    expect(p1.library.count).to eq(5)
    expect(p1.library.last(4).map(&:name)).to contain_exactly("Island", "Swamp", "Plains", "Forest")
  end
end
