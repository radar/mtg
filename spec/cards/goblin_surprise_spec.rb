# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GoblinSurprise do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast_surprise(mode)
    p1.add_mana(red: 3)
    surprise = Card("Goblin Surprise", owner: p1)
    p1.cast(card: surprise) do |a|
      a.pay_mana(generic: { red: 2 }, red: 1)
      a.choose_mode(surprise.modes[mode])
    end
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  it "gives creatures you control +2/+0 until end of turn" do
    cast_surprise(0)

    expect(bears.power).to eq(4)
    expect(rival.power).to eq(2)
  end

  it "creates two 1/1 red Goblin creature tokens" do
    cast_surprise(1)

    expect(p1.creatures.select { _1.name == "Goblin" }.count).to eq(2)
  end
end
