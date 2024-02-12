require 'spec_helper'

RSpec.describe Magic::Zones::Library do
  let(:game) { Magic::Game.new }
  let(:player) { Magic::Player.new }
  let(:island) { Card("Island", owner: player) }
  subject { described_class.new(owner: player, items: [island]) }

  context "#draw" do
    it "draws a card from the library" do
      card = subject.draw
      expect(subject.items.count).to eq(0)
    end
  end
end
