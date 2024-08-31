$nocompile
'Variablen Menustruktur
Dim Menu As Byte
Dim Initialisiert As Bit
Initialisiert = 0
Dim Sel_farbe As Word

Dim R As Byte
Dim P As Byte
Dim S As Byte
Dim X_menu As Word
Dim Manuell_driving As Bit
Manuell_driving = 0
Dim Axis_select_y As Bit
Goto Ende_menu

Pruefe_referenz:
If Initialisiert = 0 Then
Encode = 4
Gosub Erstelle_kopf
Initialisiert = 1
Call Lcd_text( "Achsen" , 15 , 50 , 2 , Black , Transparent)
Call Lcd_text( "Verlust" , 15 , 70 , 2 , Black , Transparent)
Call Lcd_text( "Pruefen" , 15 , 90 , 2 , Black , Transparent)
Call Lcd_text( "Start?" , 15 , 110 , 2 , Black , Transparent)
Call Lcd_text( "Exit" , 15 , 130 , 2 , Black , Transparent)
End If
If Encode > 5 Then Encode = 5
If Encode < 4 Then Encode = 4
R = Encode
P = R * 20
P = P + 35
If S <> P Then Call Lcd_fill_circle(7 , S , 4 , White)

If Encode < 6 Then Call Lcd_fill_circle(7 , P , 4 , Black)
S = P

If Encode = 5 And Taster = 1 Then
Menu = 1
Taster = 0
Initialisiert = 0
End If

If Encode = 4 And Taster = 1 Then
Call Lcd_clear(white)
Call Lcd_text( "Messe..." , 15 , 50 , 2 , Black , Transparent)

Taster = 0
'Maschine auf 0 Fahren
New_pos_x_step = 0
New_pos_y_step = 0
Gosub Cnc_set_drive_to_step
'Warten auf bewegung ende

Do
If Step_on = 0 Then Exit Do
Loop
Wait 1
X_long = 0
Y_long = 0
Motor_x_dir = Richtung_ref_fahrt_x
Do
Incr X_long
Toggle Motor_x_step
Waitus Speed_ref_fahrt_x
Loop Until Ref_schalter_x = Endschalter_x_invertiert

Waitms 200
Toggle Motor_x_dir

For L = 1 To Weg_ref_frei_fahrt_x Step 1
Toggle Motor_x_step
Waitus Speed_ref_frei_fahrt_x
Next L
Y_long = Weg_ref_frei_fahrt_x
X_long = X_long - Y_long
Help_str = Str(x_long)
Help_str = "Verlust X=" + Help_str
Call Lcd_text(help_str , 1 , 70 , 3 , Black , White)

'Y Achse
Y_long = 0
'Call Lcd_text( "Ref. fahrt Y..." , 1 , 40 , 3 , Black , White)
Motor_y_dir = Richtung_ref_fahrt_y
Do
Toggle Motor_y_step
Incr Y_long
Waitus Speed_ref_fahrt_y
Loop Until Ref_schalter_y = Endschalter_y_invertiert
Waitms 200

Toggle Motor_y_dir
For L = 1 To Weg_ref_frei_fahrt_y Step 1
Toggle Motor_y_step
Waitus Speed_ref_frei_fahrt_y
Next L


X_long = Weg_ref_frei_fahrt_y
Y_long = Y_long - X_long
Help_str = Str(y_long)
Help_str = "Verlust Y=" + Help_str

Call Lcd_text(help_str , 1 , 90 , 3 , Black , White)
Taster = 0


Do
If Enc_tast = 0 Then
   Waitms 30
   Tast_state = 0
   If Enc_tast = 0 Then Tast_state = 1
   If Tast_state = 1 And Tast_last = 0 Then Taster = 1
   Enc_tast = Tast_state
End If
If Taster = 1 Then
Menu = 1
Taster = 0
Initialisiert = 0
Exit Do
End If
Loop





End If




Return
Programm_anwahl:
If Initialisiert = 0 Then
Encode = 1
Gosub Erstelle_kopf
Initialisiert = 1
Call Lcd_text( "Programmauswahl" , 3 , 50 , 3 , Black , Transparent)
Help_str = Str(gefundene_dateien) + "Programmme"
Call Lcd_text(help_str , 3 , 70 , 3 , Black , Transparent)


End If

If Encode > Gefundene_dateien Then Encode = Gefundene_dateien
If Encode < 1 Then Encode = 1

Help_str = Dateiname(encode)
Nc_programm = Dateiname(encode)
B = Len(help_str)
If B < 11 Then
For X_long = B To 11 Step 1
Help_str = Help_str + " "
Next X_long
End If
Call Lcd_text(help_str , 3 , 90 , 3 , Black , White)
If Taster = 1 Then
Menu = 1
Initialisiert = 0
Taster = 0
End If
Return



'Dim Dateiname(30) As String * 15
'Dim Gefundene_dateien As Byte
'Dim Nc_programm As String * 15




Fahre_positionen:
If Initialisiert = 0 Then
Encode = 0
Gosub Erstelle_kopf
Initialisiert = 1
Call Lcd_text( "->X/Y min" , 15 , 50 , 2 , Black , Transparent)
Call Lcd_text( "->X/Y max" , 15 , 70 , 2 , Black , Transparent)
Call Lcd_text( "Kontur" , 15 , 90 , 2 , Black , Transparent)
Call Lcd_text( "Check REF" , 15 , 110 , 2 , Black , Transparent)
Call Lcd_text( "Exit" , 15 , 130 , 2 , Black , Transparent)
If Einricht_wz_aktiv = 1 Then Call Lcd_text( "Einrichtwerkzeug" , 1 , 148 , 3 , Yellow , Red)
'Enrichtlaser ein
Usartc0_data = 104


End If

If Encode > 5 Then Encode = 5
If Encode = 0 Then Encode = 1
R = Encode
P = R * 20
P = P + 35
If S <> P Then Call Lcd_fill_circle(7 , S , 4 , White)

If Encode < 6 Then Call Lcd_fill_circle(7 , P , 4 , Black)
S = P
'Exit

If Encode = 3 And Taster = 1 Then
Call Lcd_clear(white)
Call Lcd_text( "WARTEN!!" , 15 , 50 , 2 , Red , Transparent)
Call Lcd_text( "->Kontur" , 15 , 70 , 2 , Black , Transparent)
Call Lcd_text( "ACHSEN" , 15 , 90 , 2 , Black , Transparent)
Call Lcd_text( "Bewegung" , 15 , 110 , 2 , Black , Transparent)
Call Lcd_text( "X Y" , 15 , 130 , 2 , Black , Transparent)
X_prog_pos = Min_x_prg
Y_prog_pos = Min_y_prg
If Einricht_wz_aktiv = 1 Then
X_prog_pos = X_prog_pos + Einricht_wz_versatz_x
Y_prog_pos = Y_prog_pos + Einricht_wz_versatz_y
End If

'Falls gewünscht teileversatz (Teil auf null legen) errechen
If Teil_einnullen = 1 Then
X_prog_pos = X_prog_pos - Min_x_prg
Y_prog_pos = Y_prog_pos - Min_y_prg
End If


'Hier koordinaten umrechen
Gosub Steps_umrechnen
Laser_next = "U"
Gosub Cnc_set_drive_to_step
'Warten auf bewegung ende
Do
If Step_on = 0 Then Exit Do
Loop

X_prog_pos = Max_x_prg
Y_prog_pos = Min_y_prg
'Falls gewünscht teileversatz (Teil auf null legen) errechen
If Teil_einnullen = 1 Then
X_prog_pos = X_prog_pos - Min_x_prg
Y_prog_pos = Y_prog_pos - Min_y_prg
End If

If Einricht_wz_aktiv = 1 Then
X_prog_pos = X_prog_pos + Einricht_wz_versatz_x
Y_prog_pos = Y_prog_pos + Einricht_wz_versatz_y
End If
'Hier koordinaten umrechen
Gosub Steps_umrechnen
Laser_next = "U"
Gosub Cnc_set_drive_to_step
'Warten auf bewegung ende
Do
If Step_on = 0 Then Exit Do
Loop


X_prog_pos = Max_x_prg
Y_prog_pos = Max_y_prg
'Falls gewünscht teileversatz (Teil auf null legen) errechen
If Teil_einnullen = 1 Then
X_prog_pos = X_prog_pos - Min_x_prg
Y_prog_pos = Y_prog_pos - Min_y_prg
End If

'Hier koordinaten umrechen
If Einricht_wz_aktiv = 1 Then
X_prog_pos = X_prog_pos + Einricht_wz_versatz_x
Y_prog_pos = Y_prog_pos + Einricht_wz_versatz_y
End If
Gosub Steps_umrechnen
Laser_next = "U"
Gosub Cnc_set_drive_to_step
'Warten auf bewegung ende
Do
If Step_on = 0 Then Exit Do
Loop

X_prog_pos = Min_x_prg
Y_prog_pos = Max_y_prg
'Falls gewünscht teileversatz (Teil auf null legen) errechen
If Teil_einnullen = 1 Then
X_prog_pos = X_prog_pos - Min_x_prg
Y_prog_pos = Y_prog_pos - Min_y_prg
End If

If Einricht_wz_aktiv = 1 Then
X_prog_pos = X_prog_pos + Einricht_wz_versatz_x
Y_prog_pos = Y_prog_pos + Einricht_wz_versatz_y
End If

'Hier koordinaten umrechen
Gosub Steps_umrechnen
Laser_next = "U"
Gosub Cnc_set_drive_to_step
'Warten auf bewegung ende
Do
If Step_on = 0 Then Exit Do
Loop

Initialisiert = 0
Taster = 0

End If



If Encode = 5 And Taster = 1 Then
Menu = 1
Taster = 0
Initialisiert = 0
'Enrichtlaser aus
Usartc0_data = 105
End If


If Encode = 1 And Taster = 1 Then
Call Lcd_clear(white)
Call Lcd_text( "WARTEN!!" , 15 , 50 , 2 , Red , Transparent)
Call Lcd_text( "->X/Y min" , 15 , 70 , 2 , Black , Transparent)
Call Lcd_text( "ACHSEN" , 15 , 90 , 2 , Black , Transparent)
Call Lcd_text( "Bewegung" , 15 , 110 , 2 , Black , Transparent)
Call Lcd_text( "X Y" , 15 , 130 , 2 , Black , Transparent)
X_prog_pos = Min_x_prg
Y_prog_pos = Min_y_prg
If Einricht_wz_aktiv = 1 Then
X_prog_pos = X_prog_pos + Einricht_wz_versatz_x
Y_prog_pos = Y_prog_pos + Einricht_wz_versatz_y
End If
'Falls gewünscht teileversatz (Teil auf null legen) errechen
If Teil_einnullen = 1 Then
X_prog_pos = X_prog_pos - Min_x_prg
Y_prog_pos = Y_prog_pos - Min_y_prg
End If

'Hier koordinaten umrechen
Gosub Steps_umrechnen
Laser_next = "U"
Gosub Cnc_set_drive_to_step
'Warten auf bewegung ende
Do
If Step_on = 0 Then Exit Do
Loop
Initialisiert = 0
Taster = 0
End If

If Encode = 2 And Taster = 1 Then
Call Lcd_clear(white)
Call Lcd_text( "WARTEN!!" , 15 , 50 , 2 , Red , Transparent)
Call Lcd_text( "->X/Y max" , 15 , 70 , 2 , Black , Transparent)
Call Lcd_text( "ACHSEN" , 15 , 90 , 2 , Black , Transparent)
Call Lcd_text( "Bewegung" , 15 , 110 , 2 , Black , Transparent)
Call Lcd_text( "X Y" , 15 , 130 , 2 , Black , Transparent)
X_prog_pos = Max_x_prg
Y_prog_pos = Max_y_prg
If Einricht_wz_aktiv = 1 Then
X_prog_pos = X_prog_pos + Einricht_wz_versatz_x
Y_prog_pos = Y_prog_pos + Einricht_wz_versatz_y
End If
'Falls gewünscht teileversatz (Teil auf null legen) errechen
If Teil_einnullen = 1 Then
X_prog_pos = X_prog_pos - Min_x_prg
Y_prog_pos = Y_prog_pos - Min_y_prg
End If

'Hier koordinaten umrechen
Gosub Steps_umrechnen
Laser_next = "U"
Gosub Cnc_set_drive_to_step
'Warten auf bewegung ende
Do
If Step_on = 0 Then Exit Do
Loop
Initialisiert = 0
Taster = 0
End If


If Encode = 4 And Taster = 1 Then
Menu = 8
Taster = 0
Initialisiert = 0
End If




Return

Statisk_durchlauf:
If Motor_disable_prg_ende = 1 And Abbruch = 0 Then Motor_enable = 1
If Initialisiert = 0 Then
Encode = 0
Gosub Erstelle_kopf
Initialisiert = 1
Call Lcd_text( "Programm " , 15 , 50 , 2 , Black , Transparent)
If Abbruch = 1 Then
Call Lcd_text( "Abbruch" , 15 , 70 , 2 , Black , Transparent)
Else
Call Lcd_text( "fertig" , 15 , 70 , 2 , Black , Transparent)
End If
Call Lcd_text( "Laufzeit" , 15 , 90 , 2 , Black , Transparent)
Gosub Open_log
Help_str = Str(stunden) + ":"
Help_str = Help_str + Str(minuten)
Help_str = Help_str + ":"
Help_str = Help_str + Str(sekunden)
If Abbruch = 1 Then
Print#30 , "Programm-Abbruch"
Else
Print#30 , "Programm-Fertig gefahren"
End If
Print#30 , "Laufzeit:";
Print#30 , Help_str
Incr Gefertigte_platinen
E_gefertigte_platinen = Gefertigte_platinen
Print#30 , "Gesamt gefertigte Platinen: ";
Help_str = Str(gefertigte_platinen)
Print#30 , Help_str
Gosub Close_log
Gosub Open_log
Print#30 , ""
Gosub Close_log
Call Lcd_text(help_str , 15 , 110 , 2 , Black , Transparent)
Call Lcd_text( "Exit" , 15 , 130 , 2 , Black , Transparent)
End If

If Taster = 1 Then
Initialisiert = 0
Menu = 1
Taster = 0
End If







Return




Start_auswahl:
If Initialisiert = 0 Then
Encode = 0
Gosub Erstelle_kopf
Initialisiert = 1
Call Lcd_text( "Calc Prg." , 15 , 50 , 2 , Black , Transparent)
Call Lcd_text( "Start PRG" , 15 , 70 , 2 , Black , Transparent)
Call Lcd_text( "Manual" , 15 , 90 , 2 , Black , Transparent)
Call Lcd_text( "Drive2Pos" , 15 , 110 , 2 , Black , Transparent)
Call Lcd_text( "Exit" , 15 , 130 , 2 , Black , Transparent)



End If

If Encode > 5 Then Encode = 5
If Encode = 0 Then Encode = 1
R = Encode
P = R * 20
P = P + 35
If S <> P Then Call Lcd_fill_circle(7 , S , 4 , White)

If Encode < 6 Then Call Lcd_fill_circle(7 , P , 4 , Black)
S = P
'Exit

If Encode = 4 And Taster = 1 Then
Menu = 4
Initialisiert = 0
End If

If Encode = 3 And Taster = 1 Then
Menu = 6
Initialisiert = 0
End If

If Encode = 5 And Taster = 1 Then
Menu = 1
Initialisiert = 0
End If


If Encode = 1 And Taster = 1 Then
Call Lcd_clear(white)
Gosub Calc_plt_code
Initialisiert = 0
Taster = 0
End If

If Encode = 2 And Taster = 1 Then
If Motor_enable = 0 Then
Call Lcd_clear(white)
Taster = 0
Aus_programm_gestartet = 1
Gosub Programm_abarbeiten

Initialisiert = 0
Taster = 0
Menu = 5
End If
Taster = 0
End If







Return

Manuel_fahren:
If Initialisiert = 0 Then
Encode = 0
Gosub Erstelle_kopf
Initialisiert = 1
Call Lcd_text( "X-Achse" , 15 , 50 , 3 , Black , Transparent)
Call Lcd_text( "Y-Achse" , 15 , 70 , 3 , Black , Transparent)
Call Lcd_text( "EXIT" , 15 , 90 , 2 , Black , Transparent)
End If

If Encode > 3 Then Encode = 3
If Encode = 0 Then Encode = 1
R = Encode
P = R * 20
P = P + 35
If S <> P Then Call Lcd_fill_circle(7 , S , 4 , White)

If Encode < 4 Then Call Lcd_fill_circle(7 , P , 4 , Black)
S = P
'Exit
If Encode = 3 And Taster = 1 Then
Menu = 1
Initialisiert = 0
End If


If Encode = 1 And Taster = 1 Then
Wait 1
Taster = 0
Encode = 500
Manuell_driving = 1
Axis_select_y = 0
End If

If Encode = 2 And Taster = 1 Then
Taster = 0
Encode = 500
Manuell_driving = 1
Axis_select_y = 1

End If

Back_man_dv:
L = Masch_pos_x_step
L = L * 10
L = L / Steps_mm_x
Help_str = Str(l)
Help_str = Format(help_str , "000.0")
Help_str = "X " + Help_str
Call Lcd_text(help_str , 1 , 115 , 2 , Yellow , Black)

L = Masch_pos_y_step
L = L * 10
L = L / Steps_mm_y
Help_str = Str(l)
Help_str = Format(help_str , "000.0")
Help_str = "Y " + Help_str
Call Lcd_text(help_str , 1 , 134 , 2 , Yellow , Black)



If Manuell_driving = 1 Then
If Encode <> 500 Then
If Encode < 500 And Axis_select_y = 1 Then New_pos_y_step = Masch_pos_y_step - Man_steps_per_tic_y
If Encode > 500 And Axis_select_y = 1 Then New_pos_y_step = Masch_pos_y_step + Man_steps_per_tic_y
If Encode < 500 And Axis_select_y = 0 Then New_pos_x_step = Masch_pos_x_step - Man_steps_per_tic_x
If Encode > 500 And Axis_select_y = 0 Then New_pos_x_step = Masch_pos_x_step + Man_steps_per_tic_x

Gosub Cnc_set_drive_to_step
Do
If Step_on = 0 Then Exit Do
Loop
Encode = 500
End If
If Enc_tast = 0 Then
   Waitms 30
   Tast_state = 0
   If Enc_tast = 0 Then Tast_state = 1
   If Tast_state = 1 And Tast_last = 0 Then Taster = 1
   Enc_tast = Tast_state
End If
If Taster = 1 Then
Manuell_driving = 0
Initialisiert = 0
Encode = 1
Goto Manuel_fahren
End If

Goto Back_man_dv
End If
Return


Referenz_screen:
If Initialisiert = 0 Then
Encode = 0
Gosub Erstelle_kopf
Initialisiert = 1
Call Lcd_text( "Motoren" , 15 , 50 , 2 , Black , Transparent)
Call Lcd_text( "Ref-Start" , 15 , 70 , 2 , Black , Transparent)
Call Lcd_text( "PC-Program" , 15 , 90 , 2 , Black , Transparent)
Call Lcd_text( "PC-Control" , 15 , 110 , 2 , Black , Transparent)
Call Lcd_text( "Exit" , 15 , 130 , 2 , Black , Transparent)


End If
If Encode > 5 Then Encode = 5
If Encode = 0 Then Encode = 1
R = Encode
P = R * 20
P = P + 35
If S <> P Then Call Lcd_fill_circle(7 , S , 4 , White)

If Encode < 6 Then Call Lcd_fill_circle(7 , P , 4 , Black)
S = P
'Exit

If Encode = 3 And Taster = 1 Then
Taster = 0
End If
If Encode = 4 And Taster = 1 Then
Taster = 0
End If


If Encode = 5 And Taster = 1 Then
Menu = 1
Initialisiert = 0
End If


If Encode = 1 And Taster = 1 Then
Toggle Motor_enable

Gosub Open_log
If Motor_enable = 0 Then Print#30 , "!!! Motoren Aktiviert"
If Motor_enable = 1 Then Print#30 , "!!! Motoren Deaktiviert"
Gosub Close_log


Initialisiert = 0
End If

If Encode = 2 And Taster = 1 Then
If Motor_enable = 0 Then
Call Lcd_clear(white)
Gosub Referenz_fahrt
Initialisiert = 0
Taster = 0
Menu = 1
End If
Taster = 0
End If


Return










Mainscreen:
If Initialisiert = 0 Then
Encode = 0
Gosub Erstelle_kopf
Initialisiert = 1
Call Lcd_text( "Referenz" , 20 , 50 , 2 , Black , Transparent)
Call Lcd_text( "Start" , 20 , 77 , 2 , Black , Transparent)
Call Lcd_text( "Prg Wahl" , 20 , 105 , 2 , Black , Transparent)
If Simulation = 1 Then
Call Lcd_text( "Sim" , 20 , 133 , 2 , Black , Transparent)
Else
Call Lcd_text( "Scharf" , 20 , 133 , 2 , Black , Transparent)
End If
End If

If Encode > 4 Then Encode = 4
If Encode = 0 Then Encode = 1
R = Encode
P = R * 28
P = P + 29
If S <> P Then Call Lcd_fill_circle(7 , S , 4 , White)

If Encode < 5 Then Call Lcd_fill_circle(7 , P , 4 , Black)
S = P

If Encode = 1 And Taster = 1 Then
Menu = 2
Initialisiert = 0
End If

If Encode = 2 And Taster = 1 Then
If Motor_enable = 0 And Z_referenz = 1 Then
Menu = 3
Initialisiert = 0
End If
Taster = 0
End If

If Encode = 3 And Taster = 1 Then
If Motor_enable = 0 And Z_referenz = 1 Then
Menu = 7
Initialisiert = 0
End If
Taster = 0
End If


If Encode = 4 And Taster = 1 Then
Toggle Simulation
If Simulation = 1 Then
Call Lcd_text( "Sim   " , 20 , 133 , 2 , Black , White)
Else
Call Lcd_text( "Scharf" , 20 , 133 , 2 , Black , White)
End If
Taster = 0
End If



Return
'Enc_tast:
'Taster = 1
'Return


Erstelle_kopf:
Taster = 0
Encode = 0
S = 1
Call Lcd_clear(white)
'Erstelle den Rahmen
Call Lcd_line(0 , 38 , 127 , 38 , 5 , Black)
Call Lcd_line(0 , 18 , 127 , 18 , 5 , Black)
Call Lcd_line(80 , 0 , 80 , 38 , 5 , Black)
'Farbbox Referenz
If Z_referenz = 1 Then
Sel_farbe = Green
Else
Sel_farbe = Red
End If
Call Lcd_box(82 , 0 , 45 , 17 , 1 , Sel_farbe , Sel_farbe)
Call Lcd_text( "REF" , 87 , 2 , 2 , Black , Transparent)
'Farbbox Motoren
If Motor_enable = 1 Then
Sel_farbe = Red
Else
Sel_farbe = Green
End If
Call Lcd_box(82 , 20 , 45 , 17 , 1 , Sel_farbe , Sel_farbe)
Call Lcd_text( "MOT" , 87 , 22 , 2 , Black , Transparent)

Help_str = Left(nc_programm , 6)
Call Lcd_text(help_str , 2 , 2 , 2 , Blue , Green)
X_menu = Sd_free_mb
X_menu = X_menu / 1024
Help_str = Str(x_menu)
Help_str = "SD" + Help_str
Help_str = Help_str + "GB"
Call Lcd_text(help_str , 2 , 22 , 2 , Blue , Green)
Taster = 0
Return




















Ende_menu: