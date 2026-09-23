require "spec_helper"

RSpec.describe "Trigger queue (Game#queue_triggers?)" do
  include_context "two player game"

  # Wolverine Riders' upkeep trigger has no `you?` restriction, so it fires for
  # whoever's upkeep it is, and its effect (creating a token) is easy to observe.
  # Dispatched directly (not via `current_turn.upkeep!`) so the checkpoints Turn's
  # phase transitions now trigger don't immediately settle everything -- this spec
  # wants to inspect the queue mid-flight, before it's drained.
  def fire_upkeep!(*riders)
    event = Magic::Events::BeginningOfUpkeep.new(player: p1)
    riders.each { |rider| rider.receive_event(event) }
  end

  describe "with queue_triggers: true" do
    let(:game) { Magic::Game.new(queue_triggers: true) }

    it "defers a triggered ability's effect until the stack resolves, in APNAP order" do
      rider1 = ResolvePermanent("Wolverine Riders", owner: p1)
      rider2 = ResolvePermanent("Wolverine Riders", owner: p2)
      game.settle!

      fire_upkeep!(rider1, rider2)

      expect(game.battlefield.creatures.count(&:token?)).to eq(0)
      game.check_state_based_actions!
      expect(game.stack.first.controller).to eq(p2)

      game.settle!

      expect(game.battlefield.creatures.count(&:token?)).to eq(2)
    end
  end

  describe "Choice::OrderTriggers" do
    let(:game) { Magic::Game.new(queue_triggers: true) }

    it "puts one trigger on the stack and re-queues itself for the rest" do
      rider1 = ResolvePermanent("Wolverine Riders", owner: p1)
      rider2 = ResolvePermanent("Wolverine Riders", owner: p1)
      game.settle!

      event = Magic::Events::BeginningOfUpkeep.new(player: p1)
      first_trigger = Magic::Cards::WolverineRiders::UpkeepTrigger.new(actor: rider1, event: event)
      second_trigger = Magic::Cards::WolverineRiders::UpkeepTrigger.new(actor: rider2, event: event)

      choice = Magic::Choice::OrderTriggers.new(player: p1, triggers: [first_trigger, second_trigger])
      expect(choice.choices).to eq([first_trigger, second_trigger])

      game.pending_triggers.push(first_trigger, second_trigger)
      choice.resolve!(target: first_trigger)

      # A single trigger left doesn't need a real choice -- it auto-resolves too, so
      # both ended up on the stack (second on top, since it went on after first).
      expect(game.pending_triggers).to be_empty
      expect(game.choices).to be_empty
      expect(game.stack.map(&:actor)).to eq([rider2, rider1])
    end
  end

  describe "with the default (queue_triggers: false)" do
    it "keeps running triggers synchronously, with no stack involvement" do
      ResolvePermanent("Wolverine Riders", owner: p1)

      current_turn.untap!
      current_turn.upkeep!

      expect(game.battlefield.creatures.count(&:token?)).to eq(1)
      expect(game.stack).to be_empty
    end
  end
end
