###
@TODO

@namespace Atoms.Molecule
@class Calendar

@author Javier Jimenez Villar @soyjavi
###
"use strict"

class Atoms.Molecule.Calendar extends Atoms.Molecule.Div

  @MONTHS   : "January,February,March,April,May,June,July,August,September,October,November,December".split(",")
  @WEEKDAYS : "Sun,Mon,Tue,Wed,Thu,Fri,Sat".split(",")
  @DAYS     : "31,0,31,30,31,31,30,31,30,31,30,31".split(",")

  @available: ["Atom.Day"]

  constructor: ->
    super
    @today = new Date()
    do @date

  date: (@value = new Date()) ->
    @value = new Date("2014/08/05")

    day = @value.getDate()
    week_day = @value.getDay()
    month = @value.getMonth()
    year = @value.getFullYear()

    # Previous Month visible Days
    first_day_of_month = new Date(year, month).getDay()
    for previousDay in [0...first_day_of_month]
      @appendChild "App.Extension.Calendar.Day", day: "?", disabled: true

    # Current Month Days
    for day in [1..parseInt(@constructor.DAYS[@value.getMonth()])]
      @appendChild "App.Extension.Calendar.Day", day: day, date: new Date(year, month, day)

    # # Next Month visible Days
    last_day_of_month = new Date(year, month, @constructor.DAYS[month]).getDay()
    for a in [6...last_day_of_month]
      @appendChild "App.Extension.Calendar.Day", day: "?", disabled: true


  onDayTouch: (event, atom) ->
    console.log atom.attributes.date
    false
