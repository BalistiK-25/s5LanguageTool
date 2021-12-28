# s5_LanguageTool

Warum ein "language tool"?
-----------

Freispiel- und Kampagnenkarten sind von den Entwicklern so erstellt worden, dass diese in mehreren Sprachen angeboten werden können. Dafür bedient sich z.B. ein Briefing einer XML-Datei, die sich in einem Ordner mit der jeweiligen Sprachversion des Spiels befindet (Bei Nutzung des deutschen Sprachpaketes, liegt die XML-Datei dafür in dem Ordner „\extra2\shr\text\de\InGame“).

Nun ist diese Möglichkeit, Strings aus einer XML-Datei zu laden, leider auch nur auf die vorinstallierten Karten so möglich. Map-Ersteller können von ihrer Karte her nicht auf eine XML-Datei zugreifen, geschweige denn auf eine andere Datei außer LUA-Dateien (was auch gut so ist). Dies macht es aber sehr aufwendig, eigene Karten in mehreren Sprachen anzubieten.
Dieses Tool hier soll dies jedoch erleichtern, beziehungsweise ein Gerüst bereitstelle, welches man nutzen kann:

* In einem Fenster wird die Sprachauswahl angezeigt, die diese Karte unterstützt. Das Spiel wird dafür auch pausiert, damit die Auswahl der Sprache nicht versehentlich die Abläufe der Karte hindert.
* Jegliche Funktionen, die eben mehrsprachig sein sollen, können über das Tool als mehrsprachig angeboten werden.
* Umlaute oder besondere Zeichen, die es in vielen Sprachen gibt, werden automatisch in UTF-8 konvertiert. (Siehe Einbinden von unterstützten Sprachen)
* Briefings, Messages und Co. müssen wenig angepasst werden, um mehrere Sprachen gleichzeitig zu unterstützen.

Hinzufügen von Sprachen und anzeigen des Sprachselektors
-----------

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
`LanguageTool.AddToLanguageSelection("de", "Deutsch", "Drücke ENTER um in deutsch zu Spielen", {
    {"ä", "\195\164"},
    {"ö", "\195\182"},
    {"ü", "\195\188"},
    {"ß", "\195\159"},
    {"Ä", "\195\132"},
    {"Ö", "\195\150"},
    {"Ü", "\195\156"}
})`

Wichtig ist, dass man **erst** die Sprachen dem LanguageTool hinzufügt, bevor man das Fenster anzeigt.


Erstellen von Multi-Sprachen Funktionen
-----------

