class Student < User
  belongs_to :school, counter_cache: true
  has_and_belongs_to_many :school_classes, after_add: :verify_classes, join_table: 'school_classes_students'
  has_many :task_responses, :dependent => :destroy
  has_many :activity_unlocks, :dependent => :destroy
  validates :login_name, presence: true, length: {maximum: 50}, :uniqueness => {:scope => :school_id, :case_sensitive => false}
  validates :school, presence: true
  before_save { login_name.downcase! }
  before_create :create_remember_token
  before_destroy :delete_all_dependant_data
  attr_accessor :current_class
  attr_reader :current_password
  scope :not_teststudents, -> { where(type: 'Student') }

  has_secure_password


  def Student.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def Student.create_remember_hash(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def name
    "#{first_name} #{last_name}"
  end

  def update_with_password(params, *options)
    current_password = params.delete(:current_password)

    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    result = if self.authenticate(current_password)
               update_attributes(params, *options)
             else
               self.assign_attributes(params, *options)
               self.valid?
               self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
               false
             end
    self.password = self.password_confirmation = nil
    result
  end

  def change_school_class(original_class, new_class, delete_new_class_data_if_conflict)
    Student.transaction do
      task_responses.where(school_class: original_class).each { |response|
        conflict = TaskResponse.find_by(student: self, school_class: new_class, task: response.task)
        if conflict.nil?
          response.update_attribute(:school_class, new_class)
        else
          if delete_new_class_data_if_conflict
            conflict.destroy
            response.update_attribute(:school_class, new_class)
          else
            response.destroy
          end
        end
      }
      activity_unlocks.where(school_class: original_class).each { |unlock|
        conflict = ActivityUnlock.find_by(student: self, school_class: new_class, activity_page: unlock.activity_page)
        if conflict.nil?
          unlock.update_attribute(:school_class, new_class)
        else
          if delete_new_class_data_if_conflict
            conflict.destroy
            unlock.update_attribute(:school_class, new_class)
          else
            unlock.destroy
          end
        end
      }
      school_classes.delete(original_class)
      school_classes << new_class
    end
  end

  def soft_remove_from(school_class)
    school_classes.delete(school_class)
  end

  def delete_all_dependant_data
    school_classes.each { |school_class|
      delete_all_data_for(school_class)
    }
  end

  def delete_all_data_for(school_class)
    Student.transaction do
      task_responses.where(school_class: school_class).each { |response|
        response.destroy
      }
      activity_unlocks.each { |unlock|
        unlock.destroy
      }
      school_classes.delete(school_class)
    end
  end

  def reset_dependency_graph_for(school_class)
    Student.transaction do
      activity_unlocks.update_all(unlocked: false)
      task_responses.update_all(unlocked: false)
      school_class.module_pages.each do |module_page|
        module_page.activity_pages.each do |activity_page|
          if activity_page.prerequisites.count == 0
            activity_unlock = activity_unlocks.where(school_class: school_class, activity_page: activity_page).first_or_create
            activity_unlock.update(unlocked: true)
          end
          activity_page.tasks.each do |task|
            task_response = task_responses.find_by(school_class: school_class, task: task)
            unless task_response.nil?
              if task_response.completed == true
                task_response.update(unlocked: true)
                task_response.unlock_dependencies(true)
              elsif task.task_dependencies.count == 0
                task_response.update(unlocked: true)
              end
            else
              if task.prerequisites.count==0
                task.get_visibility_status_for(self, school_class)
              end
            end
          end
        end
      end
    end
  end

  private
  def create_remember_token
    self.remember_token = Student.create_remember_hash(Student.new_remember_token)
  end

  def verify_classes school_class
    raise ActiveRecord::RecordInvalid.new(self) if school_class.school_id != self.school_id
  end

  def self.role_adapter
    self.superclass.role_adapter
  end

end
