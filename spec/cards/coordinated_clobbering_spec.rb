# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CoordinatedClobbering do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:second) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:victim) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let(:clobbering) { Card("Coordinated Clobbering", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.add(clobbering)
    p1.add_mana(green: 1)
  end

  def clobber(*targets)
    p1.cast(card: clobbering) do |action|
      action.pay_mana(green: 1)
      action.targeting(*targets)
    end
    game.stack.resolve!
    game.settle!
  end

  it "taps one creature that then deals damage equal to its power" do
    clobber(bears, victim)

    expect(bears).to be_tapped
    expect(second).not_to be_tapped
    expect(p2.creatures).to be_empty
  end

  it "taps two creatures that each deal damage" do
    clobber(bears, second, victim)

    expect(bears).to be_tapped
    expect(second).to be_tapped
    expect(p2.creatures).to be_empty
  end

  it "cannot use a tapped creature" do
    bears.tap!
    expect { clobber(bears, victim) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
