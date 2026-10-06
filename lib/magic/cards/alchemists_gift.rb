module Magic
  module Cards
    AlchemistsGift = Instant("Alchemist's Gift") do
      cost black: 1
    end

    class AlchemistsGift < Instant
      # "...gains your choice of deathtouch or lifelink until end of turn."
      class KeywordChoice < Magic::Choice
        attr_reader :creature

        def initialize(actor:, creature:)
          super(actor:)
          @creature = creature
        end

        def modes
          { deathtouch: "Deathtouch", lifelink: "Lifelink" }
        end

        def resolve!(mode:)
          case mode
          when :deathtouch then creature.grant_keyword(Keywords::DEATHTOUCH)
          when :lifelink then creature.grant_keyword(Keywords::LIFELINK)
          else raise "Invalid mode chosen for Alchemist's Gift: #{mode}"
          end
        end
      end

      def target_choices = battlefield.creatures

      # "Target creature gets +1/+1 and gains your choice of deathtouch or lifelink until end of turn."
      def resolve!(target:)
        trigger_effect(:modify_power_toughness, target:, power: 1, toughness: 1)
        game.add_choice(KeywordChoice.new(actor: self, creature: target))
      end
    end
  end
end
