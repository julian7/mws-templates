# Layout helper methods
module LayoutHelper
  def title(page_title)
    content_for(:title) { concat page_title }
  end
end
