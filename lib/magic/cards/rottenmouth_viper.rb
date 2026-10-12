module Magic
  module Cards
    RottenmouthViper = Creature("Rottenmouth Viper") do
      cost generic: 5, black: 1
      creature_type("Elemental Snake")
      power 6
      toughness 6
    end

    class RottenmouthViper < Creature
      # As an additional cost to cast this spell, you may sacrifice any number of nonland permanents. This spell
      # costs {1} less to cast for each permanent sacrificed this way.
      def additional_costs = [Costs::SacrificeAny.new(self)]

      # Whenever this creature enters or attacks, put a blight counter on it. Then for each blight counter on it,
      # each opponent loses 4 life unless that player sacrifices a nonland permanent of their choice or discards
      # a card.
      module Blighting
        def blight_opponents
          actor.add_counter("blight")
          counters = actor.counters.of_type(Counters["blight"]).count
          game.opponents(controller).each do |opponent|
            counters.times do
              game.choices.add(Magic::Choice::LoseLifeUnless.new(actor: actor, player: opponent, life: 4, discard: true, sacrifice: true))
            end
          end
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        include Blighting

        def call = blight_opponents
      end

      class AttacksTrigger < TriggeredAbility
        include Blighting

        def should_perform? = event.attacks.any? { _1.attacker == actor }

        def call = blight_opponents
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
