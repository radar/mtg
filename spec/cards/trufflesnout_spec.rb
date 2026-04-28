# frozen_string_literal: true
require "spec_helper"

RSpec.describe Magic::Cards::Trufflesnout do
  include_context "two player game"

  let(:trufflesnout) { ResolvePermanent("Trufflesnout", owner: p1) }

  describe "entering the battlefield" do
    before { trufflesnout }

    it "presents a choice" do
      expect(game.choices.last).to be_a(Magic::Cards::Trufflesnout::Choice)
    end

    context "when choosing to put a +1/+1 counter on itself" do
      before do
        game.resolve_choice!(mode: Magic::Cards::Trufflesnout::Choice::COUNTER)
        game.tick!
      end

      it "puts a +1/+1 counter on itself" do
        expect(trufflesnout.power).to eq(3)
        expect(trufflesnout.toughness).to eq(3)
      end
    end

    context "when choosing to gain 4 life" do
      before { game.resolve_choice!(mode: Magic::Cards::Trufflesnout::Choice::GAIN_LIFE) }

      it "gains 4 life for the controller" do
        expect(p1.life).to eq(24)
      end
    end
  end
end
