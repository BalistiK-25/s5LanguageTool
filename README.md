# s5_LanguageTool
Freispiel- und Kampagnenkarten sind von den Entwicklern so erstellt worden, dass diese in mehreren Sprachen angeboten werden können. Dafür bedient sich z.B. ein Briefing einer XML-Datei, die sich in einem Ordner mit der jeweiligen Sprachversion des Spiels befindet (Bei Nutzung des deutschen Sprachpaketes, liegt die XML-Datei dafür in dem Ordner „\extra2\shr\text\de\InGame“).

Nun ist diese Möglichkeit, Strings aus einer XML-Datei zu laden, leider auch nur auf die vorinstallierten Karten so möglich. Map-Ersteller können von ihrer Karte her nicht auf eine XML-Datei zugreifen, geschweige denn auf eine andere Datei außer LUA-Dateien (was auch gut so ist). Dies macht es aber sehr aufwendig, eigene Karten in mehreren Sprachen anzubieten.
Dieses Tool hier soll dies jedoch erleichtern, beziehungsweise ein Gerüst bereitstelle, welches man nutzen kann:

•	In einem Fenster wird die Sprachauswahl angezeigt, die diese Karte unterstützt. Das Spiel wird dafür auch pausiert, damit die Auswahl der Sprache nicht versehentlich die Abläufe der Karte hindert.

•	Jegliche Funktionen, die eben mehrsprachig sein sollen, können über das Tool als mehrsprachig angeboten werden.

•	Umlaute oder besondere Zeichen, die es in vielen Sprachen gibt, werden automatisch in Unicode konvertiert. (Siehe Einbinden von unterstützten Sprachen)

•	Briefings, Messages und Co. müssen wenig angepasst werden, um mehrere Sprachen gleichzeitig zu unterstützen.

