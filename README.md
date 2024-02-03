# Magic: The Gathering: The Ruby Project

This is an attempt to build a somewhat functional simulation of Magic: The Gathering in Ruby.

It is incredibly rudimentary. I have little-to-no prior game programming experience. You have been warned.

Parts of this have been inspired by [Grove](https://github.com/pinky39/grove) -- a C# implementation of MTG. And other parts have been inspired by [Mage](https://github.com/magefree/mage). Kudos to them for sharing their code openly!

Unlike Grove and Mage, this implementation does not have any UI. Use your imagination!

## Getting Started

To get started with this project:

```
bundle install
bundle exec rspec
```

All the tests should pass.

## Implementing a card

Let's say we want to implement a simple card, such as [Story Seeker](https://scryfall.com/card/khm/34/story-seeker). We can do this by creating a new card at `lib/magic/cards/story_seeker.rb`, and then we can use the `CardBuilder` DSL to build this card. Given that this card does not have any activated abilities or other effects, the code is quite simple:

```ruby
module Magic
  module Cards
    StorySeeker = Creature("Story Seeker") do
      cost generic: 1, white: 1
      creature_type("Dwarf Cleric")
      keywords :lifelink
      power 2
      toughness 2
    end
  end
end
```

You might end up implementing cards that are more complex, like [Annul](https://scryfall.com/card/khm/42/annul), which has a resolution effect that counters a target artifact or enchantment spell. You can see how this is handled at [Magic::Cards::Annul](lib/magic/cards/annul.rb).

If you're unsure how to implement a card, read through the current cards that exist -- you might find something there that matches what you need.

You might find some cards that do not use the `CardBuilder` DSL. These are cards that were implemented before the `CardBuilder` DSL was added. Can you switch these over to using the `CardBuilder` DSL?

## Contributing in other ways

Other than cards, you could contribute by adding additional test cases around things like combat, or existing card abilities. Be sure to check the Issues for this project to see if anything is open and listed there.

## Copyright

Magic: The Gathering is copyright of Wizards of the Coast.
