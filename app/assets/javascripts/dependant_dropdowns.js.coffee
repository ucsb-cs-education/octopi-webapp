updateDropDowns = ->
  $("select[data-option-dependent=true]").each (i) ->
    observer_dom_id = $(this).attr("id")
    observed_dom_id = $(this).data("option-observed")
    url_mask = $(this).data("option-url")
    key_method = $(this).data("option-key-method")
    value_method = $(this).data("option-value-method")
    prompt = $(this).data("option-placeholder")
    if typeof (prompt) is "undefined"
      prompt = (if $(this).has("option[value='']").size() then $(this).find("option[value='']") else $("<option value=\"\">").text("Please select from the above drop down first"))
    else
      prompt = $("<option value=\"\">").text(prompt)
    empty_prompt = $(this).data("option-empty-placeholder")
    if typeof (empty_prompt) is "undefined"
      empty_prompt = prompt
    else
      empty_prompt = $("<option value=\"\">").text(empty_prompt)
    regexp = /:[0-9a-zA-Z_]+:/g
    observer = $("select#" + observer_dom_id)
    observed = $("#" + observed_dom_id)
    observer.attr "disabled", true  unless observer.val() || observed.size() <= 1
    observed.on "change", ->
      observer.empty()
      observer.attr 'disabled', true
      observer.change()
      if observed.val()
        observer.append $("<option value=\"\">").text("Loading...")
        url = url_mask.replace(regexp, observed.val())
        $.getJSON url, (data) ->
          observer.empty().append prompt
          $.each data, (i, object) ->
            observer.append $("<option>").attr("value", object[key_method]).text(object[value_method])
            observer.attr "disabled", false
      else
        observer.append empty_prompt
      observer.change()

$(document).ready updateDropDowns