###
@TODO

@namespace Atoms.Molecule
@class Calendar

@author Javier Jimenez Villar @soyjavi
###
"use strict"

class Atoms.Molecule.Calendar extends Atoms.Molecule.Div

  @available: ["Atom.Day"]

  @events : ["select"]

  @default :
    months: ["January", "February", "March", "April", "May", "June", "July",
             "August", "September", "October", "November", "December"]
    days  : ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

  constructor: (attributes) ->
    super attributes
    @today = new Date()
    @date new Date attributes.date or @today


  date: (@value = new Date()) ->
    do @destroyChildren

    day = @value.getDate()
    month = @value.getMonth()
    year = @value.getFullYear()

    # Days header
    for day in @attributes.days
      @appendChild "App.Extension.Calendar.Day", day: day, events: undefined

    # Previous Month visible Days
    first_day_of_month = new Date(year, month).getDay() - 1
    previous_days = @_daysInMonth((month - 1), year) - (first_day_of_month - 1)

    for previousDay in [0...first_day_of_month]
      @appendChild "App.Extension.Calendar.Day", day: previous_days, disabled: true
      previous_days++

    # Current Month Days
    for day in [1..@_daysInMonth(month, year)]
      date = new Date(year, month, day)
      attributes =
        day   : day
        date  : date
        today : @today.toString().substring(4, 15) is date.toString().substring(4, 15)
        active: @value.toString().substring(4, 15) is date.toString().substring(4, 15)
        event : (day > 11 and day < 13) or (day > 19 and day < 22)
      @appendChild "App.Extension.Calendar.Day", attributes

    # # Next Month visible Days
    last_day_of_month = new Date(year, month, @_daysInMonth(month, year)).getDay()
    day = 1
    for index in [6..last_day_of_month]
      @appendChild "App.Extension.Calendar.Day", day: day, disabled: true
      day++

  # -- Bubble Children Events --------------------------------------------------
  onDayTouch: (event, atom) ->
    console.log atom.attributes.date
    atom.el
      .addClass "active"
      .siblings().removeClass "active"
    @bubble "select", atom.attributes.date
    false

  # -- Private Events ----------------------------------------------------------
  _daysInMonth: (month, year = 2014) ->
    if month < 0
      month = 12
      year--
    32 - new Date(year, month, 32).getDate()
