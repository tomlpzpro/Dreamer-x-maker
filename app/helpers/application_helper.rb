module ApplicationHelper
  # The status tag shown over a project card (positioned with "card-status").
  def project_step_tag(project)
    status = project.matched? ? "status-accepted" : "status-pending"
    tag.span(project.status_label, class: "card-status status-badge #{status}")
  end

  # Shows a 1-to-5 rating as gold filled stars + gray empty stars.
  def rating_stars(rating)
    rating = rating.to_i
    safe_join([
      tag.span("★" * rating, class: "rating-stars-filled"),
      tag.span("★" * (5 - rating), class: "rating-stars-empty")
    ])
  end
end
