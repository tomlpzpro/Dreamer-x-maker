module ApplicationHelper
  # Number of fun background colors (must match the palette in _card.scss).
  FUN_BG_COUNT = 8

  # A fun, stable background class for a record's visual. Based on the id so a
  # given project always keeps the same color (no flicker on reload).
  def fun_bg_class(record)
    "fun-bg-#{record.id % FUN_BG_COUNT}"
  end
end
