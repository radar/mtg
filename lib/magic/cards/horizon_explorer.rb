module Magic
  module Cards
    HorizonExplorer = Creature("Horizon Explorer") do
      cost generic: 2, green: 1
      creature_type "Insect Scout"
      power 3
      toughness 3
    end

    class HorizonExplorer < Creature
      class LanderToken < Token
        token_name "Lander"
        type T::Artifact
        power 0
        toughness 0

        class Ability < Magic::ActivatedAbility
          costs "{2}, {T}, Sacrifice {this}"

          class BasicLandChoice < Magic::Choice::SearchLibrary
            def initialize(actor:)
              super(actor: actor, to_zone: :battlefield, enters_tapped: true, filter: Filter[:basic_lands])
            end
          end

          def resolve!
            game.add_choice(BasicLandChoice.new(actor: source))
          end
        end

        def self.activated_abilities = [Ability]
      end

      class LandsEnterUntapped < StaticAbility
        def lands_enter_untapped?(card)
          card.land? && card.controller == controller
        end
      end

      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { |attack| attack.attacker == actor }
        end

        def call
          actor.create_token(token_class: LanderToken)
        end
      end

      def static_abilities = [LandsEnterUntapped]

      def event_handlers
        { Events::FinalAttackersDeclared => AttackTrigger }
      end
    end
  end
end