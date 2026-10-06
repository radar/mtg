module Magic
  module Cards
    AdelineResplendentCathar = Creature("Adeline, Resplendent Cathar") do
      cost generic: 1, white: 2
      legendary_creature_type "Human Knight"
      keywords :vigilance
      power 0
      toughness 4
    end

    class AdelineResplendentCathar < Creature
      HumanToken = Token.create "Human" do
        creature_type "Human"
        power 1
        toughness 1
        colors :white
      end

      # "Adeline's power is equal to the number of creatures you control." (A power of 0 plus one for each.)
      class PowerFromCreatures < Abilities::Static::PowerAndToughnessModification
        def applicable_targets = [source]

        def power_modification = source.controller.creatures.count
        def toughness_modification = 0
      end

      # "Whenever you attack, for each opponent, create a 1/1 white Human creature token that's tapped and attacking
      # that player." (The planeswalker alternative isn't offered: the token attacks the player.)
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && event.attacks.any?
        end

        def call
          opponents.each do |opponent|
            trigger_effect(:create_token, token_class: HumanToken, amount: 1, enters_tapped: true, attacking: true, attack_target: opponent)
          end
        end
      end

      def static_abilities = [PowerFromCreatures]
      def event_handlers = { Events::FinalAttackersDeclared => AttackTrigger }
    end
  end
end
