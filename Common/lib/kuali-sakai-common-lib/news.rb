module NewsMethods
  include PageObject
  def self.page_elements(identifier)
    in_frame(identifier) do |frame|

    end
  end
end