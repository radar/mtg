module Magic
  module Cards
    PsychicFrog = Creature("Psychic Frog") do
      cost "{U}{B}"
      creature_type "Frog"
      power 1
      toughness 2
    end

    class PsychicFrog < Creature
      # "Whenever this creature deals combat damage to a player or planeswalker, draw a card."
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.source == actor &&
            (event.target.is_a?(Magic::Player) || (event.target.respond_to?(:planeswalker?) && event.target.planeswalker?))
        end

        def call
          draw_card
        end
      end

      # "Discard a card: Put a +1/+1 counter on this creature."
      class GrowAbility < Magic::ActivatedAbility
        def costs = [Costs::Discard.new(controller)]

        def resolve!
          add_counter("+1/+1", to: source)
        end
      end

      # "Exile three cards from your graveyard: This creature gains flying until end of turn."
      class FlyingAbility < Magic::ActivatedAbility
        def costs = [Costs::ExileFromGraveyard.new(source, count: 3)]

        def resolve!
          give_keyword(source, :flying)
        end
      end

      def activated_abilities = [GrowAbility, FlyingAbility]

      def event_handlers = super.merge({ Events::CombatDamageDealt => CombatDamageTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
