###
@TODO

@namespace Atoms.Molecule
@class Calendar

@author Javier Jimenez Villar @soyjavi
###
"use strict"

class Atoms.Molecule.Calendar extends Atoms.Molecule.Div

  @extends  : true

  @available: ["Atom.Day", "Atom.Heading"]

  @events   : ["select"]

  @default  :
    months: ["January", "February", "March", "April", "May", "June", "July",
             "August", "September", "October", "November", "December"]
    days  : ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    children: [
      "Atom.Heading": id: "literal", value: "Year", size: "h4"
    ]

  constructor: (attributes = {}) ->
    for key in ["months", "days"] when not attributes[key]
      attributes[key] = @constructor.default[key]
    super attributes
    @today = new Date()
    @today = new Date(@today.getFullYear(), @today.getMonth(), @today.getDate())
    @date new Date attributes.date or @today


  date: (@current = new Date()) ->
    child.destroy() for child in @children when child.constructor.name is "Day"

    day = @current.getDate()
    month = @current.getMonth()
    year = @current.getFullYear()

    @literal.el.html "#{@attributes.months[month]} - #{year}"

    class_name = "App.Extension.Calendar.Day"
    # Days header
    for day in @attributes.days
      @appendChild class_name, day: day, events: undefined

    # Previous Month visible Days
    first_day_of_month = new Date(year, month).getDay() - 1
    previous_days = @_daysInMonth((month - 1), year) - (first_day_of_month - 1)

    for previousDay in [0...first_day_of_month]
      attributes =
        day     : previous_days
        disabled: true
      attributes.events = undefined if @attributes.disable_previous_days
      @appendChild class_name, attributes
      previous_days++

    # Current Month Days
    for day in [1..@_daysInMonth(month, year)]
      date = new Date(year, month, day)
      attributes =
        day   : day
        date  : date
        today : @today.toString().substring(4, 15) is date.toString().substring(4, 15)
        active: @current.toString().substring(4, 15) is date.toString().substring(4, 15)
        # event : (day > 11 and day < 13) or (day > 19 and day < 22)
      if @attributes.disable_previous_days and date < @today
        attributes.disabled = true
        attributes.events = undefined
      @appendChild class_name, attributes

    # Next Month visible Days
    last_day_of_month = new Date(year, month, @_daysInMonth(month, year)).getDay()
    day = 1
    for index in [6..last_day_of_month]
      @appendChild class_name, day: day, disabled: true
      day++


  # -- Bubble Children Events --------------------------------------------------
  onDayTouch: (event, atom) ->
    @current = atom.attributes.date
    atom.el
      .addClass "active"
      .siblings("[data-atom-day]").removeClass "active"
    @bubble "select", @current
    false

  # -- Private Events ----------------------------------------------------------
  _daysInMonth: (month, year = 2014) ->
    if month < 0
      month = 12
      year--
    32 - new Date(year, month, 32).getDate()
