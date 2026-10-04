# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SecondHarvest do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def tokens_of(player) = player.permanents.select(&:token?)

  before do
    bears.trigger_effect(:create_token, token_class: Magic::Tokens::Treasure)
    bears.trigger_effect(:create_token, token_class: Magic::Tokens::Clue)
    rival.trigger_effect(:create_token, token_class: Magic::Tokens::Treasure)
    game.settle!

    p1.add_mana(green: 4)
    p1.cast(card: Card("Second Harvest", owner: p1)) { |a| a.pay_mana(generic: { green: 2 }, green: 2) }
    game.stack.resolve!
    game.settle!
  end

  it "creates a copy of each token you control" do
    expect(tokens_of(p1).map(&:name)).to contain_exactly("Treasure", "Treasure", "Clue", "Clue")
  end

  it "doesn't copy nontoken permanents" do
    expect(p1.permanents.by_name("Grizzly Bears").count).to eq(1)
  end

  it "doesn't copy opponents' tokens" do
    expect(tokens_of(p2).map(&:name)).to eq(["Treasure"])
  end
end
