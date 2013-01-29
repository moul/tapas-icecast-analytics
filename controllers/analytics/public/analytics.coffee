options = {}

cols =
  listeners: "Listeners"
  slow_listeners: "Slow listeners"
  total_bytes_read: "Total bytes read"
  total_bytes_sent: "Total bytes sent"
  title: "Title"
  bitrate: "Bitrate"

total =
  listeners:    {}
  slow_listeners: {}
  total_bytes_sent: {}
  total_bytes_read: {}

file_size_keys = [
  "total_bytes_sent"
  "total_bytes_read"
]

formatFileSize = (nb) ->
    NumberHelpers.number_to_human_size nb,
        precision: 5

updateServer = (server) ->
  for id, mount of server
    if options.mounts?.length && mount.server_name not in options.mounts
      continue
    mount_uuid = "#{mount.id}#{mount.server_name}"
    #console.log mount
    tr = $("tr[data-rid=\"#{mount_uuid}\"]")
    tds = tr.find('td')
    i = 0
    for key, value of cols
      if key of total
        total[key][mount_uuid] = parseInt mount[key]
      td = $(tds[i++])
      if !mount[key]? or mount[key] == '0'
        td.addClass 'nullvalue'
      else
        td.removeClass 'nullvalue'
      oldValue = td.html()
      if mount[key]? and oldValue != mount[key]
        mount[key] = formatFileSize mount[key] if key in file_size_keys
        td.html mount[key]
        td.fadeTo(100, 1).fadeTo(700, 0.3)
  tds = $('tfoot').find('td')
  i = 0
  for key, value of cols
    td = $(tds[i++])
    if key of total
      tot = 0
      for mount_uuid, amount of total[key]
        tot += amount
      if key in file_size_keys
        tot = formatFileSize tot
      td.html tot

createTable = (tree) ->
  table = $('#stats')
  table.empty()
  for group, servers of tree
    for id, mounts of servers
      thead = $('<thead/>')
      tr = $('<tr/>')
      tr.append $('<th/>').html id
      for key, value of cols
        tr.append $('<th/>').html value
      thead.append tr
      table.append thead
      tbody = $('<tbody/>')
      for mount_name, mount of mounts
        if options.mounts?.length && mount.server_name not in options.mounts
          continue
        #console.log mount
        tr = $('<tr/>').attr('data-rid', "#{mount.id}#{mount.server_name}")
        tr.append $('<th/>').html mount_name
        for key, value of cols
          tr.append $('<td/>').html('')
        tbody.append tr
      table.append tbody
      updateServer mounts
  tfoot = $('<tfoot/>')
  tr = $('<tr />')
  tr.append $('<th/>').html 'Total'
  for key, value of cols
    tr.append $('<td/>').html('')
  tfoot.append tr
  table.append tfoot


$(document).ready ->
  options.mounts = $('meta[name="mounts"]').attr('content').split(/,/) || false
  options.mounts = false if options.mounts.length == 1 and options.mounts[0] is ""
  socket = do io.connect

  socket.on 'connect', ->
    socket.emit 'getTree', createTable

  socket.on 'updateServer', updateServer
