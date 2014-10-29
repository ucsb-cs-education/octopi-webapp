class OctopiDeviseMailer < Devise::Mailer

  def confirmation_instructions(record, token, opts={})
    opts[:reply_to] = 'octopi@lists.cs.ucsb.edu'
    super
  end

  def reset_password_instructions(record, token, opts={})
    opts[:reply_to] = 'octopi@lists.cs.ucsb.edu'
    super
  end

  def unlock_instructions(record, token, opts={})
    opts[:reply_to] = 'octopi@lists.cs.ucsb.edu'
    super
  end

end