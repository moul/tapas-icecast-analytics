url = require 'url'
config = require '../../config'
Admin = require('icecast-admin').Admin

admins = {}
tree = {}
i = 0

updateNextAdmin = ->
    console.log 'updateNextAdmin'

exports.open = (app, tapas) ->
    tapas.io.on 'connection', (socket) ->
        console.log 'new io client'
        socket.on 'getTree', (fn = null) ->
            console.log 'getTree'
            fn tree

updateAdmin = (admin) ->
    console.log "updateAdmin #{admin.id}"
    admin.getStats (data) ->
        for source in data.icestats.source
            server_name = source['server_name'][0]
            branch = admin.branch[server_name] =
                id: admin.id
                server_name: server_name
            for key in ['listeners', 'slow_listeners', 'total_bytes_read', 'total_bytes_sent', 'title', 'bitrate', 'max_listeners']
                branch[key] = source[key][0]
        do updateNextAdmin

for group, servers of config.icecast_servers
    tree[group] = {}
    for server in servers
        id = url.parse(server).host
        branch = tree[group][id] = {}
        admin = admins[id] = new Admin
            url: server
        admin.id = id
        admin.branch = branch
        updateAdmin admin

exports.index = (req, res) ->
    res.render 'analytics'
