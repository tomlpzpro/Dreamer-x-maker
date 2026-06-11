module ApplicationHelper
  # The status tag shown over a project card (positioned with "card-status").
  def project_step_tag(project)
    status = project.matched? ? "status-accepted" : "status-pending"
    tag.span(project.status_label, class: "card-status status-badge #{status}")
  end
end
