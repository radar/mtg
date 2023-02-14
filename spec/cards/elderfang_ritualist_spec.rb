require 'spec_helper'

RSpec.describe Magic::Cards::ElderfangRitualist do
  include_context "two player game"

  let(:elderfang_ritualist) { ResolvePermanent("Elderfang Ritualist", owner: p1) }

  context "dies" do
    context "when p1 has wood elves in the graveyard" do
      let(:wood_elves) { Card("Wood Elves") }

      before do
        p1.graveyard.add(wood_elves)
      end

      it "brings back wood elves" do
        elderfang_ritualist.destroy!
        expect(wood_elves.zone).to eq(p1.hand)
      end
    end
  end
end
