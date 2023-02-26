require 'spec_helper'

RSpec.describe Magic::Cards::HealerOfThePride do
  include_context "two player game"

  before do
    ResolvePermanent("Healer Of The Pride", owner: p1)
  end

  context "when another creature controlled by this player enters the battlefield" do
    it "adds a life to player's life total" do
      expect { ResolvePermanent("Loxodon Wayfarer", owner: p1) }.to change { p1.life }.by(2)
    end
  end
end
