# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MidnightTilling do
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
      Card("Opt"),
      Card("Grizzly Bears"),
      Card("Shock"),
      Card("Island"),
      Card("Swamp"),
    ]
  end

  let(:tilling) { Card("Midnight Tilling") }
  let(:choice) { game.choices.last }

  before do
    p1.add_mana(green: 2)
    p1.cast(card: tilling) { _1.pay_mana(generic: { green: 1 }, green: 1) }
    game.stack.resolve!
  end

  it "mills four cards" do
    expect(p1.library.count).to eq(1)
    expect(p1.graveyard.map(&:name)).to include("Opt", "Grizzly Bears", "Shock", "Island", "Midnight Tilling")
  end

  it "offers only the permanent cards among the milled ones" do
    expect(choice).to be_a(Magic::Choice::ReturnFromAmong)
    expect(choice.choices.map(&:name)).to contain_exactly("Grizzly Bears", "Island")
  end

  it "returns the chosen permanent card to your hand" do
    bears = choice.choices.find { _1.name == "Grizzly Bears" }
    game.resolve_choice!(target: bears)

    expect(p1.hand.cards).to include(bears)
    expect(p1.graveyard.cards).not_to include(bears)
  end

  it "may return nothing" do
    expect { game.resolve_choice!(target: nil) }.not_to(change { p1.hand.count })
  end

  it "can't return a card that wasn't milled by it" do
    outside = Card("Grizzly Bears")
    expect { choice.resolve!(target: outside) }.to raise_error(ArgumentError)
  end
end
