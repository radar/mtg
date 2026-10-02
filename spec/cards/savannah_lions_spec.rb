# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SavannahLions do
  include_context "two player game"

  it "is a 2/1 Cat" do
    lions = ResolvePermanent("Savannah Lions", owner: p1)

    expect([lions.power, lions.toughness]).to eq([2, 1])
  end
end
