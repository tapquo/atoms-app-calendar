###
@TODO

@namespace Atoms.Molecule
@class Calendar

@author Javier Jimenez Villar @soyjavi
###
"use strict"

class Atoms.Molecule.Calendar extends Atoms.Molecule.Div

  @extends    : true
  @available  : ["Atom.Day", "Atom.Heading"]
  @events     : ["select"]
  @default    :
    months: ["January", "February", "March", "April", "May", "June", "July",
             "August", "September", "October", "November", "December"]
    days  : ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    children: [
      "Atom.Heading": id: "literal", value: "Year", size: "h4"
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


  date: (@current = new Date()) ->
    child.destroy() for child in @children when child.constructor.name is "Day"

    day = @current.getDate()
    month = @current.getMonth()
    year = @current.getFullYear()

    @literal.el.html "#{@attributes.months[month]} <small>#{year}</small>"

    # Days header
    for day in @attributes.days
      @appendChild @constructor.child_class, day: day, events: undefined

    # Previous Month visible Days
    first_day_of_month = new Date(year, month).getDay() - 1
    first_day_of_month = 7 if first_day_of_month is 0
    previous_month = @_previousMonth month, year
    previous_days = @_daysInMonth(previous_month) - (first_day_of_month - 1)
    for day in [0...first_day_of_month]
      values =
        day     : previous_days
        date    : new Date previous_month.setDate previous_days
        disabled: true
      values.events = undefined if not(@_active date) or @attributes.disabled
      @appendChild @constructor.child_class, values
      previous_days++

    # Current Month Days
    for day in [1..@_daysInMonth()]
      date = new Date(year, month, day)
      values =
        day   : day
        date  : date
        today : @today.toString().substring(4, 15) is date.toString().substring(4, 15)
        active: @current.toString().substring(4, 15) is date.toString().substring(4, 15)
      values.event = @events[date] if @events[date]?
      unless @_active date
        values.disabled = true
        values.events = undefined
      values.events = undefined if @attributes.disabled
      @appendChild @constructor.child_class, values

    # Next Month visible Days
    next_month = @_nextMonth month, year
    last_day_of_month = new Date(year, month, @_daysInMonth()).getDay()
    day = 1
    for index in [6..last_day_of_month]
      values =
        day     : day
        date    : new Date next_month.setDate day
        disabled: true
      values.events = undefined if not(@_active values.date) or @attributes.disabled
      @appendChild @constructor.child_class, values
      day++

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
  onDayTouch: (event, atom) ->
    atom.el
      .addClass "active"
      .siblings("[data-atom-day]")?.removeClass "active"

    if atom.attributes.date.getMonth() isnt @current.getMonth()
      @date atom.attributes.date
    @current = atom.attributes.date
    @bubble "select", atom
    false

  # -- Private Events ----------------------------------------------------------
  _previousMonth: (month, year) ->
    new Date year, (month - 1), 1

  _nextMonth: (month, year) ->
    new Date year, (month + 1), 1

  _daysInMonth: (date = @current) ->
    32 - new Date(date.getYear(), date.getMonth(), 32).getDate()

  _find: (date) ->
    return day for day in @children when date - day.attributes.date is 0

  _active: (date) ->
    return false if @attributes.disable_previous_days and date < @today
    format_date = @_format date
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
