# Magic: The Gathering: The Ruby Project

This is an attempt to build a somewhat functional simulation of Magic: The Gathering in Ruby.

It is incredibly rudimentary. I have little-to-no prior game programming experience. You have been warned.

Parts of this have been inspired by [Grove](https://github.com/pinky39/grove) -- a C# implementation of MTG. Unlike Grove, this implementation does not have any UI. Use your imagination!

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
      type "Creature -- Dwarf Cleric"
      keywords :lifelink
      power 2
      toughness 2
    end
  end
end
```

You might end up implementing cards that are more complex, like [Annul](https://scryfall.com/card/khm/42/annul), which has a resolution effect that counters a target artifact or enchantment spell. You can see how this is handled at [lib/magic/cards/annul.rb](Magic::Cards::Annul).

If you're unsure how to implement a card, read through the current cards that exist -- you might find something there that matches what you need.

## Contributing in other ways

Other than cards, you could contribute by adding additional test cases around things like combat, or existing card abilities. Be sure to check the Issues for this project to see if anything is open and listed there.
