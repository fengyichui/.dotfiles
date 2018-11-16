
:: https://github.com/mintty/mintty/issues/573
:: https://github.com/mintty/mintty/issues/821
:: Use Fontlink fallback Consolas to YaHei
REG ADD "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Fontlink\SystemLink" /v Consolas /t REG_MULTI_SZ /d "MSYH.TTC,Microsoft YaHei UI,128,96"\0"MSYH.TTC,Microsoft YaHei UI"\0"Arial.TTF,Arial,128,96"\0"Arial.TTF,Arial"
