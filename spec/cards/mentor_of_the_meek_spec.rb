# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MentorOfTheMeek do
  include_context "two player game"

  let!(:mentor) { ResolvePermanent("Mentor Of The Meek", owner: p1) }

  it "is a 2/2" do
    expect([mentor.power, mentor.toughness]).to eq([2, 2])
  end

  it "may pay {1} to draw when another creature with power 2 or less enters" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    expect(game.choices.last).to be_a(described_class::MayPayChoice)

    p1.add_mana(green: 1)
    expect { game.resolve_choice!(payment: { green: 1 }) }.to change { p1.hand.count }.by(1)
  end

  it "does nothing when the choice is declined" do
    ResolvePermanent("Grizzly Bears", owner: p1)

    expect { game.skip_choice! }.not_to change { p1.hand.count }
  end

  it "does not trigger for a creature with power 3 or more" do
    ResolvePermanent("Baneslayer Angel", owner: p1)

    expect(game.choices).to be_empty
  end

  it "does not trigger for an opponent's creature" do
    ResolvePermanent("Grizzly Bears", owner: p2)

    expect(game.choices).to be_empty
  end
end
