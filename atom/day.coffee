"use strict"

__.Extension.Calendar = {}

class __.Extension.Calendar.Day extends Atoms.Class.Atom

  @template : """<span class="{{style}}{{^events}} disabled{{/events}}{{#today}} today{{/today}}{{#active}} active{{/active}}{{#if.event}} event{{/if.event}}{{#if.month}} month{{/if.month}}">{{day}}</span>"""
  @base     : "Day"
  @events   : ["touch"]

  # -- Instance Methods --------------------------------------------------------
  setEvent: (value) ->
    @attributes.event = value
    @el.addClass "event"

  removeEvent: ->
    delete @attributes.event
    @el.removeClass "event"
