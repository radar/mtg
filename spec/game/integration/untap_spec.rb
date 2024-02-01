require 'spec_helper'

RSpec.describe Magic::Game, "untap step" do
  include_context "two player game"

  let!(:dranas_emissary) { ResolvePermanent("Drana's Emissary", owner: p1) }

  before do
    dranas_emissary.phase_out!
  end

  it "phases back in" do
    expect(dranas_emissary).to be_phased_out
    current_turn.untap!
    expect(dranas_emissary).not_to be_phased_out
  end
end
