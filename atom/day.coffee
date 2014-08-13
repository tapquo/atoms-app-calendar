"use strict"

__.Extension.Calendar = {}

class __.Extension.Calendar.Day extends Atoms.Class.Atom

  @template : """<span class="{{style}} {{#disabled}}disabled{{/disabled}} {{#today}}today{{/today}} {{#active}}active{{/active}} {{#if.event}}event{{/if.event}}">{{day}}</span>"""

  @base     : "Day"

  @events   : ["touch"]

  @default  :
    events: ["touch"]

  # -- Instance Methods --------------------------------------------------------
  setEvent: (value) ->
    @refresh event: value

  removeEvent: ->
    @refresh event: undefined
