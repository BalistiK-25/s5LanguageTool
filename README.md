# s5_LanguageTool
## Table of contents
* [Why a language tool](#why-a-language-tool)
* [Including Supported Languages](#including-supported-languages)
* [Briefings und co](#briefings-und-co)

## Why a language tool

Free-play and campaign maps have been created by the developers in such a way that they can be offered in several languages. For this purpose, a briefing, for example, uses an XML file that is located in a folder with the respective language version of the game (when using the German language package, the XML file for this is located in the folder ("\extra2\shr\text\de\InGame").

Unfortunately, this possibility of loading strings from an XML file is only possible for preinstalled maps. Map creators cannot access an XML file from their map, let alone any other file except LUA files (which is a good thing). However, this makes it very time-consuming to offer one's own maps in several languages.
However, this tool is intended to make this easier, or to provide a framework that can be used:

* A window displays the language selection that this map supports. The game is also paused for this purpose so that the language selection does not inadvertently hinder the map's operations.
* Any functions that are to be multilingual can be offered as multilingual via the tool.
* Special characters that exist in many languages are automatically converted to UTF-8. (See [Including Supported Languages](#including-supported-languages))
* Briefings, messages and the like need little adaptation to support several languages at the same time.

## Including Supported Languages

Wenn man das LanguageTool als Comfort in seine Karte kopiert hat, wird zuerst nichts weiteres passieren. Über den folgenden Aufruf kann man das Fenster anzeigen (am Besten als Aufruf in der FMA). So lange das Fenster angezeigt wird, ist das Spiel pausiert
`LanguageTool.DisplayLanguageSelection(state, callback, parameters)`
* `state` (number) = optional, ob das Fenster angezeigt werden soll oder nicht. 0 = unsichtbar, 1 = sichtbar.
* `callback` (function) = optional, die Funktion, die nach Bestätigung der Sprachauswahl aufgerufen wird.
* `parameters` (table) = optional, die Parameter, die der callback-function bei Aufruf übergeben werden sollen.


Dieses Fenster ist allerdings zwecklos, da man keine Sprache auswählen kann.
Damit Sprachen zur Auswahl verfügbar werden, müssen diese ebenfalls hinzugefügt werden. Sinn und Zweck ist, dass der Mapentwickler selbst festlegen soll, welche Sprachen er unterstützt. Daher müssen diese über die folgende Funktion hinzugefügt werden:

`LanguageTool.AddToLanguageSelection(id, name, title, charset)`
* `id` (string) = die einteudige ID der Sprache. (Empfolen ist der Sprachkürzel nach ISO 639-1)
* `name` (string) = der Name der Sprache (am Besten in der Muttersprache, z.B. Deutsch, English, Polski, ...)
* `title` (string) = der Titel, der am oberen Fenster angezeigt wird, wenn die Sprache angewählt wird.
* `charset` (table) = (optional) das Charset stellt die Sonderzeichen der jeweiligen Sprache dar. Das charset wird dafür genutzt, diese Sonderzeichen in den Texten in UTF-8 zu konvertieren. Da zum Beispiel Siedler in Briefings Probleme hat Umlaute anzuzeigen, müssten diese in den Briefings durch UTF-8 durch z.B. eine Umlaute-Funktion ersetzt werden. Dies wird eben durch dieses angegebene Tool automatisch erstezt, je nach angegebenen charset.

So fügt man zum Beispiel Deutsch in die Sprachauswahl hinzu:  
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

Wichtig ist, dass man **erst** die Sprachen dem LanguageTool hinzufügt, bevor man das Fenster anzeigt.


## Briefings und co

