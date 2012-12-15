cols =
    listeners: "Listeners"
    slow_listeners: "Slow listeners"
    total_bytes_read: "Total bytes read"
    total_bytes_sent: "Total bytes sent"
    title: "Title"
    bitrate: "Bitrate"

updateServer = (server) ->
    for id, mount of server
        console.log mount
        tr = $("tr[data-rid=\"#{mount.id}#{mount.server_name}\"]")
        tds = tr.find('td')
        i = 1
        for key, value of cols
            $(tds[i++]).html mount[key]

createTable = (tree) ->
    table = $('#stats')
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
                #console.log mount
                tr = $('<tr/>').attr('data-rid', "#{mount.id}#{mount.server_name}")
                tr.append $('<td/>').html mount_name
                for key, value of cols
                    tr.append $('<td/>').html('')
                tbody.append tr
            table.append tbody
            updateServer mounts

$(document).ready ->
    socket = do io.connect

    socket.on 'connect', ->
        socket.emit 'getTree', createTable

    socket.on 'updateServer', updateServer
