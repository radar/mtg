module Magic
  module Cards
    WitchKingBringerOfRuin = Creature("Witch-king, Bringer of Ruin") do
      cost "{4}{B}{B}"
      legendary_creature_type "Wraith Noble"
      keywords :flying
      power 5
      toughness 3
    end

    class WitchKingBringerOfRuin < Creature
      # "...defending player sacrifices a creature with the least power among creatures they control." The defending
      # player chooses among the creatures tied for least power (not a target); a lone candidate is sacrificed at once.
      class SacrificeChoice < Magic::Choice::Targeted
        def initialize(actor:, player:)
          @player = player
          super(actor: actor)
        end

        def chooser = @player

        def targets? = false

        def choice_amount = 1

        def choices
          creatures = battlefield.controlled_by(@player).creatures
          least = creatures.map(&:power).min
          creatures.select { _1.power == least }
        end

        def resolve!(target:)
          raise ArgumentError, "#{target&.name.inspect} does not have the least power" unless choices.include?(target)

          target.sacrifice!
        end

        # The sacrifice is not optional: skipping picks the first candidate.
        def decline!
          resolve!(target: choices.first)
        end
      end

      class AttackTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        # The player being attacked, or the controller of the attacked planeswalker.
        def defending_player
          target = event.target
          target.is_a?(Player) ? target : target.controller
        end

        def call
          choice = SacrificeChoice.new(actor: actor, player: defending_player)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::CreatureAttacked => AttackTrigger }
    end
  end
end
