module Magic
  module Cards
    TheHungerTideRises = Saga("The Hunger Tide Rises") do
      cost generic: 2, green: 1
    end

    class TheHungerTideRises < Saga
      InsectToken = Token.create("Insect") do
        creature_type "Insect"
        power 1
        toughness 1
        colors :black, :green
      end

      # "I, II, III — Create a 1/1 black and green Insect creature token."
      class InsectChapter < Saga::ChapterAbility
        def resolve!
          create_token(token: InsectToken)
        end
      end

      Chapter1 = Class.new(InsectChapter)
      Chapter2 = Class.new(InsectChapter)
      Chapter3 = Class.new(InsectChapter)

      # The second half of chapter IV: a creature card with mana value no greater than the number sacrificed.
      class FindCreatureChoice < Magic::Choice
        attr_reader :limit

        def initialize(actor:, limit:)
          super(actor: actor)
          @limit = limit
        end

        def prompt = "Put a creature card with mana value #{limit} or less from your library or graveyard onto the battlefield."

        def choices
          (library.to_a + graveyard.to_a).select { _1.creature? && _1.mana_value <= limit }
        end

        def resolve!(target:)
          from_library = library.include?(target)
          target.return_to_battlefield!
          library.shuffle! if from_library
        end

        # Searching and finding nothing still shuffles the library.
        def decline! = library.shuffle!
      end

      # "IV — Sacrifice any number of creatures. Search your library and/or graveyard for a creature card with mana value
      # less than or equal to the number of creatures sacrificed this way and put it onto the battlefield. If you search
      # your library this way, shuffle."
      class SacrificeChoice < Magic::Choice
        def prompt = "Sacrifice any number of creatures."

        def choices = controller.creatures.to_a

        def resolve!(sacrifices: [])
          chosen = Array(sacrifices)
          raise ArgumentError, "choose only creatures you control" unless (chosen - choices).empty?

          chosen.each(&:sacrifice!)
          game.add_choice(FindCreatureChoice.new(actor: actor, limit: chosen.size))
        end

        def decline! = game.add_choice(FindCreatureChoice.new(actor: actor, limit: 0))
      end

      class Chapter4 < Saga::ChapterAbility
        def resolve!
          game.add_choice(SacrificeChoice.new(actor: actor))
        end
      end

      def chapters = [Chapter1, Chapter2, Chapter3, Chapter4]
    end
  end
end
