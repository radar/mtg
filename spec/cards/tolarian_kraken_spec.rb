# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TolarianKraken do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:kraken) { ResolvePermanent("Tolarian Kraken", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def draw
    p1.draw!
    game.settle!
  end

  it "is a 4/6 Kraken" do
    expect([kraken.power, kraken.toughness]).to eq([4, 6])
  end

  it "offers to pay {1} whenever you draw a card, then to tap target creature" do
    p1.add_mana(blue: 1)
    draw
    game.resolve_choice!(payment: { generic: { blue: 1 } })
    game.resolve_choice!(target: bears)

    expect(bears).to be_tapped
  end

  it "can untap a creature instead" do
    bears.tap!
    p1.add_mana(blue: 1)
    draw
    game.resolve_choice!(payment: { generic: { blue: 1 } })
    game.resolve_choice!(target: bears, untap: true)

    expect(bears).to be_untapped
  end

  it "does nothing if you decline to pay" do
    p1.add_mana(blue: 1)
    draw
    game.skip_choice!

    expect(game.choices).to be_empty
    expect(bears).to be_untapped
  end

  it "offers nothing when you can't pay {1}" do
    draw

    expect(game.choices).to be_empty
  end

  it "ignores cards an opponent draws" do
    p1.add_mana(blue: 1)
    p2.draw!
    game.settle!

    expect(game.choices).to be_empty
  end
end
