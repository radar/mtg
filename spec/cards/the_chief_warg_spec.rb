# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheChiefWarg do
  include_context "two player game"

  let!(:warg) { ResolvePermanent("The Chief Warg", owner: p1) }

  def attack_with(creature)
    skip_to_combat!
    @library_before = p1.library.count
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "has menace" do
    expect(warg).to have_keyword(:menace)
  end

  it "draws a card and loses 1 life when you attack while controlling a power 4 creature" do
    ResolvePermanent("Axegrinder Giant", owner: p1)
    attack_with(warg)

    expect(p1.library.count).to eq(@library_before - 1)
    expect(p1.life).to eq(19)
  end

  it "does nothing without a power 4 creature" do
    attack_with(warg)

    expect(p1.library.count).to eq(@library_before)
    expect(p1.life).to eq(20)
  end
end
