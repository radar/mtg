require 'spec_helper'

RSpec.describe Magic::Cards::AjanisPridemate do
  include_context "two player game"

  let!(:permanent) { ResolvePermanent("Ajani's Pridemate") }

  it "gets counters when player gains life" do
    p1.gain_life(3)
    expect(permanent.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(3)
  end
end
