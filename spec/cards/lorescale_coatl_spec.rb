require "spec_helper"

RSpec.describe Magic::Cards::LorescaleCoatl do
  include_context "two player game"

  subject(:lorescale_coatl) { ResolvePermanent("Lorescale Coatl") }

  before do
    p1.library.add(Card("Forest"))
  end

  it "gets a +1/+1 counter whenever its controller draws a card" do
    expect(lorescale_coatl.power).to eq(2)
    expect(lorescale_coatl.toughness).to eq(2)

    p1.draw!
    expect(lorescale_coatl.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
  end
end
