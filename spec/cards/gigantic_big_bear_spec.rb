# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GiganticBigBear do
  include_context "two player game"

  let!(:bear) { ResolvePermanent("Gigantic Big Bear", owner: p1) }

  it "is a 10/7 Bear with hexproof and haste" do
    expect(bear.power).to eq(10)
    expect(bear.toughness).to eq(7)
    expect(bear.type?("Bear")).to eq(true)
    expect(bear.has_keyword?(Magic::Cards::Keywords::HEXPROOF)).to eq(true)
    expect(bear.has_keyword?(Magic::Cards::Keywords::HASTE)).to eq(true)
  end

  it "can't be countered" do
    expect(Card("Gigantic Big Bear").can_be_countered?).to eq(false)
  end
end
