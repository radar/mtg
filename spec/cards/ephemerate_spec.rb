# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Ephemerate do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:ephemerate) { Card("Ephemerate", owner: p1) }

  before { p1.hand.add(ephemerate) }

  it "exiles target creature you control, then returns it to the battlefield under its owner's control" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    bears.add_counter("+1/+1")

    p1.add_mana(white: 1)
    cast_and_resolve(card: ephemerate, player: p1, targeting: bears) do |action|
      action.pay_mana(white: 1)
    end

    expect(game.battlefield).not_to include(bears)

    new_bears = p1.creatures.find { |c| c.name == "Grizzly Bears" }
    expect(new_bears).not_to be_nil
    expect(new_bears).not_to eq(bears)
    expect(new_bears.owner).to eq(p1)
    expect(new_bears.counters).to be_empty
  end

  it "can only target a creature you control" do
    ResolvePermanent("Grizzly Bears", owner: p2)

    expect(ephemerate.target_choices).to be_empty
  end

  it "exiles itself instead of going to the graveyard when cast from hand" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)

    p1.add_mana(white: 1)
    cast_and_resolve(card: ephemerate, player: p1, targeting: bears) do |action|
      action.pay_mana(white: 1)
    end

    expect(ephemerate.zone).to be_exile
    expect(ephemerate.zone).not_to be_graveyard
  end

  context "after being exiled by rebound" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before do
      p1.add_mana(white: 1)
      cast_and_resolve(card: ephemerate, player: p1, targeting: bears) do |action|
        action.pay_mana(white: 1)
      end
    end

    it "offers to cast itself from exile at the beginning of the controller's next upkeep" do
      game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))

      expect(game.choices.first).to be_a(Magic::Choice::May)
    end

    it "does not trigger on the opponent's upkeep" do
      game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p2))

      expect(game.choices).to be_empty
    end

    it "remains in exile if the rebound cast is declined" do
      game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))
      game.skip_choice!

      expect(ephemerate.zone).to be_exile
    end

    it "does not offer the rebound cast again on a later upkeep once it has already triggered" do
      game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))
      game.skip_choice!

      game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))

      expect(game.choices).to be_empty
    end

    it "casts itself from exile without paying its mana cost, then goes to the graveyard" do
      new_bears = p1.creatures.find { |c| c.name == "Grizzly Bears" }

      expect do
        game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))
        game.resolve_choice!
        game.resolve_choice!(target: new_bears)
        game.stack.resolve!
      end.not_to change { p1.mana_pool.values.sum }

      expect(ephemerate.zone).to be_graveyard
    end

    it "does not offer the rebound cast if the controller has no creatures to target" do
      new_bears = p1.creatures.find { |c| c.name == "Grizzly Bears" }
      new_bears.destroy!

      game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))

      expect(game.choices).to be_empty
    end
  end
end
