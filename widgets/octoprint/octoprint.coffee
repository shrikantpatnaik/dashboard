class Dashing.Octoprint extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    if data.state != "Printing"
        $(@node).find('.current_job').hide()
    else
        $(@node).find('.current_job').show()
