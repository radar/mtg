require 'spec_helper'

RSpec.describe Magic::Cards::DaybreakCharger do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  subject { Card("Daybreak Charger", controller: p1) }


  context "ETB Event" do
    let(:wood_elves) { Card("Wood Elves", controller: p1) }

    before do
      game.battlefield.add(wood_elves)
    end

    it "buffs a target" do
      subject.resolve!
      game.stack.resolve!
      apply_buff_effect = game.next_effect
      expect(apply_buff_effect).to be_a(Magic::Effects::ApplyBuff)
      game.resolve_effect(apply_buff_effect, targets: [wood_elves])
      expect(wood_elves.power).to eq(3)
    end
  end
end
