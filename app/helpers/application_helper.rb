module ApplicationHelper
  def sidebar_nav_link_classes(path)
    current_page?(path) ? "bg-primary-soft text-primary font-medium" : "text-ink hover:bg-canvas"
  end
end
