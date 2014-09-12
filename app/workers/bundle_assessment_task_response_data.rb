class BundleAssessmentTaskResponseData
  @queue = :task_response_data

  def self.perform(question_id, generate_csv)
    @question = AssessmentQuestion.find(question_id)
    @task = @question.assessment_task
    @other_questions = @task.assessment_questions.where(assessment_question: nil)
    @activity = @task.activity_page
    @questions = (AssessmentQuestion.where(assessment_question: @question) << @question).rotate(-1) #bring the first variant back to front
    @responses = AssessmentQuestionResponse.includes(:task_response).where(assessment_question: @questions)

    #the records are loaded
    #*************************************Generate the spreadsheet!
    if generate_csv
      @all_responses = AssessmentQuestionResponse.includes(:task_response).where(assessment_question: @task.assessment_questions)

      response_book = Axlsx::Package.new
      wb = response_book.workbook

      taken_names = []
      @task.assessment_questions.each { |q|
        unless (type = q.question_type)=="freeResponse"
          correct_answer = ""
          JSON.parse(q.answers).each_with_index { |a, i|
            if a['correct']==true
              correct_answer+=(i+1).to_s+", "
            end
          }
          correct_answer = correct_answer.chomp(', ')
        end

        #prevent name collisions
        ws_title = q.title
        taken_names.push(ws_title)
        if taken_names.count(ws_title)>1
          ws_title = ws_title+"(#{taken_names.count(ws_title)})"
        end
        wb.add_worksheet(:name => ws_title) do |sheet|
          sheet.add_row ["School", "Class", "Student Number", (type=="freeResponse" ? "Response" : "Correct Response: #{correct_answer}")]
          @all_responses.where(assessment_question: q).each { |response|
            unless type=="freeResponse"
              ans_array=[]
              JSON.parse(response.selected).each { |r|
                ans_array.push(r+1)
              }
            else
              ans_array=[0]
            end
            unless ans_array == []
              ans_array.each { |x|
                sheet.add_row [response.task_response.student.school.name,
                               response.task_response.school_class.name,
                               response.task_response.student.id.to_s,
                               (type=="freeResponse" ? response.selected : x.to_s)]
              }
            else
              sheet.add_row [response.task_response.student.school.name,
                             response.task_response.school_class.name,
                             response.task_response.student.id.to_s,
                             "No Answer"]
            end
          }
        end
      }

      response_book.use_shared_strings = true
      speadsheet_title = "AssessmentTask_#{@task.id}_spreadsheet"
      begin
        sfile = File.open("tmp/#{speadsheet_title}.xlsx", "w")
        response_book.serialize(sfile)
      rescue IOError => e
        #something went wrong...
      ensure
        sfile.close unless sfile == nil
      end
    end
    #*************************************Finish loading for and generate the page
    @charts = []
    case @question.question_type
      when "singleAnswer"
        @questions.each { |q|
          response_hash = {}

          #Gather response data
          @responses.where(assessment_question: q).each { |r|
            if JSON.parse(r.selected) == []
              if response_hash["No Answer".to_sym].nil?
                response_hash.merge!("No Answer".to_sym => 1)
              else
                response_hash["No Answer".to_sym]+=1
              end
            else
              selected = JSON.parse(r.selected)[0]+1
              if response_hash["Answer #{selected}".to_sym].nil?
                response_hash.merge!("Answer #{selected}".to_sym => 1)
              else
                response_hash["Answer #{selected}".to_sym]+=1
              end
            end
          }

          #Gather correct answer
          correct_answer = ""
          JSON.parse(q.answers).each_with_index { |a, i|
            if a['correct']==true
              correct_answer=(i+1).to_s
            end
          }

          @charts.push(
              {:question_title => q.title,
               :chart => response_hash.sort,
               :correct_answer => correct_answer
              }
          )
        }
      when "multipleAnswers"
        @questions.each { |q|
          response_hash = {}

          #Gather response data
          @responses.where(assessment_question: q).each { |r|
            selected = ""
            JSON.parse(r.selected).sort.each { |x|
              selected+=(x+1).to_s+", "
            }
            if selected == ""
              if response_hash["No Answer".to_sym].nil?
                response_hash.merge!("No Answer".to_sym => 1)
              else
                response_hash["No Answer".to_sym]+=1
              end
            else
              selected = selected.chomp(', ')
              if response_hash["Answers: #{selected}".to_sym].nil?
                response_hash.merge!("Answers: #{selected}".to_sym => 1)
              else
                response_hash["Answers: #{selected}".to_sym]+=1
              end
            end
          }

          #Gather correct answer
          correct_answer = ""
          JSON.parse(q.answers).each_with_index { |a, i|
            if a['correct']==true
              correct_answer+=(i+1).to_s+", "
            end
          }
          correct_answer = correct_answer.chomp(', ')

          @charts.push(
              {:question_title => q.title,
               :chart => response_hash.sort,
               :correct_answer => correct_answer
              }
          )
        }
    end

    #*************************************render and save the webpage
    file_title = "AssessmentQuestion_#{question_id}_page.html"
    begin
      file = File.open("tmp/#{file_title}", "w")
      rendered_page = Renderer.new.renderer.render(
          :template => 'task_responses/taskresponsedata',
          :locals => {:@question => @question, :@task => @task,
                      :@other_questions => @other_questions,
                      :@activity => @activity,
                      :@questions => @questions,
                      :@responses => @responses,
                      :@charts => @charts}
      )

      file.write(rendered_page)
    rescue IOError => e
      #something went wrong...
    ensure
      file.close unless file == nil
    end
  end
end