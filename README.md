# s5_LanguageTool
The whole LanguageTool is documented with Emmy Annotation. If you use Visual Studio Code, for example, you can download the lua-extension by sumneko which includes Emmy Annotation support.

The LanguageTool is quite large too (also because of this Emmy annotation) and covers a vast amount of functions for multilingual support (It very well may be that it still misses some functions!) It also very well be that this LanguageTool might be a little bit of an **overkill** for small maps with **little amount of text**.

Furthermore, the calls of LanguageTool.StartCutscene or LanguageTool.AddTribute may only work if you have the correct Comfort-Functions in your script. Otherwise nothing will happen.

## Table of contents
* [Why a language tool](#why-a-language-tool)
* [Including Supported Languages](#including-supported-languages)
* [General Pattern](#general-Pattern)
* [Briefings and Cutscenes](#briefings-and-cutscenes)
* [Adding your own multilingual function](#adding-your-own-multilingual-function)

## Why a language tool

Free-play and campaign maps have been created by the developers in such a way that they can be offered in several languages. For this purpose, a briefing, for example, uses an XML file that is located in a folder with the respective language version of the game (when using the German language package, the XML file for this is located in the folder "\extra2\shr\text\de\InGame").

Unfortunately, this possibility of loading strings from an XML file is only possible for preinstalled maps. Map creators cannot access an XML file from their map, let alone any other file except LUA files (which is a good thing). However, this makes it very time-consuming to offer one's own maps in several languages.
However, this tool is intended to make this easier, or to provide a framework that can be used:

* A window displays the language selection that this map supports. The game is also paused for this purpose so that the language selection does not inadvertently hinder the map's operations.
* Any functions that are to be multilingual can be offered as multilingual via the tool.
* Special characters that exist in many languages are automatically converted to UTF-8. (See [Including Supported Languages](#including-supported-languages))
* Briefings, messages and the like need little adaptation to support several languages at the same time.

This is how the language-selector will look like:

## Including Supported Languages

If you have copied the LanguageTool as a Comfort-Function into your mapscript, nothing will happen at first. You need to call the following function, in order to display the window (best as a call in the FMA). Note: As long as the window is displayed, the game is paused.
`LanguageTool.DisplayLanguageSelection(state, callback, parameters)`
* `state` (number) = optional; whether the window should be displayed or not. 0 = invisible, 1 = visible.
* `callback` (function) = optional; the function that is called after confirming the language selection.
* `parameters` (table) = optional; the parameters to be passed to the callback function when it is called.

However, this window will be pretty useless, as you cannot select any language.
In order for languages to become available for selection, they must be added first. The purpose of this is that the map developer himself should determine which languages he supports. Therefore, these must be added via the following function:

`LanguageTool.AddToLanguageSelection(id, name, title, charset)`
* `id` (string) = the deterministic ID of the language. (Recommended is the language abbreviation according to ISO 639-1)
* `name` (string) = the name of the language (preferably in the mother tongue, e.g. Deutsch, English, Polski, ...)
* `title` (string) = the title displayed at the top window when the language is "hovered over".
* `charset` (table) = (optional) the charset represents the special characters of the respective language. The charset is used to convert these special characters in the texts into UTF-8. Since, for example, Settler has problems displaying special characters in briefings, these would have to be replaced in the briefings by UTF-8 encoding, e.g. by an special function. This is automatically replaced by this tool, depending on the given charset.

For example, this is how you add German to the language selection: 
```
LanguageTool.AddToLanguageSelection("de", "Deutsch", "Drücke ENTER um in deutsch zu Spielen", {
    {"ä", "\195\164"},
    {"ö", "\195\182"},
    {"ü", "\195\188"},
    {"ß", "\195\159"},
    {"Ä", "\195\132"},
    {"Ö", "\195\150"},
    {"Ü", "\195\156"}
})
```
The special characters are specified with their UTF-8 code, which allows them to be replaced in texts. This may also work as to replace any "ó" with an "o", as there is no representation for that letter in settlers.

It is important to **first** add the languages to the LanguageTool **before** displaying the selector.

## General Pattern

If the LanguageTool has been successfully initialised and several languages have been added, the briefings, messages, cutscenes, etc... must be adapted. Basically, all multilingual text outputs are built on the same pattern: Each function that origninally receives a string, that should output in multiple languages, can either receive a string or a table (with a certain pattern). Let's take the regular "Message"-Function. The LanguageTool decides as follows:

* If the value passed is a string, it will be used for **all** languages.
* If the value passed is a table, a key is searched that corresponds to the selected language.
* If the value passed is a table and no key can be found that corresponds to the selected language, the key "shared" is searched for. If this is found, it is will be used.
* If the value passed is a table and no key and no "shared" can be found, an error text is returned as a string.

As an example, it is assumed that the LanguageTool has been initialised with languages with the ids "de", "en", "pl" and "fr". In the following, a simple text output (Message) is used to show how the LanguageTool selects the proper language-string.

```
-- Every selected language will display "Example Text"

LanguageTool.Message("Example Text") 

-- Every selected language, except with the id "de" and "en", will display "Example text for shared".
-- If the language with the id "de" is selected, "Beispieltext für de" will be displayed.
-- If the language with the id "en" is selected, "Example text for en" will be displayed.

LanguageTool.Message({
    shared = "Example text for shared",
    de = "Beispieltext für de",
    en = "Example text for en"
})

-- If the language with the id "de" is selected, "Beispieltext für de" will be displayed.
-- If the language with the id "en" is selected, "Example text for en" will be displayed.
-- If the language with the id "pl" is selected, "Przykładowy tekst dla pl" will be displayed.
-- Since no key is set for the id "fr", if "fr" would be the selected language an error message would be displayed saying "LanguageTool: No key was found for the selected language with the key "fr" "

LanguageTool.Message({
    en = "Example text for en",
    de = "Beispieltext für de",
    pl = "Przykładowy tekst dla pl"
})
```

As you can see, the original "Message" function was not used in the example, but the "Message" function of the LanguageTool. All functions have been replaced by separate functions of the LanguageTool, like LanguageTool.Briefing, LanguageTool.Message or LanguageTool.StartCutscene. On one hand, this serves to prevent errors,  on the other hand, it also makes it possible to safely overwrite functions such as StartBriefing at any time without coming into conflict with the LanguageTool itself.

## Briefings and Cutscenes

Since briefings (and cutscenes) are a more complex topic, they are presented below in an additional example. The cutscene text and title work the same way as the example of the briefing. Suppose we have the following briefing, which we call with the function LanguageTool.StartBriefing:
```
local briefing = {}

table.insert(briefing, {
    title       = "Totally viable title",
    text        = "Totally viable text",
    position    = GetPosition("position")
})

LanguageTool.StartBriefing(briefing)
```
In this example, all selected languages would display title and text in the same way. Suppose we want to display a different text for the language "de", "en" and "pl". We would solve this as follows:
```
local briefing = {}

table.insert(briefing, {
    title       = "Totally viable title",
    text        = {
        de = "Vollkommen brauchbarer Text",
        en = "Totally viable text",
        pl = "Tekst całkowicie wykonalny"
    },
    position    = GetPosition("position")
})

LanguageTool.StartBriefing(briefing)
```
For the languages with the id "de", "en" and "pl" we would now display different texts. For the language "fr" we would get an error message as text. However, all languages would still display the same title: "Totally viable title". For the next step, we therefore want to give the languages "de" and "en" the same title and "pl" a different one:
```
local briefing = {}

table.insert(briefing, {
    title       = {
        shared = "Totally viable title"
        pl = "Całkowicie realny tytuł" 
    },
    text        = {
        de = "Vollkommen brauchbarer Text",
        en = "Totally viable text",
        pl = "Tekst całkowicie wykonalny"
    },
    position    = GetPosition("position")
})

LanguageTool.StartBriefing(briefing)
```
Now we would have the same title for "de" and "en" (and also "fr") and our own title for "pl".  
For "de", "en" and "pl" we would therefore have a different text and for "fr" an error message as text.

It is also very important to **replace the call StartBriefing to LanguageTool.StartBriefing before adjusting the briefing pages**. Otherwise you will quickly run into an error that can only be solved by Alt+F4 the game.

If we want to create multiple-choice briefings we must replace the firstText and secondText of the mc-table with the same principle as shown below:
```
    ...
mc   = {
    title = "Title for everyone",
    text = "Text for everyone",
    firstText = {
        de   = "Erster Text für de",
        en   = "First text for en",
        pl   = "Pierwszy tekst do pl"
    },
    secondText = {
        de  = "Zweiter Text für de",
        en  = "Second text for en",
        pl  = "Drugi tekst do de"
    },
    firstSelected  = 2,
    secondSelected = 4,
},
    ...
```

The concept stays the same across all functions that may take text that should be multilingual. Here is the full list of all functions implemented in the LanguageTool:
* LanguageTool.Message
* LanguageTool.StartBriefing
* LanguageTool.StartCutscene (requires comfort-function)
* LanguageTool.SetPlayerName
* LanguageTool.CreateNPC
* LanguageTool.AddQuest
* LanguageTool.AddTribute (requires comfort-function)

## Adding your own multilingual function

If there is a need to write a separate function to display multilingual text, the function `LanguageTool:GetString(_table, _returnInput)` can be called.
This is the main function to find the correct keys from a table (as set throughout the examples above). Important to note, if no matching key is found, `_returnInput` (a boolean) can be used to specify whether an error message should be returned or the input itself.
```
-- Your own function that does something with the text that should be multilingual
function Test(_text)
    doSomethingWithTheText(_text)
end

function LanguageTool.Test(_table)
    _table = LanguageTool:GetString(_table) -- will always return a string
    _table = LanguageTool:GetString(_table, true) -- will either return the correct string or _table
    
    Test(_table)
end
```
