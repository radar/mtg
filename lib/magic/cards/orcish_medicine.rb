module Magic
  module Cards
    OrcishMedicine = Instant("Orcish Medicine") do
      cost generic: 1, black: 1
    end

    class OrcishMedicine < Instant
      # "...gains your choice of lifelink or indestructible until end of turn." Declining takes lifelink.
      class KeywordChoice < Magic::Choice
        attr_reader :creature

        def initialize(actor:, creature:)
          super(actor:)
          @creature = creature
        end

        def modes
          { lifelink: "Lifelink", indestructible: "Indestructible" }
        end

        def resolve!(mode:)
          case mode
          when :lifelink then creature.grant_keyword(Keywords::LIFELINK)
          when :indestructible then creature.grant_keyword(Keywords::INDESTRUCTIBLE)
          else raise "Invalid mode chosen for Orcish Medicine: #{mode}"
          end
        end

        def decline!
          resolve!(mode: :lifelink)
        end
      end

      def single_target? = true

      def target_choices = battlefield.creatures

      # "Target creature gains your choice of lifelink or indestructible until end of turn. Amass Orcs 1."
      def resolve!(target:)
        game.add_choice(KeywordChoice.new(actor: self, creature: target))
        Magic::Amass.call(source: self, controller: controller, amount: 1, subtype: "Orc")
        super()
      end
    end
  end
end
