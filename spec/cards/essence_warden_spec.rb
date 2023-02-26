require 'spec_helper'

RSpec.describe Magic::Cards::EssenceWarden do
  include_context "two player game"

  before do
    ResolvePermanent("Essence Warden", owner: p1)
  end

  context "when another creature controlled by the same controller enters the battlefield" do
    it "adds a life to controller's life total" do
      expect { ResolvePermanent("Loxodon Wayfarer", owner: p1) }.to change { p1.life }.by(1)
    end
  end

  context "when another creature controlled by a different controller enters the battlefield" do
    it "adds a life to controller's life total" do
      expect { ResolvePermanent("Loxodon Wayfarer", owner: p2)  }.to change { p1.life }.by(1)
    end
  end
end
