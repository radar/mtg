# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BillowingShriekmass do
  include_context "two player game"

  def fill_graveyard(count)
    count.times { p1.graveyard.add(Card("Grizzly Bears", owner: p1)) }
  end

  it "mills three cards when it enters" do
    library_size = p1.library.count
    ResolvePermanent("Billowing Shriekmass", owner: p1)

    expect(p1.library.count).to eq(library_size - 3)
    expect(p1.graveyard.count).to eq(3)
  end

  it "is a 2/3 flyer" do
    shriekmass = ResolvePermanent("Billowing Shriekmass", owner: p1)

    expect([shriekmass.power, shriekmass.toughness]).to eq([2, 3])
    expect(shriekmass).to be_flying
  end

  it "gets +2/+1 with seven or more cards in your graveyard" do
    shriekmass = ResolvePermanent("Billowing Shriekmass", owner: p1)
    fill_graveyard(4)
    game.tick!

    expect([shriekmass.power, shriekmass.toughness]).to eq([4, 4])
  end

  it "doesn't get the bonus with six cards" do
    shriekmass = ResolvePermanent("Billowing Shriekmass", owner: p1)
    fill_graveyard(3)
    game.tick!

    expect([shriekmass.power, shriekmass.toughness]).to eq([2, 3])
  end
end
