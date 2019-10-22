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

  #param 'element' must be a ':attribute => identifier' pair
  #where the symbol is a valid find_element option
  #e.g.: 
  # :class => 'modal-dialog'
  # or :xpath => "//*[@class='modal-dialog']"
  def wait_for_invisiblity(element)
    wait = Selenium::WebDriver::Wait.new(:timeout => 10) 
    wait.until { 
      begin
          return !page.driver.browser.find_element(element).displayed?
      rescue #when the element is gone, trying to find it will generate an exception
          return true; 
      end
    }
  end

  def wait_for_path(a, timeout)
    wait = Selenium::WebDriver::Wait.new(:timeout => timeout) 
    puts "current_path: #{current_path}, a: #{a}"
    begin
      wait.until { a == current_path }
    rescue
      puts "on resceu current_path: #{current_path}, a: #{a}"
      Capybara.current_session.save_and_open_screenshot
      #Capybara.current_session.save_and_open_page
    end
  end

  def wait_for_accept_alert(timeout = 10)
    wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
    alert = wait.until { page.driver.browser.switch_to.alert }
    alert.accept
    sleep 2
  end

end