namespace :octopi do
  desc 'Mail Taks to charlotte'
  task :mail_tasks => :environment do
    class String
      def html_sanitize
        ActionView::Base.full_sanitizer.sanitize(self)
      end
    end

    class CSVMailer < ActionMailer::Base
      def csv(recipient, subject, body, filename, data)
        attachments[filename] = data
        mail(from: 'donotreply@octopi.herokuapp.com', to: recipient, subject: subject, body: body)
      end
    end

    include Rails.application.routes.url_helpers
    default_url_options[:host] = 'octopi.herokuapp.com'

    def get_data
      spreadsheet = Axlsx::Package.new
      result = spreadsheet.workbook
      rows = 0
      result.add_worksheet(name: 'Responses') do |sheet|
        sheet.add_row ['TaskID', 'Module Title', 'Task Title', 'Task Modified at Date', 'Task Full Teacher Body', 'Task Sanitized Teacher Body', 'Task Full Student Body', 'Task Santized Student Body', 'Question Title', 'Question ID', 'Question Modified at date', 'Question Position', 'Question Type', 'Question Full Body', 'Question Sanitized Body', 'Answer ID', 'Answer Correct', 'Answer Text', 'Answer Text Sanitized']
        AssessmentQuestion.all.each do |question|
          task = question.assessment_task
          task_id = ''
          module_title = ''
          task_title = ''
          task_modified = ''
          t_teacher_body = ''
          t_teacher_sanitized = ''
          t_student_body = ''
          t_student_body_sanitized = ''
          unless task.nil?
            task_id = task.id
            module_title = task.activity_page.module_page.title
            task_title = task.title
            task_modified = task.updated_at
            t_teacher_body = task.teacher_body
            t_teacher_sanitized = t_teacher_body.html_sanitize
            t_student_body = task.student_body
            t_student_body_sanitized = t_student_body.html_sanitize
          end
          q_title = question.title
          q_id = question.id
          q_body = question.question_body
          q_body_sanitized = q_body.html_sanitize
          q_type = question.question_type
          q_position = question.position
          q_modified = question.updated_at
          (JSON.parse(question.answers)).each_with_index do |ans, a_id|
            a_text = ans['text']
            a_text_sanitized = a_text.html_sanitize
            a_correct = ans['correct']
            sheet.add_row [task_id, module_title, task_title, task_modified, t_teacher_body, t_teacher_sanitized, t_student_body, t_student_body_sanitized, q_title, q_id, q_modified, q_position, q_type, q_body, q_body_sanitized, a_id, a_correct, a_text, a_text_sanitized]
            rows+=1
          end
        end
      end
      result.use_shared_strings = true
      puts "Processed #{rows} rows."
      spreadsheet
    end

    CSVMailer.csv('johan@henkens.com, charlottehill@umail.ucsb.edu', 'Assessment Task Data', 'Here is the data, hopefully it works.\n', 'data.xls', get_data.to_stream.read).deliver
  end
end