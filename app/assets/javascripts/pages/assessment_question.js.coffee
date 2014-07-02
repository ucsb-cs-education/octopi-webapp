# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

PagesController = Paloma.controller('Pages/AssessmentQuestion');
PagesController.prototype.show = () ->

  enableSubmitButton = () ->
    $('.page-form input[type=submit]').removeAttr('disabled');
  window.enableUpdateButton = enableSubmitButton;

  addPageViewSelectorCallback = () ->
    CKEDITOR.disableAutoInline = true;

    inline = (element) ->
      $(element).attr("contenteditable", true)
      CKEDITOR.inline( element, {
        toolbar:'Pure',
        on: {
          blur: enableSubmitButton
        }
      });

    window.ckeditor_inline = inline

    $("div.octopieditable").each( () ->
      inline(this)
    )

    $("#tabs").tabs({
      activate: (event, ui) ->
        if ui.newPanel.attr("contenteditable") is "false"
          for name of CKEDITOR.instances
            instance = CKEDITOR.instances[name]
            instance.destroy()  if ui.newPanel and ui.newPanel.is($(instance.element.$))
          ui.newPanel.attr("contenteditable", true)
          ui.newPanel.each( () ->
            editor = inline(this)
          )
    });
    $("#children").sortable({
      placeholder: "ui-state-highlight",
      axis: 'y',
      update: enableSubmitButton
    });
    $("#children").disableSelection();

    #add new answer
    $("#addAns").click ->
      window.enableUpdateButton()
      str = "<div class = 'answer'> <div class = 'answerHead isNotchecked'>This answer is correct:"
      if $("#ansType").val() is "singleAnswer"
        str += "<input type = 'radio' class = 'choices' name='answerChoice'>"
      else
        str += "<input type = 'checkbox' class = 'choices' name='answerChoice'>"
      str += "<button class='deleteAnswer'>Remove Answer</button></div> <div class = 'answerBox'> <div class='octopieditable answerText'></div></div></div>"
      $("#answerList").append(str).children().last().find(".octopieditable").each ->
        window.ckeditor_inline this
        return

      return


    #change color of header
    $(document).on "change", ".choices", ->
      window.enableUpdateButton()
      $(".choices").each ->
        if $(this).prop("checked") is true
          switchClass $(this).parent(), "isNotchecked", "ischecked"
        else
          switchClass $(this).parent(), "ischecked", "isNotchecked"
        return

      return

    switchClass = (who, class1, class2) ->
      $(who).removeClass(class1).addClass class2  if $(who).hasClass(class1)
      return

    #change question type
    $("#ansType").change ->
      window.enableUpdateButton()
      if $(this).val() is "singleAnswer"
        $(".answerHead input").each ->
          $(this).attr "type", "radio"
          $(this).prop "checked", false
          switchClass $(this).parent(), "ischecked", "isNotchecked"
          return

      else if $(this).val() is "multipleAnswers"
        $(".answerHead input").each ->
          $(this).attr "type", "checkbox"
          $(this).prop "checked", false
          switchClass $(this).parent(), "ischecked", "isNotchecked"
          return

      return

  #remove an answer
    $(document).on "click", ".deleteAnswer", ->
      if confirm("Are you sure you want to remove this answer?")
        window.enableUpdateButton()
        $(this).parent().parent().remove()
      return

    submitFunction = () ->
      question_body = $('#question-body').html()
      question_type = $('#ansType').val();
      hasAnAnswer = false
      ansArray = []
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


      if hasAnAnswer is true
        $(this).find('.title').val(title)
        $(this).find('.question_body').val(question_body)
        $(this).find('.questionType').val(question_type)
        $(this).find(".answers").val JSON.stringify(ansArray)
      else
        alert "A question must have at least one correct answer."
        return false
      return true;


    $('.page form ').submit(submitFunction)

  $(document).ready(addPageViewSelectorCallback);
  $(document).ready()

