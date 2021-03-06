class ActivePopulationLookup < PopulationsBase

  expected_element :keyword

  def frm
    self.frame(class: "fancybox-iframe")
  end

  include PopulationsSearch

  population_lookup_elements
  green_search_buttons
  element(:paginate_links_span) { |b| b.frm.div(class: "dataTables_paginate paging_full_numbers").span() }

  def change_results_page(page_number)
    results_table.wait_until_present
   paginate_links_span.link(text: "#{page_number}").click
  end
end