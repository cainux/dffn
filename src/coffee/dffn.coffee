# Guarentee jQuery
$ = window.jQuery

# Util Functions
class util
  this.cleanUp = ->
    $("#__dffn_container").remove()
    $("#wrap").show()

  this.addStyles = ->
    $("HEAD").append("<link id='__dffn_styles' rel='stylesheet' type='text/css' href='http://dffn.azurewebsites.net/lib/css/dffn.css?v=1_3'>")

  # Lifted from http://stackoverflow.com/questions/196972/convert-string-to-title-case-with-javascript
  this.titleCase = (str) ->
    str.replace(/\w\S*/g, (txt) ->
      txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase())

# Types
class Item
  constructor: (@name, @src) ->

class ItemGroup
  constructor: (@name, $items) ->
    @items =
      for item in $items
        name = util.titleCase(item.src.replace(/^.+?\/item\//i, "").replace(/\.png$/i, "").replace(/-/g, " "))
        src = item.src

        new Item name, src

class Skill
  constructor: (@name, @level, @key, @skillImg) ->

class SkillBuild
  constructor: ($skills) ->
    @skills =
      for skill in $skills
        $sk = $(skill)
        keyImage = $sk.parents("TR").children("TD:last").children("IMG")
        skillImage = $sk.parents("TR").children("TD:first").children("IMG")

        name = $sk.parents("DIV.ajax-tooltip").children("H4").text()
        level = parseInt($sk.text())
        name = "Stats" if name is ''
        key = ""

        if keyImage.length > 0
          key = keyImage[0].src.replace(/^.+?key-|\.png$/g, "").toUpperCase()

        new Skill name, level, key, skillImage.attr('src')

    @skills.sort (a, b) ->
      if a.level >= b.level then 1 else -1

class Hero
  constructor: (@name, @url) ->

class Dffn
  noobify: ->
    util.cleanUp()

    title = $("TITLE").text()
    buildName = $(".build-tab:visible H2").text()

    $dffnContainer = $("
      <div id='__dffn_container'>
        <a class='__dffn_close'>close</a>
        <h1>#{title}</h1>
        <h2>#{buildName}</h2>
        <div id='__dffn_itemgroups'></div>
        <div id='__dffn_skills'></div>
        <div id='__dffn_heroes'></div>
      </div>
    ")

    addBuild $dffnContainer
    addHeroes $dffnContainer

    $("#wrap").hide()
    $("BODY").prepend $dffnContainer

  addBuild = ($container) ->
    # Get the placeholders from the container
    $itemGroups = $("#__dffn_itemgroups", $container)
    $skills = $("#__dffn_skills", $container)

    # Scrape Item Groups
    itemGroups =
      for $ig in $("DIV.build-tab:visible DIV.items>H4").parent()
        new ItemGroup $("H4", $ig).text(), $("IMG", $ig)

    # Scrape Build
    skillBuild = new SkillBuild $("DIV.build-tab:visible DIV.skill-box TD.selected.c")

    # Item Groups
    if itemGroups.length > 0
      for itemGroup in itemGroups
        itemTemplate = ["<div class='__dffn_itemgroup'><h4>#{itemGroup.name}</h4><ul>"]
        for item in itemGroup.items
          itemTemplate.push "<li><img src='#{item.src}' /> #{item.name}</li>"

        itemTemplate.push "</ul></div>"
        $itemGroups.append itemTemplate.join ""
    else
      $itemGroups.remove()

    # Skills
    if skillBuild.skills.length > 0
      skillsTemplate = ["<h4>Hero Skills</h4><ul>"]

      for skill in skillBuild.skills
        key = if skill.key.length > 0 then "<span class='__dffn_key'>(#{skill.key})</span>" else ""
        skillsTemplate.push "<li><span class='__dffn_level'>#{skill.level}</span> <img src='#{skill.skillImg}'/> #{key} #{skill.name}</li>"

      skillsTemplate.push "</ul>"
      $skills.append skillsTemplate.join ""
    else
      $skills.remove()

  addHeroes = ($container) ->
    $heroes = $("#__dffn_heroes", $container)

    # Scrape the hero list
    heroes = for link in $("#footer-links .foot-links a.ajax-tooltip")
      new Hero link.innerText, link.href

    heroes.sort (a, b) ->
      if a.name > b.name then 1 else -1

    # Build the list
    heroesTemplate = ["<h4>Heroes</h4><ul>"]

    for hero in heroes
      heroesTemplate.push "<li><a href='#{hero.url}'>#{hero.name}</a></li>"

    heroesTemplate.push "</ul>"
    $heroes.append heroesTemplate.join ""

# Do this only once
if not window.dffn?
  $("BODY").on "click", ".__dffn_close", (evt) ->
    evt.preventDefault()
    util.cleanUp()

  util.addStyles()
  dffn = new Dffn()
  dffn.noobify()

  window.dffn = dffn
