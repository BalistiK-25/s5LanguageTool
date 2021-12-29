--[[ LanguageTool   version 2 ]]--
--[[ Author:        BalistiK  ]]--
LanguageTool = {
    isActive = false,
    callback = nil,
    parameters = nil,
    initialised = false,
    chosenLanguage = nil,
    languageTable = {},
    currentIndex = 1
}

LanguageTool.NO_LANG_ERROR = "@color:255,95,95 LanguageTool: No language was set. Language specific functions may not work!"
LanguageTool.NO_LANG_FOR_KEY = "@color:255,255,95 LanguageTool: No key was found for the selected language with the key \"LANGKEY\""

LanguageTool.GERMAN_CHARSET = {
    {"Ä", "\195\132"},{"ä", "\195\164"},
    {"Ö", "\195\150"},{"ö", "\195\182"},
    {"Ü", "\195\156"},{"ü", "\195\188"},
    {"ß", "\195\159"}
}

LanguageTool.POLISH_CHARSET = {
    {"Ą", "\196\132"},{"ą", "\196\133"},
    {"Ć", "\196\134"},{"ć", "\196\135"},
    {"Ę", "\196\152"},{"ę", "\196\153"},
    {"Ł", "\197\129"},{"ł", "\197\130"},
    {"Ń", "\197\131"},{"ń", "\197\132"},
    {"Ó", "O"},{"ó", "o"},
    {"Ś", "\197\154"},{"ś", "\197\155"},
    {"Ż", "\197\187"},{"ż", "\197\188"},
    {"Ź", "\197\185"},{"ź", "\197\186"}
}

LanguageTool.FRENCH_CHARSET = {
    {"Ç", "\195\135"},{"ç", "\195\167"},
    {"À", "\195\128"},{"à", "\195\160"},
    {"Â", "\195\130"},{"â", "\195\162"},
    {"Æ", "\195\134"},{"æ", "\195\166"},
    {"É", "\195\137"},{"é", "\195\169"},
    {"È", "\195\136"},{"è", "\195\168"},
    {"Ê", "\195\138"},{"ê", "\195\170"},
    {"Ë", "\195\139"},{"ë", "\195\171"},
    {"Î", "\195\142"},{"î", "\195\174"},
    {"Ï", "\195\143"},{"ï", "\195\175"},
    {"Ô", "\195\148"},{"ô", "\195\180"},
    {"Œ", "\197\146"},{"œ", "\197\147"},
    {"Ù", "\195\153"},{"ù", "\195\185"},
    {"Û", "\195\155"},{"û", "\195\187"},
    {"Ü", "\195\156"},{"ü", "\195\188"},
    {"Ÿ", "\197\184"},{"ÿ", "\195\191"}
}

--- Replaces all occurring characters by a given table that defines which characters are to be replaced by a string.
---
--- @param _text any        The string or table that contains stringts that should be converted.
--- @param _table table     A table containing the necessary characters to unicodes. 
---                         The table must follow this structure: 
---                         {
---                             {"characterToReplace", "replacement"},
---                             {"characterToReplace", "replacement"}, 
---                                                 ...
---                         }
--- @return any _text       The converted input or the input itself, if it could not be converted.
function LanguageTool.SubstituteStrings(_text, _table)
    if not _table or not type(_table) == "table" or table.getn(_table) == 0 then
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

--- Initzialises the language selector (setting the callback function, binding keys)
--- This function should not be called outside of the scope of the LangageSelector itself.
---
--- @param _callback function   | (optional) The function that will be execute as this window is gets hidden.
--- @param _parameters table    | (optional) The parameters of the callbacl-function.
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

--- Takes a table as its input, which contains either a language specific id with its string and/or a
--- "shared" key, which will be used indead and displays it as a regular text-message. 
--- The text can also be set as a regular string, wich will be displayed for all languages, no matter the id. 
--- @param _text table   The table follows this structure: 
---                     {
---                         shared  = "Text for all ids that are not listed in this table",
---                         id1 = "Text for language with the id 1",
---                         id2 = "Text for language with the id 2"
---                                     ...
---                     }
function LanguageTool.Message(_text)
    if _text ~= nil and type(_text) == "table" then
        _text = LanguageTool:GetString(_text)
    end

    Message(_text)
end

--- Takes a briefing table as its input. In every page the title and text, and in mc-briefings the first- and secondText have to be a table,
--- which contains either a language specific id with its string and/or a "shared" key. 
--- The title and text, and in mc-briefings the first- and secondText can also be set as a regular string, wich will be displayed for all languages, no matter the id. 
--- A regular briefing is then created with the proper
--- selected language-strings, based on the selected language of this tool. Otherwise these keys will be replaced with an empty one.
--- @param _briefing table   The regular briefing table in which all pages title, text, firstText and secondText follows this structure: 
---                         {
---                             shared  = "Text for all ids that are not listed in this table",
---                             id1 = "Text for language with the id 1",
---                             id2 = "Text for language with the id 2"
---                                         ...
---                         }
function LanguageTool.StartBriefing(_briefing)
    for _, v in pairs(_briefing) do
        if type(v) == "table" then
            if v.mc ~= nil then
                if v.mc.firstText ~= nil and type(v.mc.firstText) == "table" then
                    v.mc.firstText = LanguageTool:GetString(v.mc.firstText)
                end

                if v.mc.secondText ~= nil and type(v.mc.secondText) == "table" then
                    v.mc.secondText = LanguageTool:GetString(v.mc.secondText)
                end

                if v.mc.title ~= nil and type(v.mc.title) == "table" then
                    v.mc.title = LanguageTool:GetString(v.mc.title)
                end

                if v.mc.text ~= nil and type(v.mc.text) == "table" then
                    v.mc.text = LanguageTool:GetString(v.mc.text)
                end
            else
                if v.title ~= nil and type(v.title) == "table" then
                    v.title = LanguageTool:GetString(v.title)
                end

                if v.text ~= nil and type(v.text) == "table" then
                    v.text = LanguageTool:GetString(v.text)
                end
            end
        end
    end

    StartBriefing(_briefing)
end

--- Requires the Cutscene-Comfort Function to work!
--- Takes a cutscene table as its input. In every flight the title and text have to be a table,
--- which contains either a language specific id with its string and/or a "shared" key.
--- The text and title can also be set as a regular string, wich will be displayed for all languages, no matter the id. 
--- A regular cutscene is then created with the proper selected language-strings, based on the selected language of this tool. 
--- Otherwise these keys will be replaced with an empty one.
--- @param _cutscene table   The regular cutscene table in which all pages title, text, firstText and secondText follows this structure: 
---                         {
---                             shared  = "Text for all ids that are not listed in this table",
---                             id1 = "Text for language with the id 1",
---                             id2 = "Text for language with the id 2"
---                                         ...
---                         }
function LanguageTool.StartCutscene(_cutscene)
    if StartCutscene ~= nil and type(StartCutscene) == "function" then
        for _, v in pairs(_cutscene.Flights) do
			if type(v) == "table" then
                if v.title ~= nil and type(v.title) == "table" then
                    v.title = LanguageTool:GetString(v.title)
                end

                if v.text ~= nil and type(v.text) == "table" then
                    v.text = LanguageTool:GetString(v.text)
                end
			end
		end

        StartCutscene(_cutscene)
    end
end

--- Sets the playername for a specific id. The name is expressed as a table and must contain either a language specific id with its string and/or a
--- "shared" key. The name can also be set as a regular string, wich will be displayed for all languages, no matter the id.
--- @param _player number   The id of the player, which name is to be set.
--- @param _name table      The table follows this structure: 
---                         {
---                             shared  = "Text for all ids that are not listed in this table",
---                             id1 = "Text for language with the id 1",
---                             id2 = "Text for language with the id 2"
---                                         ...
---                         }
function LanguageTool.SetPlayerName(_player, _name)
    if _name ~= nil and type(_name) == "table" then
        _name = LanguageTool:GetString(_name)
    end

    SetPlayerName(_player, _name)
end

--- Takes a npc table as its input. The wrongHeroMessage must contain either a language specific id with its string and/or a
--- "shared" key. The wrongHeroMessage can also be set as a regular string, wich will be displayed for all languages, no matter the id.
--- found for the given language key, an empty string will be displayed.
--- @param _npc table   The regular npc table in which the wrongHeroMessage follows this structure: 
---                     {
---                         shared  = "Text for all ids that are not listed in this table",
---                         id1 = "Text for language with the id 1",
---                         id2 = "Text for language with the id 2"
---                                     ...
---                     }
function LanguageTool.CreateNPC(_npc)
    if _npc.wrongHeroMessage ~= nil and type(_npc.wrongHeroMessage) == "table" then
        _npc.wrongHeroMessage = LanguageTool:GetString(_npc.wrongHeroMessage)
    end

    CreateNPC(_npc)
end

--- Takes a regular quest table as its input. The title and text of the quest-table must contain either a language specific id with its string and/or a
--- "shared" key. The title and text can also be set as a regular string, wich will be displayed for all languages, no matter the id.
--- @param _questTable table    The quest as a table with the following structure:
---                             _questTable	= {
---                                 player  =   number,
---	                                id		=   number,
---	                                type	=   number,
---	                                title	=   {
---                                                 shared  = "Text for all ids that are not listed in this table",
---                                                 id1 = "Text for language with the id 1",
---                                                 id2 = "Text for language with the id 2"
---                                                             ...
---                                 },
---	                                text	=   {
---                                                 shared  = "Text for all ids that are not listed in this table",
---                                                 id1 = "Text for language with the id 1",
---                                                 id2 = "Text for language with the id 2"
---                                                             ...
---                                 }
---                             }
function LanguageTool.AddQuest(_questTable)
    assert(_questTable ~= nil, "Questtable must not be nil!")
    assert(_questTable.title ~= nil and (type(_questTable.title) == "string" or type(_questTable.title) == "table"), "Questtable.title must not be nil and a string or table!")
    assert(_questTable.text ~= nil and (type(_questTable.text) == "string" or type(_questTable.text) == "table"), "Questtable.text must not be nil and a string or table!")

    if _questTable.title ~= nil and type(_questTable.title) == "table" then
        _questTable.title = LanguageTool:GetString(_questTable.title)
    end
    if _questTable.text ~= nil and type(_questTable.text) == "table" then
        _questTable.text = LanguageTool:GetString(_questTable.text)
    end

    assert(_questTable.player ~= nil and type(_questTable.player) == "number", "Questtable.player must not be nil and a number!")
    assert(_questTable.id ~= nil and type(_questTable.id) == "number", "Questtable.id must not be nil and a number!")
    assert(_questTable.type ~= nil and type(_questTable.type) == "number", "Questtable.type must not be nil and a number!")

    Logic.AddQuest(_questTable.player, _questTable.id, _questTable.type, _questTable.title, _questTable.text, 1)
end

--- Requires the AddTribute-Comfort Function to work!
--- Creates a new Tribute with the given table. The text of the tribute-table must contain either a language specific id with its string and/or a
--- "shared" key. The title and text can also be set as a regular string, wich will be displayed for all languages, no matter the id.
---@param _tribute table    The tribute as a table, where the text is a table following this structure:
---                         {
---                             shared  = "Text for all ids that are not listed in this table",
---                             id1 = "Text for language with the id 1",
---                             id2 = "Text for language with the id 2"
---                                         ...
---                         }
function LanguageTool.AddTribute(_tribute)
    if _tribute.text ~= nil and type(_tribute.text) == "table" then
        _tribute.text = LanguageTool:GetString(_tribute.text)
    end

    if AddTribute ~= nil and type(AddTribute) == "function" then
        AddTribute(_tribute)
    end
end

--- Returns the correct string of a given table by the chosen language-id or an error message, if no key could be found.
--- The table should follow this style:
--- {
---    shared  = "Text for all id that are not listed in this table (may be optional)"
---    langID1 = "Text for langID1",
---    langID2 = "Text for langID2"
--- }
--- @param _table table             The table to look for.
--- @param _returnInput boolean     (optional) boolean If the input should be returned, if no key was found
--- @return string any              A error-string or the input
function LanguageTool:GetString(_table, _returnInput)
    _returnInput = _returnInput or false

    if _table ~= nil and type(_table) == "table" and self.chosenLanguage ~= nil then
        if _table[self.chosenLanguage.id] ~= nil then
            return LanguageTool.SubstituteStrings(_table[self.chosenLanguage.id], self.chosenLanguage.charset)
        elseif _table.shared ~= nil then
            return LanguageTool.SubstituteStrings(_table.shared, self.chosenLanguage.charset)
        end
    end

    if _returnInput then
        return _table
    end

    return string.gsub(LanguageTool.NO_LANG_FOR_KEY, "LANGKEY", (self.chosenLanguage == nil and type(self.chosenLanguage) or self.chosenLanguage.id))
end

--- Adds a new language to the LanguageTool. Every other function, that should be multi-language, must include
--- this given id as its key.
---
--- @param _id string            Must be a uniqe ID. This id defines which string will be chosen.
--- @param _name string          The name of the language (in its native language)
--- @param _title string         The title that should be displayed. 
--- @param _characterSet table   The characterset of the language. The table follows this structure: 
---                             {
---                                 {"specialCharacter", "UTF-8 Code"},
---                                 {"specialCharacter", "UTF-8 Code"}, 
---                                                   ...
---                             }
function LanguageTool.AddToLanguageSelection(_id, _name, _title, _characterSet)
    table.insert(LanguageTool.languageTable, {
        id      =     _id,
        text    =     _name,
        title   =     _title == "" and _name or _title,
        charset =     _characterSet or {}
    })
end

--- Sets the currently displayed language as the chosen one.
--- Should not be called outside the scope of the LanguageTool itself.
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

--- Moves the current index of the language selection to the next element (down)
--- Should not be called outside the scope of the LanguageTool itself.
function LanguageTool:__PreviousLanguage()
    if self.isActive then
        if self.currentIndex - 1 >= 1 then
            self.currentIndex = self.currentIndex - 1
        end

        LanguageTool:__DisplayText()
    end
end

--- Moves the current index of the language selection to the next element (down)
--- Should not be called outside the scope of the LanguageTool itself.
function LanguageTool:__NextLanguage()
    if self.isActive then
        if self.currentIndex + 1 <= table.getn(self.languageTable) then
            self.currentIndex = self.currentIndex + 1
        end

        LanguageTool:__DisplayText()
    end
end

--- Creates the text necessary for display of the language selection
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

--- Displays the language selection window or hides it.
---
--- @param _state number        | (0 or 1) Wether to show or hide the language-selection window.
--- @param _callback function   | (optional) The function that will be executed as this window gets hidden.
--- @param _params table        | (optional) The parameters of the callback-function.
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

--- Displays the language-selection-window
--- Should not be called outside the scope of the LanguageTool itself.
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

--- Hides the language-selection-window
--- Should not be called outside the scope of the LanguageSelecotr itself.
function LanguageTool:__Hide()
    self.isActive = false

    XGUIEng.ShowWidget("Movie", 0);
    XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Normal"), 1)
    Camera.SetControlMode(0)

    Game.GameTimeSetFactor(1)
    Stream.Pause(false)
    Sound.Pause3D(false)
end
