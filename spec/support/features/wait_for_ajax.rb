# spec/support/wait_for_ajax.rb
# see: https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara

# Note: rarely used.  Is this useful?
# consider renaming this to wait_for_jquery

module Features
  # module name changed per: https://github.com/thoughtbot/suspenders/issues/142
  def wait_for_ajax
    # Timeout.timeout(5) do # increase timeout from 2 seconds to 5 seconds ?
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end

