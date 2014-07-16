include ApplicationHelper
require 'timeout'
require 'html/sanitizer'

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-danger', text: message)
  end
end

RSpec::Matchers.define :have_warning_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-warning', text: message)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-success', text: message)
  end
end

def valid_session
  {"warden.user.user.key" => session["warden.user.user.key"]}
end

def wait_for_ajax
  wait_until do
    page.evaluate_script('jQuery.active') == 0
  end
end

def wait_until
  Timeout.timeout(Capybara.default_wait_time) do
    sleep(0.1) until yield == true
  end
end

def wait_for_and_click_on_button button
  wait_until do
    page.has_button?(button)
  end
  click_on(button)
end

def clear_text_box(textbox)
  textbox.set('')
  textbox.click
  textbox.native.send_keys(:delete)
end

module RSpecSanitizer
  def self.sanitize(string)
    @sanitizer ||= HTML::FullSanitizer.new
    @sanitizer.sanitize(string)
  end
end
