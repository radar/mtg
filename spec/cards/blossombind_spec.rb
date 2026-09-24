# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Blossombind do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before do
    go_to_main_phase!
    p1.add_mana(blue: 2)
    p1.cast(card: Card("Blossombind")) do
      _1.auto_pay_mana
      _1.targeting(bears)
    end
    game.stack.resolve!
  end

  it "enchants the creature and taps it when it enters" do
    expect(bears.attachments.map(&:name)).to eq(["Blossombind"])
    expect(bears).to be_tapped
  end

  it "keeps the creature from becoming untapped" do
    bears.untap!
    expect(bears).to be_tapped

    go_to_main_phase_for!(p2)
    expect(bears).to be_tapped
  end

  it "keeps counters from being put on the creature" do
    bears.add_counter("+1/+1", amount: 2)
    game.tick!
    expect(bears.counters).to be_empty
    expect(bears.power).to eq(2)
  end

  it "stops once Blossombind leaves" do
    aura = bears.attachments.first
    aura.destroy!
    game.tick!

    bears.untap!
    bears.add_counter("+1/+1")
    expect(bears).to be_untapped
    expect(bears.counters.count).to eq(1)
  end
end
