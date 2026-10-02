# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WaryThespian do
  include_context "two player game"

  let!(:thespian) { ResolvePermanent("Wary Thespian", owner: p1) }

  it "is a 3/1 Cat Druid" do
    expect([thespian.power, thespian.toughness]).to eq([3, 1])
  end

  it "surveils 1 when it enters" do
    expect(game.choices.last).to be_a(Magic::Choice::Surveil)

    top = p1.library.first
    game.resolve_choice!(graveyard: [top])

    expect(top.zone).to be_graveyard
  end

  it "surveils 1 when it dies" do
    game.resolve_choice!(top: [p1.library.first])
    thespian.destroy!
    game.settle!

    expect(game.choices.last).to be_a(Magic::Choice::Surveil)
  end
end
