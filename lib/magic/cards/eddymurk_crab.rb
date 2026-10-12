module Magic
  module Cards
    EddymurkCrab = Creature("Eddymurk Crab") do
      cost generic: 5, blue: 2
      creature_type("Elemental Crab")
      keywords :flash
      power 5
      toughness 5
    end

    class EddymurkCrab < Creature
      # This spell costs {1} less to cast for each instant and sorcery card in your graveyard.
      def self_mana_cost_adjustment
        player = controller || owner
        { generic: -> { -player.graveyard.count { _1.instant? || _1.sorcery? } } }
      end

      # This creature enters tapped if it's not your turn.
      def enters_tapped?
        game.current_turn.active_player != (controller || owner)
      end

      # When this creature enters, tap up to two target creatures.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TapChoice < Magic::Choice::Targeted
          def choices = battlefield.creatures

          def choice_amount = 0..2

          def resolve!(targets:)
            Array(targets).first(2).each { trigger_effect(:tap, target: _1) }
          end
        end

        def call
          choice = TapChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
