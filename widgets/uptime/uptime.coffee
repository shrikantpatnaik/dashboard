class Dashing.Uptime extends Dashing.Widget
  @current_data = []
  ready: ->
    $('.item_row').remove()
    for monitor in @current_data.items
      $('tr.header').after(@createRow(monitor))

  onData: (data) ->
    @current_data = data
    $('.item_row').remove()
    for monitor in data.items
      $('tr.header').after(@createRow(monitor))

  createRow: (monitor) ->
    cssClass = if monitor.status == "9" then "down" else ""
    return "<tr class=\"#{cssClass} item_row\"><td class=\"name\">#{monitor.name}</td><td class=\"response\">#{monitor.response_time}</td><td class=\"uptime\">#{monitor.uptime}</td></tr>"
