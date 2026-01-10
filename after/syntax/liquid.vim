" Custom Liquid syntax for translator filters/tags
" Generated from Code/translator/src/liquid-utils.ts with extra LiquidJS filters

syn keyword liquidFilter GetCaseFactorObjects OnlyLettersNumbersDashesSpaces addGuidToObjArray addKeyPairToObjArray contained
syn keyword liquidFilter addOneMinute addTimeToDateTime applyOffsetToDate arrayTail calcAge checkCrossStreet contained
syn keyword liquidFilter checkIfAgeIsValid checkIfDateIsValid codeTable codeTableDefault codeTablePassthrough combineString contained
syn keyword liquidFilter compact concat concatNoDupe concatenate convertHeightStringtoInches contained
syn keyword liquidFilter convertInchesTothreeCharacterString convertNil convertThreeCharacterHeightStringToInches contained
syn keyword liquidFilter correctToGivenLength decodeHTMLSpecialCharacters decrement default deleteKeyInObject contained
syn keyword liquidFilter dmsToDecimalDegrees doubleEncodeXmlSpecialCharacters encodeXmlSpecialCharacters extractBadgeNumber contained
syn keyword liquidFilter extractDate fillEmpty fillRight fillRightZero filterNil findKeyValueInObjArray fixYearFormat flatten contained
syn keyword liquidFilter formatAddressWithMissingFields getCaseNum getEndOfString getIdFromPeopleObject getNestedValue contained
syn keyword liquidFilter getPersonFromPeopleObject getRawDateTime getReportNum getValueOrInnerValue getZuluTimestamp guid contained
syn keyword liquidFilter guidWrapObj isNaN isNumeric itemPropertyNamesArray jmespath jsonEncode keyValueGenerator logger contained
syn keyword liquidFilter matchListObjsByKey objAggregator objGenerator parseJsonString parseStringToDate parseStringToInt pop contained
syn keyword liquidFilter push regexMatch removeLastElement removeLeadingCharacters rtfToPlainText setValueInObject contained
syn keyword liquidFilter sortObjectsByProperty sort_natural splitObjectByKey stringifyObj stringifyWithDefault timeFormatter contained
syn keyword liquidFilter timeZoneConvert timeZoneConvertFromFormat timeZoneConverttoUTC toPascalCase toUpperElseEmptyString contained
syn keyword liquidFilter translationErrorBlockParsing updateKeyPairInObjArray updateTimeStamp zerofill contained

" Custom declaration tags from liquid-utils (different tint from control flow)
syn keyword liquidCustomDeclaration assertPresent captureJson ensureArray entityLookup newArray newGuid newObject relationshipLookup contained

" Keep the full comment block (including delimiters) in Comment highlight.
syn clear liquidComment
syn region liquidComment matchgroup=liquidComment start="{%-\=\s*comment\s*-\=%}" end="{%-\=\s*endcomment\s*-\=%}" contains=liquidTodo,@Spell containedin=ALLBUT,@liquidExempt keepend
