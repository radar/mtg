module Magic
  class Choice
    # "As this enters, choose a creature type." Stores the answer on the permanent
    # (`Permanent#chosen_creature_type`). Pass `options:` for "choose Elemental, Elf, Faerie, ..."
    # cards, which may only pick from that list.
    class ChooseCreatureTypeForPermanent < CreatureType
      def initialize(actor:, options: nil)
        super(actor: actor)
        @options = options
      end

      def choices = @options

      def resolve!(creature_type:)
        if @options && !@options.include?(creature_type)
          raise ArgumentError, "#{creature_type} is not one of #{@options.join(", ")}"
        end

        actor.chosen_creature_type = creature_type
      end
    end
  end
end
