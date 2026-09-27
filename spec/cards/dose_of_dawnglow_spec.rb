# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DoseOfDawnglow do
  include_context "two player game"

  let(:bears) { Card("Grizzly Bears", owner: p1) }

  before { p1.graveyard.add(bears) }

  def cast!
    p1.add_mana(black: 5)
    p1.cast(card: Card("Dose of Dawnglow", owner: p1)) { |a| a.pay_mana(generic: { black: 4 }, black: 1).targeting(bears) }
    game.stack.resolve!
  end

  it "returns target creature card from the graveyard to the battlefield" do
    go_to_main_phase!
    cast!

    expect(bears.zone).to be_battlefield
  end

  it "does not blight during its controller's main phase" do
    go_to_main_phase!
    cast!

    expect(game.choices).to be_empty
  end

  it "blights 2 when it isn't its controller's main phase" do
    own_bears = ResolvePermanent("Grizzly Bears", owner: p1)
    skip_to_combat!
    cast!

    expect(game.choices).not_to be_empty
    game.resolve_choice!(target: own_bears)

    expect(own_bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(2)
  end

  it "blights 2 when cast on an opponent's turn" do
    own_bears = ResolvePermanent("Grizzly Bears", owner: p1)
    go_to_main_phase_for!(p2)
    cast!

    expect(game.choices).not_to be_empty
    game.resolve_choice!(target: own_bears)

    expect(own_bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(2)
  end
end
