module Magic
  module Cards
    HauntwoodsShrieker = Creature("Hauntwoods Shrieker") do
      cost generic: 1, green: 2
      creature_type "Beast Mutant"
      power 3
      toughness 3
    end

    class HauntwoodsShrieker < Creature
      # "Whenever this creature attacks, manifest dread."
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          Magic::Choice::ManifestDread.perform(actor: actor)
        end
      end

      # "...If it's a creature card, you may turn it face up." Turned up for free, as an effect.
      class TurnFaceUpChoice < Magic::Choice::May
        def initialize(actor:, permanent:)
          super(actor: actor)
          @permanent = permanent
        end

        def prompt = "Turn #{@permanent.card.name} face up?"

        def resolve!
          @permanent.turn_face_up!
        end
      end

      # "{1}{G}: Reveal target face-down permanent. If it's a creature card, you may turn it face up."
      class RevealAbility < Magic::ActivatedAbility
        costs "{1}{G}"

        def target_choices
          game.battlefield.permanents.select(&:face_down?)
        end

        def resolve!(target:)
          reveal_cards([target.card])
          return unless target.card.creature? && target.can_be_turned_face_up?

          game.add_choice(TurnFaceUpChoice.new(actor: source, permanent: target))
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
      def activated_abilities = [RevealAbility]
    end
  end
end
