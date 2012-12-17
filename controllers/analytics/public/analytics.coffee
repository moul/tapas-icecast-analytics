cols =
    listeners: "Listeners"
    slow_listeners: "Slow listeners"
    total_bytes_read: "Total bytes read"
    total_bytes_sent: "Total bytes sent"
    title: "Title"
    bitrate: "Bitrate"

total =
    listeners:      {}
    slow_listeners: {}

updateServer = (server) ->
    for id, mount of server
        mount_uuid = "#{mount.id}#{mount.server_name}"
        #console.log mount
        tr = $("tr[data-rid=\"#{mount_uuid}\"]")
        tds = tr.find('td')
        i = 0
        for key, value of cols
            if key of total
                total[key][mount_uuid] = parseInt mount[key]
            td = $(tds[i++])
            if mount[key] == '0'
                td.addClass 'nullvalue'
            else
                td.removeClass 'nullvalue'
            td.html mount[key]
    tds = $('tfoot').find('td')
    i = 0
    for key, value of cols
        td = $(tds[i++])
        if key of total
            tot = 0
            for mount_uuid, amount of total[key]
                tot += amount
            td.html tot

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
    socket = do io.connect

    socket.on 'connect', ->
        socket.emit 'getTree', createTable

    socket.on 'updateServer', updateServer
