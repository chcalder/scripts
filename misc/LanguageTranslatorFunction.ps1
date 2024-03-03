<#  
.SYNOPSIS  
    Function to support language translation.  
.DESCRIPTION      
    This script uses Google translator API for translating localization values. 

    Pass the desired text to translate in English and the what you need it to be tranlated to. 


.NOTES  
    File Name  : LanguageTranslatorFunction.ps1  
    Author     : Chris Calderon 
     
.LINK  
#>


function Translate([string]$Text, [string]$TargetLanguage)
{
    
    $LanguageHashTable = @{ 
    Afrikaans='af' 
    Albanian='sq' 
    Arabic='ar' 
    Azerbaijani='az' 
    Basque='eu' 
    Bengali='bn' 
    Belarusian='be' 
    Bulgarian='bg' 
    Catalan='ca' 
    'Chinese Simplified'='zh-CN' 
    'Chinese Traditional'='zh-TW' 
    Croatian='hr' 
    Czech='cs' 
    Danish='da' 
    Dutch='nl' 
    English='en' 
    Esperanto='eo' 
    Estonian='et' 
    Filipino='tl' 
    Finnish='fi' 
    French='fr' 
    Galician='gl' 
    Georgian='ka' 
    German='de' 
    Greek='el' 
    Gujarati='gu' 
    Haitian ='ht' 
    Creole='ht' 
    Hebrew='iw' 
    Hindi='hi' 
    Hungarian='hu' 
    Icelandic='is' 
    Indonesian='id' 
    Irish='ga' 
    Italian='it' 
    Japanese='ja' 
    Kannada='kn' 
    Korean='ko' 
    Latin='la' 
    Latvian='lv' 
    Lithuanian='lt' 
    Macedonian='mk' 
    Malay='ms' 
    Maltese='mt' 
    Norwegian='no' 
    Persian='fa' 
    Polish='pl' 
    Portuguese='pt' 
    Romanian='ro' 
    Russian='ru' 
    Serbian='sr' 
    Slovak='sk' 
    Slovenian='sl' 
    Spanish='es' 
    Swahili='sw' 
    Swedish='sv' 
    Tamil='ta' 
    Telugu='te' 
    Thai='th' 
    Turkish='tr' 
    Ukrainian='uk' 
    Urdu='ur' 
    Vietnamese='vi' 
    Welsh='cy' 
    Yiddish='yi' 
    }

    
    if ($LanguageHashTable.ContainsKey($TargetLanguage)) {
        $TargetLanguageCode = $LanguageHashTable[$TargetLanguage]
    }
    elseif ($LanguageHashTable.ContainsValue($TargetLanguage)) {
        $TargetLanguageCode = $TargetLanguage
    }
    else {
        throw "Unknown target language. Use one of the languages in the `$LanguageHashTable hashtable."
    }

    # Create a list object to store the finished translation in.
        $Translation = New-Object System.Collections.Generic.List[System.Object]
        #$input = Read-Host "Enter text to translate here"
        $Uri = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$($TargetLanguageCode)&dt=t&q=$Text"

    # Get the response from the web request, then throw a bunch of regex at it to clean it up.
        $RawResponse = (Invoke-WebRequest -Uri $Uri -Method Get).Content
        $CleanResponse = $RawResponse -split '\\r\\n' -replace '^(","?)|(null.*?\[")|\[{3}"' -split '","'
        $CleanResponse = $CleanResponse -replace "\]|\[|_en_2022q1.md|\,|", ""

    #Selecting every odd line and adding it to the $Translation list, we recreate the full translated text.
    
        $LineNumber = 0
        foreach ($Line in $CleanResponse) {
            $LineNumber++
            if($LineNumber%2) {
                $Translation.Add($Line)
            }
    }
     
    return $Translation[0]

}

# Example below:

# $Text = "Hello, my name is Chris Calderon. It's a pleasure to meet you."
# $TargetLanguage = "Filipino"

# Translate -Text $Text -TargetLanguage $TargetLanguage


