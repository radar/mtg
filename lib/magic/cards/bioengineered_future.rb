module Magic
  module Cards
    BioengineeredFuture = Enchantment("Bioengineered Future") do
      cost generic: 1, green: 2
    end

    class BioengineeredFuture < Enchantment
      LanderToken = Token.create("Lander") do
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

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          actor.create_token(token_class: LanderToken)
        end
      end

      class CreatureEntryCounters < StaticAbility
        def additional_counters_for_entering(permanent)
          return 0 unless permanent.controller == controller

          lands = game.current_turn.events.count do |event|
            event.is_a?(Events::Landfall) && event.player == controller
          end
          lands
        end
      end

      def etb_triggers = [EntersTrigger]

      def static_abilities = [CreatureEntryCounters]
    end
  end
end
