"use strict"

__.Extension.Calendar = {}

class __.Extension.Calendar.Day extends Atoms.Class.Atom

  @template : """<span class="{{style}} {{#disabled}}disabled{{/disabled}} {{#today}}today{{/today}} {{#active}}active{{/active}} {{#event}}event{{/event}}">{{day}}</span>"""

  @base     : "Day"

  @events   : ["touch"]

  @default  :
    events: ["touch"]
