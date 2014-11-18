namespace :octopi do
  desc 'Mail Assessment Question Responses'
  task :mail_responses => :environment do
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
        sheet.add_row ['School Name', 'Class Name', 'Student Number', 'Activity Name', 'Activity ID', 'Task Name', 'Task ID', 'Question ID', 'Question Title', 'Question Type', 'Question Text', 'Response Date', 'Task Version Date', 'Task Version ID', 'Versioning Worked', 'All Answer Texts', 'All Answer Texts Raw', 'Correct IDs', 'Correct Texts', 'Correct Texts Raw', 'Selected Answer IDs', 'Selected Text', 'Selected Texts raw','Free response text']
        AssessmentQuestionResponse.all.each do |response|
          puts response.id
          if response.assessment_question.nil? ||
              ([1, 3].include?(response.task_response.student.school.id) && !(response.task_response.school_class.id == 3)) ||
              response.task_response.student.is_a?(TestStudent)
            next
          end
          tr = response.task_response
          version_date = tr.version_date
          versioning_worked = 'false'
          if tr.version_date
            tv = tr.task.versions.where(created_at: version_date).first
            version_id = tv.id
            t = tv.reify
            cv = PaperTrail::Version.where(id: JSON.parse(tv.child_versions).map { |x| x['version_id'] }).where(item_id: response.assessment_question_id, item_type: 'AssessmentQuestion')
            q = cv.first.reify
            versioning_worked = 'true'
          else
            t = tr.task
            q = response.assessment_question
            version_date = 'nil'
            version_id = 'nil'
          end

          school_name = tr.student.school.name
          class_name = tr.school_class.name
          student_number = tr.student.id
          activity_name = 'nil'
          activity_id = 'nil'
          task_name = 'nil'
          task_id = 'nil'
          unless t.nil?
            unless t.activity_page.nil?
              activity_name = t.activity_page.title
              activity_id = t.activity_page.id
            end
            task_name = t.title
            task_id = t.id
          end
          question_id = q.id
          question_title = q.title
          question_type = q.question_type
          question_text = q.question_body.html_sanitize
          response_date = response.created_at
          correct_ids = ''
          correct_texts = ''
          correct_texts_raw = ''
          selected_ids = ''
          selected_texts = ''
          selected_texts_raw = ''
          all_texts = ''
          all_texts_raw = ''
          free_response_text = ''
          begin
            if question_type != 'freeResponse'
              temp = JSON.parse(response.selected)
              selected_ids = response.selected
              answer_texts = JSON.parse(response.assessment_question.answers).map { |x| {text: x['text'].html_sanitize, correct: x['correct'], raw_text: x['text']} }
              all_texts = answer_texts.map { |x| x[:text] }.to_json
              all_texts_raw = answer_texts.map { |x| x[:raw_text] }.to_json
              selected_texts = temp.map { |x| answer_texts[x][:text] }.to_json
              selected_texts_raw = temp.map { |x| answer_texts[x][:raw_text] }.to_json
              correct_texts = (answer_texts.select { |x| x[:correct] }).map { |x| x[:text] }.to_json
              correct_texts_raw = (answer_texts.select { |x| x[:correct] }).map { |x| x[:raw_text] }.to_json
              correct_ids = (answer_texts.each_with_index.map { |x, i| [x[:correct], i] })
              correct_ids = correct_ids.select { |x| x[0] }
              correct_ids = correct_ids.map { |x| x[1] }
              correct_ids = correct_ids.to_json
            else
              free_response_text = response.selected
            end
          rescue
            free_respose_text = response.selected
          end
         sheet.add_row [school_name, class_name, student_number, activity_name, activity_id, task_name, task_id, question_id, question_title, question_type, question_text, response_date, version_date, version_id, versioning_worked, all_texts, all_texts_raw, correct_ids, correct_texts, correct_texts_raw, selected_ids, selected_texts, selected_texts_raw, free_response_text]
          rows+=1
        end
      end
      result.use_shared_strings = true
      puts "Processed #{rows} rows."
      spreadsheet
    end

    CSVMailer.csv('johan@henkens.com, charlottehill@umail.ucsb.edu', 'Octopi Student Assessment Responses', 'Here is the data, hopefully it works.\n', 'data.xls', get_data.to_stream.read).deliver
  end
end