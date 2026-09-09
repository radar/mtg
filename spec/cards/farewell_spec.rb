require "spec_helper"

RSpec.describe Magic::Cards::Farewell do
  include_context "two player game"

  it "is a six-mana sorcery" do
    expect(Card("Farewell").mana_value).to eq(6)
  end
end