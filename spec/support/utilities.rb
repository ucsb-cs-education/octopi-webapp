include ApplicationHelper

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

