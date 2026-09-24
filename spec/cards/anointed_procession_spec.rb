require "spec_helper"

RSpec.describe Magic::Cards::AnointedProcession do
  include_context "two player game"

  def cast_ascension(player, target)
    player.add_mana(white: 2)
    player.cast(card: Card("Angelic Ascension", owner: player)) do
      _1.targeting(target)
      _1.auto_pay_mana
    end
    game.stack.resolve!
  end

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }
  let!(:procession) { ResolvePermanent("Anointed Procession", owner: p1) }

  it "creates twice as many tokens under your control" do
    cast_ascension(p1, wood_elves)

    expect(game.battlefield.controlled_by(p1).creatures.by_name("Angel").count).to eq(2)
  end

  it "doesn't double tokens an opponent creates" do
    opponent_elves = ResolvePermanent("Wood Elves", owner: p2)
    cast_ascension(p2, opponent_elves)

    expect(game.battlefield.controlled_by(p2).creatures.by_name("Angel").count).to eq(1)
  end

  it "doubles again with a second Anointed Procession" do
    ResolvePermanent("Anointed Procession", owner: p1)
    cast_ascension(p1, wood_elves)

    expect(game.battlefield.controlled_by(p1).creatures.by_name("Angel").count).to eq(4)
  end

  it "doesn't double counters" do
    wood_elves.trigger_effect(:add_counter, counter_type: Magic::Counters::Plus1Plus1, target: wood_elves)

    expect(wood_elves.counters.count).to eq(1)
  end
end
