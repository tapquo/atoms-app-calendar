"use strict"

__.Extension.Calendar = {}

class __.Extension.Calendar.Day extends Atoms.Class.Atom

  @template: """<span class="{{style}} {{#disabled}}disabled{{/disabled}}">{{day}}</span>"""

  @base    : "Day"

  @events   : ["touch"]

  @default  :
    events: ["touch"]
