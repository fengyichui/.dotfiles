
:: https://github.com/mintty/mintty/issues/573
:: https://github.com/mintty/mintty/issues/821
:: Use Fontlink fallback Consolas to YaHei
REG ADD "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Fontlink\SystemLink" /v Consolas /t REG_MULTI_SZ /d "MSYH.TTC,Microsoft YaHei UI,128,96"\0"MSYH.TTC,Microsoft YaHei UI"\0"SEGOEUI.TTF,Segoe UI,120,80"\0"SEGOEUI.TTF,Segoe UI"\0"SIMSUN.TTC,SimSun"\0"MSJH.TTC,Microsoft Jhenghei UI"\0"MEIRYO.TTC,Meiryo UI"\0"MALGUN.TTF,Malgun Gothic,128,96"\0"MALGUN.TTF,Malgun Gothic"\0"YUGOTHM.TTC,Yu Gothic UI,128,96"\0"YUGOTHM.TTC,Yu Gothic UI"\0"SEGUISYM.TTF,Segoe UI Symbol"

