# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Thrive do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:warmaster) { ResolvePermanent("Elvish Warmaster", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast_thrive(x, *targets)
    p1.add_mana(green: x + 1)
    p1.cast(card: Card("Thrive", owner: p1), value_for_x: x) do |a|
      a.pay_mana(x: { green: x }, green: 1)
      a.targeting(*targets)
    end
    game.stack.resolve!
    game.tick!
  end

  it "puts a +1/+1 counter on each of X target creatures" do
    cast_thrive(2, bears, rival)

    expect(bears.power).to eq(3)
    expect(rival.power).to eq(3)
    expect(warmaster.counters).to be_empty
  end

  it "works with X of 1" do
    cast_thrive(1, bears)

    expect(bears.toughness).to eq(3)
  end
end
