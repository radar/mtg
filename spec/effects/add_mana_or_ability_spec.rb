require 'spec_helper'

RSpec.describe Magic::Effects::AddManaOrAbility do
  let(:player) { Magic::Player.new }
  subject { described_class.new(player: player, black: 1, green: 1) }

  context "choose" do
    it "chooses the black mana" do
      subject.choose(:black)
      expect(player.mana_pool[:black]).to eq(1)
    end
  end
end
