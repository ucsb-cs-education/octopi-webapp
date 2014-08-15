class UserMailer < ActionMailer::Base
  default from: 'admin@octopi.herokuapp.com'

  def generated_password_email(user)
    @user = user
    @password = user.password
    mail(to: "#{@user.name} <#{@user.email}>", subject: 'Octopi Login Information')
  end
end