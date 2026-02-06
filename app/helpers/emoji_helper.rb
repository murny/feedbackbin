# frozen_string_literal: true

module EmojiHelper
  REACTION_KEYS = {
    "\u{1F44D}" => :thumbs_up,
    "\u{1F44E}" => :thumbs_down,
    "\u{1F604}" => :smile,
    "\u{1F389}" => :party_popper,
    "\u{1F615}" => :confused,
    "\u{2764}\u{FE0F}" => :heart,
    "\u{1F680}" => :rocket,
    "\u{1F440}" => :eyes
  }.freeze

  def self.reactions
    REACTION_KEYS.transform_values { |key| I18n.t("reactions.emojis.#{key}") }
  end
end
