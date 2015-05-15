class User < ActiveRecord::Base
  rolify
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  alias_attribute :password_digest, :encrypted_password

  alias_method :rolify_add_role, :add_role

  def add_role(*options)
    self.becomes(User).rolify_add_role(*options)
  end

  def name
    "#{first_name} #{last_name}"
  end

  def self.options_for_sorted_by
    [
        ['User ID (Smallest First)', 'id_asc'],
        ['User ID (Largest First)', 'id_desc']
    ]
  end
    filterrific(
        default_filter_params: {sorted_by: 'id_asc'},
        available_filters:[
            :user_query,
            :sorted_by,
            :with_school_id,
            :with_class_id
        ])

  scope :with_school_id, lambda { |school_ids|
                          where(school_id: [*school_ids])
                        }
  scope :with_class_id, lambda { |class_id|
                            where('id IN (select student_id FROM (select * FROM school_classes_students WHERE school_class_id = ?) AS tmp)',class_id)
                          }
  scope :sorted_by, lambda {|sort_option|
                    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
                    order("users.id #{direction}")
                  }

  scope :user_query, lambda { |query|

                       return nil  if query.blank?

                       # condition query, parse into individual keywords
                       query = query.to_s
                       terms = query.downcase.split(/\s+/)

                       # replace "*" with "%" for wildcard searches,
                       # append '%', remove duplicate '%'s
                       terms = terms.map { |e|
                         (e.gsub('*', '%') + '%').gsub(/%+/, '%')
                       }
                       # configure number of OR conditions for provision
                       # of interpolation arguments. Adjust this if you
                       # change the number of OR conditions.
                       num_or_conds = 3
                       where(
                           terms.map { |term|
                             "(LOWER(users.first_name) LIKE ? OR LOWER(users.last_name) LIKE ? OR CAST(users.id as varchar) LIKE ?)"
                           }.join(' AND '),
                           *terms.map { |e| [e] * num_or_conds }.flatten
                       )
                     }

end
