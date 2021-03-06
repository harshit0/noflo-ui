noflo = require 'noflo'
debug = require('debug') 'noflo-ui:state'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'action',
    datatype: 'all'
  c.inPorts.add 'state',
    datatype: 'object'
  c.outPorts.add 'pass',
    datatype: 'object'

  c.inPorts.state.on 'data', (state) ->
    c.state = state

  c.state = {}
  c.shutdown = ->
    c.state = {}
  noflo.helpers.WirePattern c,
    in: 'action'
    out: 'pass'
    forwardGroups: true
    async: true
  , (data, groups, out, callback) ->
    if data?.state
      # Keep track of last state
      c.state = data.state
    else
      # Warn of actions that don't contain state
      debug "#{groups.join(':')} was sent without state, using previous state"
    state = data?.state or c.state
    payload = data?.payload or data
    out.send
      action: groups.join ':'
      state: state
      payload: payload
    do callback
