# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

PagesController = Paloma.controller('Pages/Pages')
AssessmentController = Paloma.controller('Pages/AssessmentQuestion')
AssessmentController.prototype.show = () ->
  PagesController.prototype.show()
  enableSubmitButton = PagesController.prototype.enableSubmitButton
  inline = PagesController.prototype.ckeditor_inline

  addPageViewSelectorCallback = () ->
    #add new answer
    $("#addAns").click ->
      enableSubmitButton()
      str = "<div class = 'answer'> <div class = 'answerHead'>This answer is correct:\n<input type = '"
      str += if $('#ansType').val() is 'singleAnswer' then 'radio' else 'checkbox'
      str += "' class = 'choices' name='answerChoice'>
      <button class='deleteAnswer'>Remove Answer</button>
      </div>
      <div class = 'answerBox'>
      <div class='octopieditable answerText'>
      <p></p>
      </div>
      </div>
      </div>"
      node = $("#answerList").append(str)
      node.children().last().find(".octopieditable").each ->
        inline(this)
      node.find('input.choices').change ->
        choicesChangeListener()
      node.find('button.deleteAnswer').click ->
        deleteAnswerListener(this)

    updateHeaderClasses = (obj) ->
      obj = $(obj)
      if obj.prop("checked")
        obj.parent().addClass('checked')
      else
        obj.parent().removeClass('checked')

    choicesChangeListener = () ->
      $('input.choices').each( ->
        enableSubmitButton()
        updateHeaderClasses(this)
      )

    #change color of header
    $('input.choices').change ->
      choicesChangeListener()

    #change question type
    $("#ansType").change ->
      enableSubmitButton()
      switch $(this).val()
        when "singleAnswer"
          $("#answerList").show()
          $("#addAns").show()
          $("#free-response-note").hide()
          $(".answerHead input").each ->
            $(this).attr "type", "radio"
            $(this).prop "checked", false
            $(this).change()

        when "multipleAnswers"
          $("#answerList").show()
          $("#addAns").show()
          $("#free-response-note").hide()
          $(".answerHead input").each ->
            $(this).attr "type", "checkbox"
            $(this).prop "checked", false
            $(this).change()

        when "freeResponse"
          $("#answerList").hide()
          $("#addAns").hide()
          $("#free-response-note").show().removeClass("hidden")
        else

        #remove an answer
    deleteAnswerListener = (obj) ->
      if confirm("Are you sure you want to remove this answer?")
        enableSubmitButton()
        $(obj).parent().parent().remove()

    $('button.deleteAnswer').click () ->
      deleteAnswerListener(this)

    submitFunction = () ->
      question_body = $('#question-body').html()
      question_type = $('#ansType').val();
      hasAnAnswer = false
      ansArray = []

      if question_type is "freeResponse"
        hasAnAnswer = true
      else
        $(".choices").each ->
          ansObj =
            text: ""
            correct: false

          if $(this).prop("checked") is true
            ansObj.correct = true
            hasAnAnswer = true
          ansArray.push ansObj
          return

        $(".answerText").each (index) ->
          ansArray[index].text = $(this).html()
          return

      title = $('#page-title').html()

      if hasAnAnswer and title isnt ""
        $(this).find('.title').val(title)
        $(this).find('.question_body').val(question_body)
        $(this).find('.question_type').val(question_type)
        $(this).find(".answers").val JSON.stringify(ansArray)
      else
        if title is ""
          alert "Title cannot be blank"
        else
          alert "A question must have at least one correct answer."
        return false
      return true;
    $('form.page-form').unbind('submit')
    $('form.page-form').submit(submitFunction)

  $(document).ready(addPageViewSelectorCallback);
  $(document).ready()

