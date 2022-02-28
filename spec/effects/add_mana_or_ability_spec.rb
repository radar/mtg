require 'spec_helper'

RSpec.describe Magic::Effects::AddManaOrAbility do
  let(:player) { Magic::Player.new }
  subject { described_class.new(source: double(Magic::Card), player: player, black: 1, green: 1) }

  context "choose" do
    it "chooses the black mana" do
      subject.resolve(black: 1)
      expect(player.mana_pool[:black]).to eq(1)
    end
  end
end
