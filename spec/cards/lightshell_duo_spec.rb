# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LightshellDuo do
  include_context "two player game"

  it "is a 3/4 with prowess" do
    duo = ResolvePermanent("Lightshell Duo", owner: p1)

    expect([duo.power, duo.toughness]).to eq([3, 4])
    expect(duo.card.has_keyword?(:prowess)).to eq(true)
  end

  it "surveils 2 when it enters" do
    ResolvePermanent("Lightshell Duo", owner: p1)

    expect(game.choices.last).to be_a(Magic::Choice::Surveil)
  end

  it "can put surveilled cards into the graveyard" do
    ResolvePermanent("Lightshell Duo", owner: p1)
    first, second = p1.library.first(2)
    library_size = p1.library.count
    game.resolve_choice!(graveyard: [first], top: [second])

    expect(first.zone).to be_graveyard
    expect(p1.library.first).to eq(second)
    expect(p1.library.count).to eq(library_size - 1)
  end
end
