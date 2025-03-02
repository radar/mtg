require 'spec_helper'

RSpec.describe Magic::Filter do
  include_context "two player game"
  subject(:filter) { described_class.[](:basic_lands) }

  it "applies a filter to a card list" do
    list = Magic::CardList.new([
      Card("Forest"),
      Card("Island"),
      Card("Mountain"),
      Card("Swamp"),
      Card("Plains"),
      Card("Lightning Bolt")
    ])


    expect(list.filter(filter).count).to eq(5)
  end
end
