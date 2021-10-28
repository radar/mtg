require 'spec_helper'

RSpec.describe Magic::Cards::ProfaneMemento do
  include_context "two player game"

  subject { Card("Profane Memento", controller: p1) }

  context "receive notification" do
    context "when creature enters controller's graveyard" do
      let(:p1_creature) { Card("Loxodon Wayfarer", controller: p1) }
      let(:event) do
        Magic::Events::EnteredZone.new(
          p1_creature,
          from: game.battlefield,
          to: p1.graveyard
        )
      end

      it "does not gain life" do
        expect { subject.receive_notification(event) }.not_to(change { p1.life })
      end
    end

    context "when a creature enters opponent's graveyard" do
      let(:p2_creature) { Card("Loxodon Wayfarer", controller: p2) }
      let(:event) do
        Magic::Events::EnteredZone.new(
          p2_creature,
          from: game.battlefield,
          to: p2.graveyard,
        )
      end

      it "gains life" do
        expect { subject.receive_notification(event) }.to(change { p1.life }.by(1))
      end
    end

    context "when an artifact enters opponent's graveyard" do
      let(:p2_artifact) { Card("Profane Memento", controller: p2) }
      let(:event) do
        Magic::Events::EnteredZone.new(
          p2_artifact,
          from: game.battlefield,
          to: p2.graveyard,
        )
      end

      it "gains no life" do
        expect { subject.receive_notification(event) }.not_to(change { p1.life })
      end
    end
  end
end
