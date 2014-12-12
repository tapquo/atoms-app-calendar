###
@TODO

@namespace Atoms.Molecule
@class Calendar

@author Javier Jimenez Villar @soyjavi
###
"use strict"

class Atoms.Molecule.Calendar extends Atoms.Molecule.Div

  @extends    : true
  @available  : ["Atom.Day", "Molecule.Div"]
  @events     : ["select"]
  @default    :
    months: ["January", "February", "March", "April", "May", "June", "July",
             "August", "September", "October", "November", "December"]
    days  : ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    children: [
      "Molecule.Div": id: "header", children: [
        "Atom.Button": icon:"angle-left", style: "transparent", callbacks: ["onPreviousMonth"]
      ,
        "Atom.Heading": id: "literal", value: "Year", size: "h4"
      ,
        "Atom.Button": icon:"angle-right", style: "transparent", callbacks: ["onNextMonth"]
      ]
    ]
  @child_class: "App.Extension.Calendar.Day"

  constructor: (attributes = {}) ->
    for key in ["months", "days"] when not attributes[key]
      attributes[key] = @constructor.default[key]
    super attributes
    @events = {}
    @today = new Date()
    @today = new Date(@today.getFullYear(), @today.getMonth(), @today.getDate())
    @date new Date attributes.date or @today

  refresh: ->
    super
    @date new Date @attributes.date or @today

  # -- Instance methods  ----------------------------------------------------------
  date: (@current = new Date()) -> @_showMonth @current

  setEvent: (values, data = {}) ->
    values = [values] unless Array.isArray(values)
    for value in values
      @events[value] = data
      @_find(value)?.setEvent?(data)

  removeEvent: (values) ->
    values = [values] unless Array.isArray(values)
    for value in values
      delete @events[value]
      @_find(value)?.removeEvent?()

  removeAllEvents: ->
    @events = []
    @date @current

  # -- Bubble Children Events --------------------------------------------------
  onPreviousMonth: ->
    @_showMonth @_previousMonth()
    false

  onNextMonth: ->
    @_showMonth @_nextMonth()
    false

  onDayTouch: (event, atom) ->
    atom.el
      .addClass "active"
      .siblings()?.removeClass "active"
    if atom.attributes.date.getMonth() isnt @current.getMonth()
      @date atom.attributes.date
    else
      @current = atom.attributes.date
    @bubble "select", atom
    false

  # -- Private Events ----------------------------------------------------------
  _showMonth: (date) ->
    @year = date.getFullYear()
    @month = date.getMonth()

    # Header
    @header.literal.el.html "#{@attributes.months[@month]} <small>#{@year}</small>"
    @el.removeClass key for key in ["disabled", "disable_previous_days"]
    @el.addClass "disabled" if @attributes.disabled
    if @attributes.disable_previous_days and @month is new Date().getMonth()
      @el.addClass "disable_previous_days"

    child.destroy() for child in @children when child?.constructor.name is "Day"
    @children = [@children[0]]

    # Days header
    for day in @attributes.days
      @appendChild @constructor.child_class, day: day, summary: true

    # Previous Month visible Days
    first_day_of_month = new Date(@year, @month).getDay() - 1
    first_day_of_month = 6 if first_day_of_month < 0
    previous_month = @_previousMonth()
    previous_days = @_daysInMonth(previous_month) - (first_day_of_month - 1)
    for day in [0...first_day_of_month]
      @appendChild @constructor.child_class,
        day     : previous_days
        current : false
      previous_days++

    # Current Month Days
    for day in [1..@_daysInMonth(date)]
      date = new Date(@year, @month, day)
      values =
        day   : day
        date  : date
        month : true
        today : @today.toString().substring(4, 15) is date.toString().substring(4, 15)
        active: @current.toString().substring(4, 15) is date.toString().substring(4, 15)
      values.event = @events[date] if @events[date]?
      values.events = ["touch"] if @_active date
      @appendChild @constructor.child_class, values

    # Next Month visible Days
    last_day_of_month = new Date(@year, @month, @_daysInMonth(date)).getDay()
    day = 1
    for index in [6..last_day_of_month]
      @appendChild @constructor.child_class,
        day     : day
        current : false
      day++

  _previousMonth: -> new Date @year, (@month - 1), 1

  _nextMonth: -> new Date @year, (@month + 1), 1

  _daysInMonth: (date) ->
    32 - new Date(date.getYear(), date.getMonth(), 32).getDate()

  _find: (date) ->
    return day for day in @children when date - day.attributes.date is 0

  _active: (date) ->
    return false if @attributes.disable_previous_days and date < @today
    format_date = @_format date
    return false if @attributes.available? and format_date not in @attributes.available
    return false if @attributes.from? and @attributes.from > format_date
    return false if @attributes.to? and @attributes.to < format_date
    return true

  _format: (date) ->
    date = new Date(date)
    str = "#{date.getFullYear()}/"
    month = date.getMonth() + 1
    str += if month < 10 then "0#{month}/" else "#{month}/"
    day = date.getDate()
    str += if day < 10 then "0#{day}" else "#{day}"
    str
