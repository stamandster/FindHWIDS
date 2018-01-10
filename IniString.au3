#include-once

#CS
	;		Name:			IniString.au3
	;
	;		Descriptions:	Functions for retrieving & modifying data from a string variable containing Ini file data
	;						Parameters, returns, and error values as per standard Ini*() functions
	;
	;		To do:		documentation
	;
	;		Authors:			ResNullius & MrCreatoR (G.Sandler)
#CE

Func _IniString_Delete(ByRef $sIni, $sSection, $sKey = Default)
	Local $sSectRegExp = "(?:\A|[\n|\r])(?:\s*)(?:\[)(?P<SectionName>.*)(?:\])"
	Local $sNamedSectRegExp = "(?i)(?:\A|[\n|\r])(?:\s*)(?:\[)(?P<SectionName>" & StringStripWS($sSection, 3) & ")(?:\])"
	Local $sCommentRegExp = "(?:\A|[\n|\r])(?:\s*)(?=;).*"
	Local $sKeyNameRegExp = "(?i)(?U)(?:\s*)(?P<Key>.*)(?:=)"
	Local $sNamedKeyRegExp = "(?i)(?U)(?:\s*)(?P<Key>" & StringStripWS($sKey, 3) & ")(?:=)"
	Local $aIni = StringSplit($sIni, @CRLF, 1), $sSectData

	For $i = 1 To $aIni[0]
		If StringRegExp($aIni[$i], $sNamedSectRegExp) Then
			If $sKey = Default Then $sSectData &= $aIni[$i] & @CRLF

			While 1
				If $i = $aIni[0] Then ExitLoop
				$i += 1

				If StringRegExp($aIni[$i], $sSectRegExp) Then ExitLoop

				If $sKey <> Default Then
					If Not StringRegExp($aIni[$i], $sCommentRegExp) And StringRegExp($aIni[$i], $sNamedKeyRegExp) Then
						$sSectData = $aIni[$i]
						If $i + 1 <= $aIni[0] Then $sSectData &= @CRLF
						ExitLoop
					EndIf
				EndIf

				$sSectData &= $aIni[$i]
				If $i + 1 <= $aIni[0] Then $sSectData &= @CRLF
			WEnd

			$sIni = StringReplace($sIni, $sSectData, "")
			Return @extended
		EndIf
	Next

	Return 0
EndFunc   ;==>_IniString_Delete

Func _IniString_Read($sIni, $sSection, $sKey, $sDefault = "")
	Local $sSectRegExp = "(?:\A|[\n|\r])(?:\s*)(?:\[)(?P<SectionName>.*)(?:\])"
	Local $sNamedSectRegExp = "(?i)(?:\A|[\n|\r])(?:\s*)(?:\[)(?P<SectionName>" & StringStripWS($sSection, 3) & ")(?:\])"
	Local $sCommentRegExp = "(?:\A|[\n|\r])(?:\s*)(?=;).*"
	Local $sNamedKeyRegExp = "(?i)(?U)(?:\s*)(?P<Key>" & StringStripWS($sKey, 3) & ")(?:=)"
	Local $sKeyValueRegExp = "(?:=)(?P<Value>.*)"
	Local $aIni = StringSplit($sIni, @CRLF, 1)

	For $i = 1 To $aIni[0]
		If StringRegExp($aIni[$i], $sNamedSectRegExp) Then
			While 1
				If $i = $aIni[0] Then ExitLoop

				$i += 1

				If StringRegExp($aIni[$i], $sSectRegExp) Then ExitLoop

				If Not StringRegExp($aIni[$i], $sCommentRegExp) And StringRegExp($aIni[$i], $sNamedKeyRegExp) Then _
						Return _Ini_StringRegExp_GetFirstMatch($aIni[$i], $sKeyValueRegExp)

			WEnd

			ExitLoop
		EndIf
	Next

	Return $sDefault
EndFunc   ;==>_IniString_Read

Func _IniString_ReadSection($sIni, $sSection)
	Local $sSectRegExp = "(?:\A|[\n|\r])(?:\s*)(?:\[)(?P<SectionName>.*)(?:\])"
	Local $sNamedSectRegExp = "(?i)(?:\A|[\n|\r])(?:\s*)(?:\[)(?P<SectionName>" & StringStripWS($sSection, 3) & ")(?:\])"
	Local $sCommentRegExp = "(?:\A|[\n|\r])(?:\s*)(?=;).*"
	Local $sKeyNameRegExp = "(?U)(?:\s*)(?P<Key>.*)(?:=)"
	Local $sKeyValueRegExp = "(?:=)(?P<Value>.*)"
	Local $aIni, $iKeyCount = 0
	Local $sKeyList, $sValueList, $aKeyList, $aValueList

	$aIni = StringSplit($sIni, @CRLF, 1)

	For $i = 1 To $aIni[0]
		If StringRegExp($aIni[$i], $sNamedSectRegExp) Then
			While 1
				If $i = $aIni[0] Then ExitLoop

				$i += 1

				If StringRegExp($aIni[$i], $sSectRegExp) Then ExitLoop

				If Not StringRegExp($aIni[$i], $sCommentRegExp) And _
						StringRegExp($aIni[$i], $sKeyNameRegExp) And _
						StringRegExp($aIni[$i], $sKeyValueRegExp) Then

					$sKeyList &= _Ini_StringRegExp_GetFirstMatch($aIni[$i], $sKeyNameRegExp) & Chr(1)
					$sValueList &= _Ini_StringRegExp_GetFirstMatch($aIni[$i], $sKeyValueRegExp) & Chr(1)
					$iKeyCount += 1
				EndIf
			WEnd

			$sKeyList = StringTrimRight($sKeyList, 1)
			$sValueList = StringTrimRight($sValueList, 1)
			$aKeyList = StringSplit($sKeyList, Chr(1))
			$aValueList = StringSplit($sValueList, Chr(1))

			Dim $aSection[$iKeyCount + 1][2]
			$aSection[0][0] = $iKeyCount

			For $i = 1 To $iKeyCount
				$aSection[$i][0] = $aKeyList[$i]
				$aSection[$i][1] = $aValueList[$i]
			Next

			Return $aSection
		EndIf

	Next

	Return SetError(1, 0, 0)
EndFunc   ;==>_IniString_ReadSection

Func _IniString_ReadSectionNames($sIni)
	Local $sSectRegExp = "(?:\A|[\n|\r])(?:\s*)(?:\[)(?P<SectionName>.*)(?:\])"
	Local $aTmpSections, $aSections, $iUbound

	$aTmpSections = StringRegExp($sIni, $sSectRegExp, 3)
	$iUbound = UBound($aTmpSections)

	If $iUbound = 0 Then Return SetError(1, 0, 0)

	Dim $aSections[$iUbound + 1]
	$aSections[0] = $iUbound

	For $i = 0 To $iUbound - 1
		$aSections[$i + 1] = $aTmpSections[$i]
	Next

	Return $aSections
EndFunc   ;==>_IniString_ReadSectionNames

Func _IniString_RenameSection(ByRef $sIni, $sOldSection, $sNewSection)
	Local $sNamedSectRegExp = "(?i)(?:\A|[\n|\r])(?:\s*)(?:\[)(?P<SectionName>" & StringStripWS($sOldSection, 3) & ")(?:\])"
	Local $aIni = StringSplit($sIni, @CRLF, 1), $sTempIni = "", $iSectExists = StringRegExp($sIni, $sNamedSectRegExp)

	If $iSectExists Then
		For $i = 1 To $aIni[0]
			If StringRegExp($aIni[$i], $sNamedSectRegExp) Then
				$sTempIni &= StringRegExpReplace($aIni[$i], $sNamedSectRegExp, "[" & $sNewSection & "]")
			Else
				$sTempIni &= $aIni[$i]
			EndIf

			If $i + 1 <= $aIni[0] Then $sTempIni &= @CRLF
		Next

		$sIni = $sTempIni

		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>_IniString_RenameSection

Func _IniString_Write(ByRef $sIni, $sSection, $sKey, $sValue)
	Local $sSectRegExp = "(?:\A|[\n|\r])(?:\s*)(?:\[)(?P<SectionName>.*)(?:\])"
	Local $sNamedSectRegExp = "(?i)(?:\A|[\n|\r])(?:\s*)(?:\[)(?P<SectionName>" & StringStripWS($sSection, 3) & ")(?:\])"
	Local $sCommentRegExp = "(?:\A|[\n|\r])(?:\s*)(?=;).*"
	Local $sNamedKeyRegExp = "(?i)(?U)(?:\s*)(?P<Key>" & StringStripWS($sKey, 3) & ")(?:=)"
	Local $sKeyValueRegExp = "(?:=)(?P<Value>.*)"
	Local $sTempIni = "", $iSectExists = 0, $iKeyExists = 0, $aIni = StringSplit($sIni, @CRLF, 1)

	For $i = 1 To $aIni[0]
		If StringRegExp($aIni[$i], $sNamedSectRegExp) Then
			$iSectExists = 1
			$sTempIni &= $aIni[$i] & @CRLF

			While 1
				If $i = $aIni[0] Then ExitLoop

				$i += 1

				If StringRegExp($aIni[$i], $sSectRegExp) Then ExitLoop

				If Not StringRegExp($aIni[$i], $sCommentRegExp) And StringRegExp($aIni[$i], $sNamedKeyRegExp) Then
					$sTempIni &= StringRegExpReplace($aIni[$i], $sKeyValueRegExp, "=" & $sValue)
					$iKeyExists = 1
					ExitLoop
				Else
					$sTempIni &= $aIni[$i]
				EndIf

				If $i + 1 <= $aIni[0] Then $sTempIni &= @CRLF
			WEnd

			If Not $iKeyExists Then
				$sTempIni = StringStripWS($sTempIni, 2)
				$sTempIni &= @CRLF & $sKey & "=" & $sValue & @CRLF & @CRLF
				$sTempIni &= $aIni[$i]
			EndIf

			If $i + 1 <= $aIni[0] Then $sTempIni &= @CRLF
		Else
			$sTempIni &= $aIni[$i]
			If $i + 1 <= $aIni[0] Then $sTempIni &= @CRLF
		EndIf
	Next

	If Not $iSectExists Then
		$sTempIni = StringStripWS($sTempIni, 2)
		$sTempIni &= @CRLF & @CRLF & "[" & $sSection & "]" & @CRLF & $sKey & "=" & $sValue
	EndIf

	$sIni = $sTempIni
	Return 1

EndFunc   ;==>_IniString_Write

Func _IniString_WriteSection(ByRef $sIni, $sSection, $data, $iIndex = 1)
	Local $sSectRegExp = "(?:\A|[\n|\r])(?:\s*)(?:\[)(?P<SectionName>.*)(?:\])"
	Local $sNamedSectRegExp = "(?i)(?:\A|[\n|\r])(?:\s*)(?:\[)(?P<SectionName>" & StringStripWS($sSection, 3) & ")(?:\])"
	Local $iSectExists = 0, $sSectName, $sSectDataToReplace, $sSectToReplace, $sSectToWrite
	Local $aSectDataToReplace, $sSectDataToWrite, $sTempIni, $iResult = 0
	Local $aIni = StringSplit($sIni, @CRLF, 1), $iDimension = 0

	$sTempIni = $sIni
	$iSectExists = StringRegExp($sIni, $sNamedSectRegExp)

	If IsArray($data) Then
		$aData = $data
		$iDimension = UBound($aData, 0)
		If $iDimension <> 2 Then Return SetError(1, 0, 0)

		If $iIndex < 0 Then Return
		For $i = $iIndex To UBound($aData) - 1
			$sSectDataToWrite &= $aData[$i][0] & "=" & $aData[$i][1] & @CRLF
		Next
	Else
		$sSectDataToWrite = StringReplace($data, @LF, @CRLF)
	EndIf

	If $iSectExists Then
		For $i = 1 To $aIni[0]
			If StringRegExp($aIni[$i], $sNamedSectRegExp) Then
				$sSectName = $aIni[$i]

				While 1
					If $i = $aIni[0] Then ExitLoop
					$i += 1
					If StringRegExp($aIni[$i], $sSectRegExp) Then ExitLoop
					$sSectDataToReplace &= $aIni[$i] & @CRLF
				WEnd
				$sSectDataToReplace = StringTrimRight($sSectDataToReplace, 2)
				$sSectToReplace = $sSectName & @CRLF & $sSectDataToReplace
				$sSectToWrite = $sSectName & @CRLF & $sSectDataToWrite
				$sTempIni = StringReplace($sTempIni, $sSectToReplace, $sSectToWrite & @CRLF)
				$iResult = @extended
			EndIf
		Next
	Else
		If StringRight($sTempIni, 1) <> @LF Then $sTempIni &= @CRLF
		$sSectToWrite = "[" & $sSection & "]" & @CRLF & $sSectDataToWrite
		$sTempIni &= @CRLF & $sSectToWrite
		$iResult = 1
	EndIf

	$sIni = $sTempIni
	Return $iResult
EndFunc   ;==>_IniString_WriteSection

Func _Ini_StringRegExp_GetFirstMatch($sString, $sRegExp)
	Local $aMatch = StringRegExp($sString, $sRegExp, 1)
	If IsArray($aMatch) Then Return $aMatch[0]
	Return 0
EndFunc   ;==>_Ini_StringRegExp_GetFirstMatch