namespace :octopi do
  desc 'Mail Assessment Question Responses'
  task :mail_responses => :environment  do
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
        sheet.add_row ['School Name', 'Class Name', 'Student Number', 'Activity Name', 'Task Name', 'Question ID', 'Question Title', 'Question Type', 'Question Text', 'Correct IDs', 'Correct Texts', 'Selected Answer IDs', 'Selected Text', 'Free response text', 'Link to the Question']
        AssessmentQuestionResponse.all.each do |response|
          puts response.id
          if response.task_response.task.nil? ||
              response.assessment_question.nil? ||
              ([1, 3].include?(response.task_response.student.school.id) && !(response.task_response.school_class.id == 3)) ||
              response.task_response.student.is_a?(TestStudent)
            next
          end

          school_name = response.task_response.student.school.name
          class_name = response.task_response.school_class.name
          student_number = response.task_response.student.id
          activity_name = response.task_response.task.activity_page.title
          task_name = response.task_response.task.title
          question_id = response.assessment_question.id
          question_title = response.assessment_question.title
          question_type = response.assessment_question.question_type
          question_text = response.assessment_question.question_body.html_sanitize
          correct_ids = ''
          correct_texts = ''
          selected_ids = ''
          selected_texts = ''
          free_response_text = ''
          begin
            if question_type != 'freeResponse'
              temp = JSON.parse(response.selected)
              selected_ids = response.selected
              answer_texts = JSON.parse(response.assessment_question.answers).map { |x| {text: x['text'].html_sanitize, correct: x['correct']} }
              selected_texts = temp.map { |x| answer_texts[x]['text'] }
              selected_texts = selected_texts.to_json
              correct_texts = (answer_texts.select { |x| x[:correct] }).map { |x| x[:text] }
              correct_ids = (answer_texts.each_with_index.map { |x, i| [x[:correct], i] })
              correct_ids = correct_ids.select { |x| x[0] }
              correct_ids = correct_ids.map { |x| x[1] }
              correct_ids = correct_ids.to_json
            else
              free_response_text = response.selected
            end
          rescue
            free_response_text = response.selected
          end
          link = url_for(response.assessment_question)
          sheet.add_row [school_name, class_name, student_number, activity_name, task_name, question_id, question_title, question_type, question_text, correct_ids, correct_texts, selected_ids, selected_texts, free_response_text, link]
          rows+=1
        end
      end
      result.use_shared_strings = true
      puts "Processed #{rows} rows."
      spreadsheet
    end

    CSVMailer.csv('johan@henkens.com', 'Assessment Question Data', 'Here is the data, hopefully it works.\n', 'data.xls', get_data.to_stream.read).deliver
  end
end