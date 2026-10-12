# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Anthropede do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:room) { ResolvePermanent("Funeral Room Awakening Hall", owner: p2, doors: [:left]) }
  let!(:other_room) { ResolvePermanent("Glassworks Shattered Yard", owner: p1, doors: [:left]) }

  def enter!
    ResolvePermanent("Anthropede", owner: p1)
    game.settle!
  end

  it "is a 3/4 Insect with reach" do
    anthropede = ResolvePermanent("Anthropede", owner: p1)

    expect([anthropede.power, anthropede.toughness]).to eq([3, 4])
    expect(anthropede).to have_keyword(:reach)
  end

  it "destroys target Room if you discard a card" do
    enter!
    discarded = p1.hand.cards.first
    game.resolve_choice!(discard: discarded)
    expect(game.choices.last.choices).to contain_exactly(room, other_room)
    game.resolve_choice!(target: room)

    expect(discarded.zone).to be_graveyard
    expect(room.zone).to be_nil
    expect(other_room.zone).to be_battlefield
  end

  it "destroys target Room if you pay {2}" do
    p1.add_mana(green: 2)
    enter!
    game.resolve_choice!(pay: true)
    game.resolve_choice!(target: other_room)

    expect(p1.mana_pool.values.sum).to eq(0)
    expect(other_room.zone).to be_nil
  end

  it "does nothing if you decline" do
    enter!
    game.skip_choice!

    expect(game.choices).to be_empty
    expect([room.zone, other_room.zone]).to all(be_battlefield)
  end

  it "can't be paid for without the mana" do
    enter!

    expect { game.resolve_choice!(pay: true) }.to raise_error(Magic::Costs::Mana::CannotPay)
  end

  it "does nothing further when there is no Room to destroy" do
    [room, other_room].each(&:destroy!)
    game.settle!
    enter!
    game.resolve_choice!(discard: p1.hand.cards.first)

    expect(game.choices).to be_empty
  end
end
