require 'spec_helper'

RSpec.describe Magic::Game, "your upkeep trigger" do
  subject(:game) { Magic::Game.new }

  let!(:p1) { game.add_player }
  let!(:p2) { game.add_player }
  let(:dranas_emissary) { Card("Drana's Emissary", controller: p1) }

  before do
    game.battlefield.add(dranas_emissary)
  end

  it "upkeep triggers dranas emissary's ability" do
    expect(subject).to be_at_step(:untap)
    subject.next_step

    expect(p1.life).to eq(21)
    expect(p2.life).to eq(19)
  end
end
