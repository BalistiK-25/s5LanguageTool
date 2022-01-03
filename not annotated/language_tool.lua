--[[ LanguageTool   version 2.5.0 	]]--
--[[ Author:        BalistiK    	]]--
LanguageTool = {
    isActive = false,
    callback = nil,
    parameters = nil,
    initialised = false,
    chosenLanguage = nil,
    languageTable = {},
    currentIndex = 1,
    checkEnabled = false,
    flagStrings = false
}

LanguageTool.NO_LANG_ERROR = "@color:255,95,95 LanguageTool: No language was set. Language specific functions may not work!"
LanguageTool.NO_LANG_FOR_KEY = "@color:255,255,95 LanguageTool: No key was found for the selected language with the key \"LANGKEY\""
LanguageTool.NO_KEYS_FOUND = "@color:255,255,95 LanguageTool: No key/(s) was/were found for the id/(s): KEY_IDS"
LanguageTool.FLAG_STRING = "@color:95,255,95 LanguageTool: The valid key is a string."

LanguageTool.GERMAN_PRESET = {
    id      = "de",
    text    = "Deutsch",
    title   = "Drücke ENTER um in deutsch zu Spielen",
    charset = {
        {"Ä", "\195\132"},{"ä", "\195\164"},{"Ö", "\195\150"},{"ö", "\195\182"},{"Ü", "\195\156"},{"ü", "\195\188"},
        {"ß", "\195\159"}
    }
}

LanguageTool.ENGLISH_PRESET = {
    id      = "en",
    text    = "English",
    title   = "Press ENTER to play in English",
    charset = {}
}

LanguageTool.POLISH_PRESET = {
    id      = "pl",
    text    = "Polski (Eksperymentalny)",
    title   = "Naciśnij ENTER, aby odtwarzać w języku polskim",
    charset = {
        {"Ą", "\196\132"},{"ą", "\196\133"},{"Ć", "\196\134"},{"ć", "\196\135"},{"Ę", "\196\152"},{"ę", "\196\153"},
        {"Ł", "\197\129"},{"ł", "\197\130"},{"Ń", "\197\131"},{"ń", "\197\132"},{"Ó", "\195\147"},{"ó", "\195\179"},
        {"Ś", "\197\154"},{"ś", "\197\155"},{"Ż", "\197\187"},{"ż", "\197\188"},{"Ź", "\197\185"},{"ź", "\197\186"}
    }
}

LanguageTool.FRENCH_PRESET = {
    id      = "fr",
    text    = "Français (Expérimental)",
    title   = "Appuyez sur ENTER pour lire en français",
    charset = {
        {"Ç", "\195\135"},{"ç", "\195\167"},{"À", "\195\128"},{"à", "\195\160"},{"Â", "\195\130"},{"â", "\195\162"},
        {"Æ", "\195\134"},{"æ", "\195\166"},{"É", "\195\137"},{"é", "\195\169"},{"È", "\195\136"},{"è", "\195\168"},
        {"Ê", "\195\138"},{"ê", "\195\170"},{"Ë", "\195\139"},{"ë", "\195\171"},{"Î", "\195\142"},{"î", "\195\174"},
        {"Ï", "\195\143"},{"ï", "\195\175"},{"Ô", "\195\148"},{"ô", "\195\180"},{"Œ", "OE"},{"œ", "oe"},
        {"Ù", "\195\153"},{"ù", "\195\185"},{"Û", "\195\155"},{"û", "\195\187"},{"Ü", "\195\156"},{"ü", "\195\188"},
        {"Ÿ", "Y"}, {"ÿ", "\195\191"}
    }
}

function LanguageTool.SubstituteStrings(_text, _table)
    if _table and type(_table) == "table" and table.getn(_table) > 0 then
        local texttype = type(_text);
        if texttype == "string" then
            for _, v in pairs(_table) do
                _text = string.gsub(_text, v[1], v[2]);
            end
        elseif texttype == "table" then
            for k, _ in _text do
                _text[k] = LanguageTool.SubstituteStrings(_text, _table);
            end
        end
    end

    return _text
end

function LanguageTool:__Init(_callback, _parameters)
    if not self.initialised then
        Input.KeyBindDown(Keys.W, "LanguageTool:__PreviousLanguage()", 2)
        Input.KeyBindDown(Keys.S, "LanguageTool:__NextLanguage()", 2)
        Input.KeyBindDown(Keys.Enter, "LanguageTool:__ChooseLanguage()", 2)

        self.initialised = true
    end

    self.callback = (_callback and type(_callback) == "function") and _callback or nil
    self.parameters = _parameters and _parameters or nil
end

function LanguageTool.EnableLanguageCheck(_flagStrings)
    LanguageTool.checkEnabled = true
    if _flagStrings then
        LanguageTool.flagStrings = true
    end
end

function LanguageTool.Message(_text)
    _text = LanguageTool:GetString(_text)

    Message(_text)
end

function LanguageTool.StartBriefing(_briefing)
    for _, v in pairs(_briefing) do
        if type(v) == "table" then
            if v.mc ~= nil then
                v.mc.firstText = LanguageTool:GetString(v.mc.firstText)
                v.mc.secondText = LanguageTool:GetString(v.mc.secondText)

                v.mc.title = LanguageTool:GetString(v.mc.title)
                v.mc.text = LanguageTool:GetString(v.mc.text)
            else
                v.title = LanguageTool:GetString(v.title)
                v.text = LanguageTool:GetString(v.text)
            end
        end
    end

    StartBriefing(_briefing)
end

function LanguageTool.StartCutscene(_cutscene)
    if StartCutscene ~= nil and type(StartCutscene) == "function" then
        for _, v in pairs(_cutscene.Flights) do
			if type(v) == "table" then
                v.title = LanguageTool:GetString(v.title)
                v.text = LanguageTool:GetString(v.text)
			end
		end

        StartCutscene(_cutscene)
    end
end

function LanguageTool.SetPlayerName(_player, _name)
    _name = LanguageTool:GetString(_name)

    SetPlayerName(_player, _name)
end

function LanguageTool.CreateNPC(_npc)
    _npc.wrongHeroMessage = LanguageTool:GetString(_npc.wrongHeroMessage)

    CreateNPC(_npc)
end

function LanguageTool.AddQuest(_questTable)
    assert(_questTable ~= nil, "Questtable must not be nil!")
    assert(_questTable.title ~= nil and (type(_questTable.title) == "string" or type(_questTable.title) == "table"), "Questtable.title must not be nil and a string or table!")
    assert(_questTable.text ~= nil and (type(_questTable.text) == "string" or type(_questTable.text) == "table"), "Questtable.text must not be nil and a string or table!")

    _questTable.title = LanguageTool:GetString(_questTable.title)
    _questTable.text = LanguageTool:GetString(_questTable.text)

    assert(_questTable.player ~= nil and type(_questTable.player) == "number", "Questtable.player must not be nil and a number!")
    assert(_questTable.id ~= nil and type(_questTable.id) == "number", "Questtable.id must not be nil and a number!")
    assert(_questTable.type ~= nil and type(_questTable.type) == "number", "Questtable.type must not be nil and a number!")

    Logic.AddQuest(_questTable.player, _questTable.id, _questTable.type, _questTable.title, _questTable.text, 1)
end

function LanguageTool.AddTribute(_tribute)
    _tribute.text = LanguageTool:GetString(_tribute.text)

    if AddTribute ~= nil and type(AddTribute) == "function" then
        AddTribute(_tribute)
    end
end

function LanguageTool:GetString(_table, _returnInput)
    _returnInput = _returnInput or false
    local prefix = (_table ~= nil and type(_table) == "table" and _table.prefix ~= nil) and _table.prefix.." " or ""
    local warning = ""

    if self.checkEnabled then
        if type(_table) == "table" and not _returnInput then
            for _, v in pairs(self.languageTable) do
                if _table[v.id] == nil and _table.shared == nil then
                    warning = warning..v.id..", "
                end
            end
            warning = (warning == "") and warning or "\n"..string.gsub(LanguageTool.NO_KEYS_FOUND, "KEY_IDS", string.sub(warning, 1, string.len(warning) - 2))
        elseif self.flagStrings and type(_table) == "string" then
            warning = "\n"..LanguageTool.FLAG_STRING
        end
    end
    
    if _table ~= nil and type(_table) == "table" and self.chosenLanguage ~= nil then
        if _table[self.chosenLanguage.id] ~= nil then
            return prefix..LanguageTool.SubstituteStrings(_table[self.chosenLanguage.id], self.chosenLanguage.charset)..warning
        elseif _table.shared ~= nil then
            return prefix..LanguageTool.SubstituteStrings(_table.shared, self.chosenLanguage.charset)..warning
        end
    elseif _table ~= nil and type(_table) == "string" then
        return _table..warning
    end

    if _returnInput then
        return _table
    end

    return prefix..string.gsub(LanguageTool.NO_LANG_FOR_KEY, "LANGKEY", (self.chosenLanguage == nil and type(self.chosenLanguage) or self.chosenLanguage.id))..warning
end

function LanguageTool.AddToLanguageSelection(_id, _name, _title, _characterSet)
    table.insert(LanguageTool.languageTable, {
        id      =     _id,
        text    =     _name,
        title   =     _title == "" and _name or _title,
        charset =     _characterSet or {}
    })
end

function LanguageTool:__ChooseLanguage()
    if self.isActive then
        LanguageTool.DisplayLanguageSelection(0)

        if table.getn(self.languageTable) > 0 then
            self.chosenLanguage = self.languageTable[self.currentIndex]
        else
            Message(LanguageTool.NO_LANG_ERROR)
        end


        if self.callback then
            if self.parameters then
                if type(self.parameters) == "table" then
                    self.callback(unpack(self.parameters))
                else
                    self.callback(self.parameters)
                end
            else
                self.callback()
            end
        end
    end
end

function LanguageTool:__PreviousLanguage()
    if self.isActive then
        if self.currentIndex - 1 >= 1 then
            self.currentIndex = self.currentIndex - 1
        end

        LanguageTool:__DisplayText()
    end
end

function LanguageTool:__NextLanguage()
    if self.isActive then
        if self.currentIndex + 1 <= table.getn(self.languageTable) then
            self.currentIndex = self.currentIndex + 1
        end

        LanguageTool:__DisplayText()
    end
end

function LanguageTool:__DisplayText()
    local moveUp = "@color:255,255,255 (A) UP "
    local languageList = ""
    local languageTitle = ""
    local moveDown = "@color:255,255,255 (D) DOWN "
    local select = "(ENTER) Select"

    for k, v in pairs(self.languageTable) do
        if k == self.currentIndex then
            languageList = languageList.."@color:255,255,255 "..v.text.."\n"
            languageTitle = v.title
        else
            languageList = languageList.."@color:165,165,165 "..v.text.."\n"
        end
    end

    languageList = languageList == "" and "Use \"LanguageTool.AddToLanguageSelection\" to add languages to this selector.\n" or languageList
    languageTitle = languageTitle == "" and "No languages for selection found!" or languageTitle

    XGUIEng.SetText("CreditsWindowTextTitle", "@color:255,255,255 "..languageTitle)
    XGUIEng.SetText("CreditsWindowText", ""..moveUp.."\n\n"..languageList.."\n"..moveDown.."\n\n"..select)
end

function LanguageTool.DisplayLanguageSelection(_state, _callback, _params)
    _state = _state or 1

    if _state <= 0 then
        LanguageTool:__Hide()
    elseif _state > 0 then
        LanguageTool:__Init(_callback, _params)
        LanguageTool:__DisplayText()
        LanguageTool:__Show()
    end
end

function LanguageTool:__Show()
    self.isActive = true

    Game.GameTimeSetFactor(0)
    Stream.Pause(true)
    Sound.Pause3D(true)

    Camera.ScrollSetLookAt(-1, -1)
    Camera.SetControlMode(1)
    XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Normal"), 0)

    XGUIEng.ShowWidget("Movie", 1);
    XGUIEng.ShowWidget("Cinematic_Text", 0);
    XGUIEng.ShowWidget("MovieBarTop", 0);
    XGUIEng.ShowWidget("MovieBarBottom", 0);
    XGUIEng.ShowWidget("MovieInvisibleClickCatcher", 0);
    XGUIEng.ShowWidget("CreditsWindowLogo", 0);
end

function LanguageTool:__Hide()
    self.isActive = false

    XGUIEng.ShowWidget("Movie", 0);
    XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Normal"), 1)
    Camera.SetControlMode(0)

    Game.GameTimeSetFactor(1)
    Stream.Pause(false)
    Sound.Pause3D(false)
end
