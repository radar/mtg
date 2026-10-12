module Magic
  module Cards
    class TrialOfAgony < Sorcery
      card_name "Trial of Agony"
      cost red: 1

      # "That player chooses one of those creatures. Trial of Agony deals 5 damage to that creature, and the other can't
      # block this turn."
      class OpponentChoice < Magic::Choice
        attr_reader :player, :creatures

        def initialize(actor:, player:, creatures:)
          @player = player
          @creatures = creatures
          super(actor: actor)
        end

        def chooser = player

        def prompt = "Choose a creature to be dealt 5 damage; the other can't block this turn."

        def choices = creatures

        def resolve!(target:)
          raise ArgumentError, "Choose one of the targeted creatures." unless creatures.include?(target)

          trigger_effect(:deal_damage, target:, damage: 5)
          (creatures - [target]).each(&:prevent_blocking!)
        end
      end

      def multi_target? = true

      def distinct_targets? = true

      def target_choices = [battlefield.creatures, battlefield.creatures]

      # "Choose two target creatures controlled by the same opponent."
      def targets_legal?(targets)
        targets.size == 2 && targets.map(&:controller).uniq.size == 1 && targets.first.controller != controller
      end

      def resolve!(targets:)
        creatures = targets.select { _1.zone&.battlefield? }
        return if creatures.empty?

        choice = OpponentChoice.new(actor: self, player: creatures.first.controller, creatures:)
        # With only one creature still around there is nothing to choose between.
        creatures.one? ? choice.resolve!(target: creatures.first) : game.choices.add(choice)
      end
    end
  end
end
