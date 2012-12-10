# Do this only once
if (!@df4nLoaded)
  $("BODY").on "click", ".__df4n_close", (evt) ->
    evt.preventDefault()
    cleanUp()
  @df4nLoaded = true

# Util Functions
cleanUp = ->
  $("#__df4n_styles, #__df4n_container").remove()
  $("#wrap").show()

addStyles = ->
  $("HEAD").append("<link id='__df4n_styles' rel='stylesheet' type='text/css' href='http://dffn.azurewebsites.net/static/main/less/df4n.css?v=1_0'>")

# Lifted from http://stackoverflow.com/questions/196972/convert-string-to-title-case-with-javascript
titleCase = (str) ->
  str.replace(/\w\S*/g, (txt) ->
    txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase())

# Types
class Item
  constructor: (@name, @src) ->

class ItemGroup
  constructor: (@name, $items) ->
    @items =
      for item in $items
        name = titleCase(item.src.replace(/^.+?\/item\//i, "").replace(/\.png$/i, "").replace(/-/g, " "))
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

# Work
cleanUp()
addStyles()

itemGroups =
  for $ig in $("DIV.build-tab:visible DIV.items>H4").parent()
    new ItemGroup $("H4", $ig).text(), $("IMG", $ig)

skillBuild = new SkillBuild $("DIV.build-tab:visible DIV.skill-box TD.selected.c")

console.log skillBuild

title = $("TITLE").text()
buildName = $(".build-tab:visible H2").text()

# Inject Noob Info
$df4nContainer = $("
  <div id='__df4n_container'>
    <a class='__df4n_close'>close</a>
    <h1>#{title}</h1>
    <h2>#{buildName}</h2>
    <div id='__df4n_itemgroups'></div>
    <div id='__df4n_skills'></div>
  </div>
")

$df4nItemGroups = $("#__df4n_itemgroups", $df4nContainer)
$df4nSkills = $("#__df4n_skills", $df4nContainer)

for itemGroup in itemGroups
  template = []
  template.push "<div class='__df4n_itemgroup'>"
  template.push "<h4>#{itemGroup.name}</h4>"
  template.push "<ul>"

  for item in itemGroup.items
    template.push "<li><img src='#{item.src}' /> #{item.name}</li>"

  template.push "</ul>"
  template.push "</div>"
  $df4nItemGroups.append(template.join(""))

skillsTemplate = []
skillsTemplate.push "<h4>Hero Skills</h4>"
skillsTemplate.push "<ul>"

for skill in skillBuild.skills
  key = ""
  key = "<span class='__df4n_key'>(#{skill.key}</span>)" if skill.key.length > 0
  skillsTemplate.push "<li><span class='__df4n_level'>#{skill.level}</span> <img src='#{skill.skillImg}'/> #{key} #{skill.name}</li>"

skillsTemplate.push "</ul>"

$df4nSkills.append(skillsTemplate.join(""))

$("BODY").prepend($df4nContainer)
$("#wrap").hide()