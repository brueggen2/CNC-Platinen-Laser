'*******************************************************************************
'******************************************************************************
'                     CNC Platinen Laser
'CPU ATXmega 128a3
'SD-Karte FAT16/32
'Konfiguration und Parameter rein auf der SD karte
'
'
'
'*******************************************************************************

Const Neue_platine = 1
'Zoll = 0
'Ralf = 1

'Const Nc_programm = "n.plt"
Const Version1 = "2"
Const Version2 = "3"

Const Laser_modul_use = 1
'Befehle (alles Binär)
'0-100 = %
'101 Start NC io
'102 Programmstart / Normal
'106 Programmstart Simulation
'103 Programmende
'104 Simulation
'105 Simulation ende

Const Logbuchname = "Log_CNC.txt"
$programmer = 16
$projecttime = 9

Config Portb.0 = Output
Test_time Alias Portb.0

$regfile = "xm128a3def.dat"
$crystal = 32000000                                         '32MHz
$hwstack = 128
$swstack = 128
$framesize = 128

'SystemQuarz / Oszilator
Config Osc = Enabled , 32mhzosc = Enabled
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1


'Interrupt Level Configuration
Config Priority = Static , Vector = Application , Lo = Enabled , Med = Enabled , Hi = Enabled       'config interrupts
Disable Interrupts



'=====[ Serial Interface to PC = COM5 ]========================================
Config Com5 = 115200 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Open "COM5:" For Binary As #5
Waitms 1


#if Laser_modul_use = 1
Config Com1 = 38400 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Enable Usartc0_rxc , Lo
Dim Lasermodul_buff As String * 9
On Usartc0_rxc Laser_com
Open "COM1:" For Binary As #1

Waitms 1



#endif

'------------------------------------------------------------------------------

''=====[ Portsetup vom UC ]====================================================
'LEDs
Led_rot Alias Portf.3 : Config Led_rot = Output : Led_rot = 1
Led_gelb Alias Portf.4 : Config Led_gelb = Output : Led_gelb = 1
Led_grun Alias Portf.5 : Config Led_grun = Output : Led_grun = 1

Motor_x_step Alias Porte.5 : Config Motor_x_step = Output
Motor_x_dir Alias Porte.6 : Config Motor_x_dir = Output
Motor_y_step Alias Porte.0 : Config Motor_y_step = Output
Motor_y_dir Alias Porte.1 : Config Motor_y_dir = Output
Motor_enable Alias Porte.4 : Config Motor_enable = Output : Motor_enable = 1
Ref_schalter_x Alias Pina.4 : Config Ref_schalter_x = Input : Porta_pin4ctrl = &B00_011_000
Ref_schalter_y Alias Pina.3 : Config Ref_schalter_y = Input : Porta_pin3ctrl = &B00_011_000

Laser Alias Portb.7 : Config Laser = Output : Laser = 0

'Interface
Enc_b Alias Pina.6 : Config Enc_b = Input : Porta_pin6ctrl = &B00_011_000
Enc_a Alias Pina.7 : Config Enc_b = Input : Porta_pin7ctrl = &B00_011_000
Enc_tast Alias Pina.5 : Config Enc_tast = Input : Porta_pin5ctrl = &B00_011_000

'------------------------------------------------------------------------------

'=====[ Varialblen Dateisystem ]===============================================
Dim Btemp1 As Byte
Dim File_handle As Byte
Dim File_names As String * 15
Dim Dateiname(30) As String * 15
Dim Gefundene_dateien As Byte
Dim Nc_programm As String * 15
'------------------------------------------------------------------------------


'=====[ Fix Varialblen Koordinatensystem / Steuerung]==========================
Dim Step_count_x As Long
Dim Step_count_y As Long
Dim Position_x As Long
Dim Position_y As Long
Dim Masch_pos_x_mm As Single
Dim Masch_pos_y_mm As Single
Dim Masch_pos_x_step As Long
Masch_pos_x_step = 0
Dim Masch_pos_y_step As Long
Masch_pos_y_step = 0
Dim Long_way As Byte
Dim New_pos_x_step As Long
Dim New_pos_y_step As Long
Dim X_prog_pos As Long
Dim Y_prog_pos As Long
Dim 2te_achse_steps As Word
Dim 2te_achse_single As Single
Dim 2te_achse_scale As Single
Dim Lange_achse As Long
Dim Compare_2te_achse As Long
Dim Single_q As Single
Dim Err1 As Bit : Err1 = 0
Dim Err_code1 As Long
Dim Step_on As Bit : Step_on = 0
Dim X_long As Long
Dim Y_long As Long
Dim X_single As Single
Dim Y_single As Single
Dim Z_single As Single
Dim Laser_next As Byte
Dim Header_pen As String * 4
Dim Min_x_prg As Long
Dim Max_x_prg As Long
Dim Min_y_prg As Long
Dim Max_y_prg As Long
Dim Ignoriere_null_pa As Bit
Dim Fahrweg_gesamt As Long
Dim Sim_achse_x As Long
Dim Sim_achse_y As Long
Dim Bohren_aktiv As Bit
Dim Fortschritt As Byte
Dim Ein_prozent As Single
Dim Rechnen_prozent As Single
Dim Aus_programm_gestartet As Bit
Aus_programm_gestartet = 0
Dim Simulation As Bit : Simulation = 0
Dim Laser_weg_mm As Long
'Dim X_test As Long : X_test = 0
'Dim Y_test As Long : Y_test = 0
'------------------------------------------------------------------------------

'Variables Encoder  -----------------------------------------------------------
Dim Bytincr As Byte                                         '=2: Encoder incr., =1: decr., =0: ./.
Dim Bytenc_old As Byte
Dim Bytenc_new As Byte
Dim Bitkey_enc As Bit
Dim Last As Bit
Dim Pointer As Byte
Last = 0
Dim Taster As Bit
Taster = 0                                                  'Encoder key, =1: pressed
Const Doublestep = 1                                        '=1: intermediate position detected
Bytenc_old = 0                                              'Encoder data
Bytenc_new = 0                                              'Encoder data
Bytincr = 0
'USer Encoder
Dim Encode As Word
Dim Encode_endlos As Bit
Encode_endlos = 0

Dim Tast_state As Bit
Dim Tast_last As Bit


'=====[ Variablen Global Programm ]============================================
Dim Help_str As String * 50
Dim Help_str2 As String * 50
Dim Time_str As String * 50
Dim L As Long
Dim B As Byte
Dim Splitt(8) As String * 50
Dim Header As String * 5
Dim Akt_line As Word
Dim Prg_zeilen As Long
Akt_line = 0
Dim Sd_size_mb As Word
Dim Sd_free_mb As Word
Dim Minuten As Byte
Dim Stunden As Byte
Dim Sekunden As Byte
Dim M_minuten As Byte
Dim M_stunden As Byte
Dim M_sekunden As Byte
Dim Free_single As Single
Dim Rec_c0 As Byte
Dim Abbruch As Bit
Dim Laser_out As Byte
'=====[ Variablen Für Zustände  ]===============================================
Dim Z_referenz As Bit : Z_referenz = 0
Dim Z_sd_karte As Bit : Z_sd_karte = 0

'Dim Z_sd_karte As Bit : Z_sd_karte = 0



'------------------------------------------------------------------------------


'=====[ EEProm Parametersystem bzw SD-Parameter]================================
Config Eeprom = Mapped
Dim Steps_mm_x As Word
Dim Steps_mm_y As Word
Dim Steps_plt_x As Word
Dim Steps_plt_y As Word
Dim Ignoriere_nullfahrt As Byte
Dim Motor_disable_prg_ende As Bit
Dim Man_steps_per_tic_x As Word
Dim Man_steps_per_tic_y As Word
Dim Para_dat As Word
Dim Richtung_ref_fahrt_x As Bit
Dim Richtung_ref_fahrt_y As Bit
Dim Speed_ref_fahrt_x As Word
Dim Speed_ref_fahrt_y As Word
Dim Speed_ref_frei_fahrt_x As Word
Dim Speed_ref_frei_fahrt_y As Word
Dim Weg_ref_frei_fahrt_y As Word
Dim Weg_ref_frei_fahrt_x As Word
Dim Timer_arbeits_speed As Word
Dim Endschalter_x_invertiert As Bit
Dim Endschalter_y_invertiert As Bit
Dim Laserbrennzeit As Word
Dim Mm_pro_minute As Word
Dim Einricht_wz_aktiv As Bit
Dim Einricht_wz_versatz_x As Integer
Dim Einricht_wz_versatz_y As Integer
Dim Laser_modul_verbaut As Bit
Dim Teil_einnullen As Bit
Dim Sim_mit_einricht_wz As Bit
Dim Chk_read As Byte
Dim Beladepos_x As Integer
Dim Beladepos_y As Integer
Dim Laser_start_zeit As Word
Dim Laser_stop_zeit As Word
Dim Gefertigte_platinen As Word
Dim E_gefertigte_platinen As Eram Word
Gefertigte_platinen = E_gefertigte_platinen
If Gefertigte_platinen > 65000 Then
E_gefertigte_platinen = 0
Gefertigte_platinen = 0
End If

Chk_read = 0
$include "config128x160LCD.bas"
Call Lcd_clear(black)
Wait 1
Help_str = Version(1)
Help_str = "Build " + Help_str
Call Lcd_text(help_str , 1 , 1 , 3 , White , Transparent)
Wait 1
Help_str = "Version " + Version1
Help_str = Help_str + "."
Help_str = Help_str + Version2
Call Lcd_text(help_str , 1 , 12 , 3 , White , Transparent)
Wait 1
Call Lcd_text( "Start Timer" , 1 , 24 , 3 , White , Transparent)
Call Lcd_text( "OK" , 100 , 24 , 3 , Green , Transparent)

'------------------------------------------------------------------------------

'=====[ Timer Konfiguration ]==================================================
'Timer C1 Für Sekundentakt
Config Tcc1 = Normal , Prescale = 1024
Tcc1_per = 31250                                            '32MHz/1024 = 31250
On Tcc1_ovf Timer_sekunde
Enable Tcc1_ovf , Lo

'Timer C0 für Motorentakt
Config Tcc0 = Normal , Prescale = 64
On Tcc0_ovf Timer_mot
Enable Tcc0_ovf , Hi

'Timer D0 Für Encoder
Config Tcd0 = Normal , Prescale = 64
Tcd0_per = 3000                                             '32MHz/1024 = 31250
On Tcd0_ovf Encode_isr
Enable Tcd0_ovf , Lo


Print#5 , "Startup"
'------------------------------------------------------------------------------

'=====[ ADC Initialisierung ]==================================================
'Spannungsmessung ADC
'Config Adca = Single , Convmode = Unsigned , Resolution = 12bit , Dma = Off , Reference = Intvcc , Event_mode = None , Prescaler = 32 , _
'Ch0_gain = 1 , Ch0_inp = Single_ended                       'you can setup other channels as well
'V = Getadc(adca , 0 , &B0_0010_000 )
'------------------------------------------------------------------------------
Print#5 , "Display Initialisiert"



Call Lcd_text( "Ini Menu" , 1 , 36 , 3 , White , Transparent)

$include "Menu_struckture.bas"
Call Lcd_text( "OK" , 100 , 36 , 3 , Green , Transparent)



Enable Interrupts

'=====[ Includes ]============================================================
Wait 1
Print#5 , "Start SD"
Call Lcd_text( "Ini SD" , 1 , 48 , 3 , White , Transparent)
#if Neue_platine = 1
$include "Config_MMCSD_HC.bas"
#else
$include "Config_Zoll_MMCSD_HC.bas"
#endif
If Gbdriveerror = 0 Then
   Call Lcd_text( "OK" , 100 , 48 , 3 , Green , Transparent)
   $include "Config_AVR-DOS.bas"
'   Led_grun = 0
   Btemp1 = Initfilesystem(1)
   Call Lcd_text( "Start DOS" , 1 , 60 , 3 , White , Transparent)
   If Btemp1 = 0 Then
      Call Lcd_text( "OK" , 100 , 60 , 3 , Green , Transparent)
      Else
      Call Lcd_text( "ERR" , 100 , 60 , 3 , Red , Transparent)
      Do
         !nop
      Loop
   End If
Else
   Call Lcd_text( "ERR" , 100 , 48 , 3 , Red , Transparent)
   Print#5 , "SD ERROR"
   Do
      nop
   Loop
End If
'------------------------------------------------------------------------------
'SD Kartengröße Anzeigen
L = Diskfree() : L = L / 1024 : Sd_free_mb = L
L = Disksize() : L = L / 1024 : Sd_size_mb = L
Print#5 , "SD I.O"
Help_str = "["
Help_str = Help_str + Str(sd_size_mb)
Help_str = Help_str + "MB]"
Call Lcd_text( "SD" , 1 , 72 , 3 , White , Transparent)
Call Lcd_text(help_str , 50 , 72 , 3 , Green , Transparent)
Wait 1
'------------------------------------------------------------------------------

Gosub Open_log
Print#30 , "*******************************************"
Print#30 , "--------  CNC Steuerung gestartet  --------"
Help_str = Version(1)
Help_str = "Build-Time ROM " + Help_str
Print#5 , Help_str
Print#30 , Help_str
Help_str = "Version " + Version1
Help_str = Help_str + "."
Help_str = Help_str + Version2
Print#30 , Help_str
Print#5 , Help_str

Gosub Close_log
$include "EE_Prom.bas"

For B = 1 To 6 Step 1
Dateiname(b) = "nix"
Next B
Call Lcd_text( "Suche .plt" , 1 , 96 , 3 , White , Transparent)
Menu = 1
Gefundene_dateien = 1
'Erstelle den Dateibaum
File_names = Dir( "*.PLT")

Dateiname(1) = File_names
While Len(file_names) > 0                                   ' if there was a file found
Incr Gefundene_dateien
File_names = Dir()
Dateiname(gefundene_dateien) = File_names                   ' get next
Wend
Decr Gefundene_dateien
'Erstes Programm anwählen
Nc_programm = Dateiname(1)
Help_str = Str(gefundene_dateien)
Help_str = Help_str + " Dateien vorhanden"
Gosub Open_log
Print#30 , "Pruefe NC Dateien"
Print#30 , Help_str
Gosub Close_log
Call Lcd_text( "OK" , 100 , 96 , 3 , Green , Transparent)
'ENDE Dateisuche

'Initialisierung Laser Modul
#if Laser_modul_use = 1
Call Lcd_text( "Wait Laser" , 1 , 108 , 3 , White , Transparent)
Lasermodul_buff = ""
Laser_out = 101
Usartc0_data = Laser_out

If Laser_modul_verbaut = 1 Then
   Do
   Header = Left(lasermodul_buff , 2)
   If Header = "OK" Then Exit Do
   Loop
   Call Lcd_text( "OK" , 100 , 108 , 3 , Green , Transparent)
Else
   Call Lcd_text( "NO" , 100 , 108 , 3 , Blue , Transparent)
End If





#endif
Help_str = Str(laser_weg_mm)
'Laser_weg_mm
Call Lcd_text( "Laser Speed" , 1 , 120 , 3 , White , Transparent)
Call Lcd_text(help_str , 100 , 120 , 3 , Blue , Transparent)
'Laser_weg_mm
Wait 1

Call Lcd_text( "Platinen" , 1 , 132 , 3 , White , Transparent)
Help_str = Str(gefertigte_platinen)
Call Lcd_text(help_str , 100 , 132 , 3 , Green , Transparent)




Wait 4
Do
If Menu = 1 Then Gosub Mainscreen
If Menu = 2 Then Gosub Referenz_screen
If Menu = 3 Then Gosub Start_auswahl
If Menu = 4 Then Gosub Fahre_positionen
If Menu = 5 Then Gosub Statisk_durchlauf
If Menu = 6 Then Gosub Manuel_fahren
If Menu = 7 Then Gosub Programm_anwahl
If Menu = 8 Then Gosub Pruefe_referenz
'Gosub Referenz_fahrt
'Taster encoder auswerten
If Enc_tast = 0 Then
   Waitms 30
   Tast_state = 0
   If Enc_tast = 0 Then Tast_state = 1
   If Tast_state = 1 And Tast_last = 0 Then Taster = 1
   Enc_tast = Tast_state
End If
Loop





























Calc_plt_code:
Gosub Open_log
Print#30 , ""
Print#30 , "##Analyse gestartet##"
Print#30 , "Programmname: " ;
Print#30 , Nc_programm
Gosub Close_log
Sim_achse_x = 0
Sim_achse_y = 0
Fahrweg_gesamt = 0
File_handle = Freefile()
Open Nc_programm For Input As #file_handle
L = Lof(#file_handle)
L = L / 1024
Help_str = Str(l) + " KBytes"
Call Lcd_clear(white)

Call Lcd_text( "Calc PRG" , 1 , 1 , 2 , Black , Transparent)
Call Lcd_text(nc_programm , 1 , 20 , 3 , Black , Transparent)
'Call Lcd_text( "Wait..." , 1 , 32 , 3 , Black , Transparent)

Call Lcd_text(help_str , 1 , 32 , 3 , Black , White)


Prg_zeilen = 0
Min_x_prg = 999999
Min_y_prg = 999999
Max_x_prg = 0
Max_y_prg = 0
Do
Lineinput #file_handle , Help_str                           '
Header = Left(help_str , 2)

'Nullfahrt erkennen, ggf überspringen
Splitt(1) = Left(help_str , 6)
If Splitt(1) = "PA0,0;" Then Goto Null_f_erk


'Fahrbahre Koordindaten
If Header = "PA" Then


'PA Entfernen
Delchar Help_str , 1
Delchar Help_str , 1
B = Split(help_str , Splitt(1) , ",")

X_prog_pos = Val(splitt(1))
'achse Y
Help_str = Splitt(2)
B = Split(help_str , Splitt(1) , ";")

Y_prog_pos = Val(splitt(1))

'Maximalmaße erkennen
If X_prog_pos < Min_x_prg Then Min_x_prg = X_prog_pos
If X_prog_pos > Max_x_prg Then Max_x_prg = X_prog_pos
If Y_prog_pos < Min_y_prg Then Min_y_prg = Y_prog_pos
If Y_prog_pos > Max_y_prg Then Max_y_prg = Y_prog_pos

'Fahrstrecke errechnen


If Sim_achse_x > X_prog_pos Then
X_long = Sim_achse_x - X_prog_pos
Else
X_long = X_prog_pos - Sim_achse_x
End If
Sim_achse_x = X_prog_pos

If Sim_achse_y > Y_prog_pos Then
Y_long = Sim_achse_y - Y_prog_pos
Else
Y_long = Y_prog_pos - Sim_achse_y
End If
Sim_achse_y = Y_prog_pos
If X_long > Y_long Then
Fahrweg_gesamt = Fahrweg_gesamt + X_long
Else
Fahrweg_gesamt = Fahrweg_gesamt + Y_long
End If







End If
Null_f_erk:
Incr Prg_zeilen
Loop Until Eof(file_handle) <> 0
Close #file_handle

Gosub Open_log
Help_str = "min x=" + Str(min_x_prg)
Call Lcd_text(help_str , 1 , 44 , 3 , Black , Transparent)
Print#30 , Help_str
Gosub Close_log
Gosub Open_log
Help_str = "min y=" + Str(min_y_prg)
Call Lcd_text(help_str , 1 , 56 , 3 , Black , Transparent)
Print#30 , Help_str
Help_str = "max x=" + Str(max_x_prg)
Call Lcd_text(help_str , 1 , 68 , 3 , Black , Transparent)
Print#30 , Help_str
Help_str = "max y=" + Str(max_y_prg)
Call Lcd_text(help_str , 1 , 80 , 3 , Black , Transparent)
Print#30 , Help_str
Help_str = "LINES=" + Str(prg_zeilen)
Call Lcd_text(help_str , 1 , 92 , 3 , Black , Transparent)
Print#30 , Help_str
Gosub Close_log
Gosub Open_log
Call Lcd_text( "platinenmas X Y" , 1 , 104 , 3 , Black , Transparent)
L = Max_x_prg - Min_x_prg
L = L / 40
Help_str = Str(l) + "mm x "
L = Max_y_prg - Min_y_prg
L = L / 40
Help_str = Help_str + Str(l)
Help_str = Help_str + "mm"
Call Lcd_text(help_str , 1 , 116 , 3 , Black , Transparent)

'PLT in mm umrechen
Fahrweg_gesamt = Fahrweg_gesamt / 40
Help_str2 = Str(fahrweg_gesamt)
Help_str2 = "Strecke " + Help_str2
Help_str2 = Help_str2 + "mm"
Taster = 0
Print#30 , Help_str2
'Mm_pro_minute
Call Lcd_text(help_str2 , 1 , 128 , 3 , Black , Transparent)
'Geplante Zeit
L = Fahrweg_gesamt / Mm_pro_minute
Help_str2 = "Laufzeit: " + Str(l)
Help_str2 = Help_str2 + "min"
Call Lcd_text(help_str2 , 1 , 140 , 3 , Black , Transparent)

Help_str = "platinenmas X Y " + Help_str
Print#30 , Help_str
Print#30 , Help_str2
Print#30 , "--------- ENDE Analyse -----------"

Gosub Close_log
Do
If Enc_tast = 0 Then
   Waitms 30
   Tast_state = 0
   If Enc_tast = 0 Then Tast_state = 1
   If Tast_state = 1 And Tast_last = 0 Then Taster = 1
   Enc_tast = Tast_state
End If
Waitms 80
Loop Until Taster = 1
Call Lcd_clear(white)
Taster = 0
Wait 1
Taster = 0
Return





Programm_abarbeiten:
Gosub Open_log
Print#30 , ""
Print#30 , "##Automatik-Programm gestartet##"
Print#30 , "Programmname: " ;
Print#30 , Nc_programm
Gosub Close_log

'Beladeposition anfahren
New_pos_x_step = Beladepos_x
New_pos_y_step = Beladepos_y
Gosub Cnc_set_drive_to_step


Gosub Calc_plt_code
Laser = 0
Laser_next = ""
If Simulation = 0 Then
Laser_out = 102
Else
Laser_out = 106
End If
Usartc0_data = Laser_out
Abbruch = 0
Rechnen_prozent = Prg_zeilen
Ein_prozent = Rechnen_prozent / 100
Akt_line = 0
Bohren_aktiv = 0

Call Lcd_clear(white)
Call Lcd_text( "Start NC_Code" , 1 , 1 , 3 , Black , White)
Call Lcd_text( "open Code..." , 1 , 20 , 3 , Black , White)
Call Lcd_text( "ini Time" , 1 , 30 , 3 , Black , White)
Minuten = 0
Sekunden = 0
Stunden = 0
File_handle = Freefile()
Open Nc_programm For Input As #file_handle
L = Lof(#file_handle)
L = L / 1024
Help_str = Str(l) + " KBytes"
Call Lcd_text(help_str , 1 , 40 , 3 , Black , White)

Do
Lineinput #file_handle , Help_str
If Ignoriere_null_pa = 1 Then
Splitt(1) = Left(help_str , 2)
If Splitt(1) = "SP" Then Bohren_aktiv = 0
Splitt(1) = Left(help_str , 6)

If Splitt(1) = "SP999;" Then Bohren_aktiv = 1

If Splitt(1) = "PA0,0;" Then Goto Null_f_ahrt
End If


                        ' read a line
Header = Left(help_str , 2)
'Fahrbahre Koordindaten
If Header = "PA" Then
'PA Entfernen
Delchar Help_str , 1
Delchar Help_str , 1
B = Split(help_str , Splitt(1) , ",")


X_prog_pos = Val(splitt(1))
'achse Y
Help_str = Splitt(2)
B = Split(help_str , Splitt(1) , ";")

Y_prog_pos = Val(splitt(1))

'PLT Option auswerten
Header_pen = ""
Header_pen = Left(splitt(2) , 2)

'Falls gewünscht teileversatz (Teil auf null legen) errechen
If Teil_einnullen = 1 Then
X_prog_pos = X_prog_pos - Min_x_prg
Y_prog_pos = Y_prog_pos - Min_y_prg
End If


If Einricht_wz_aktiv = 1 Then
If Simulation = 1 Then
If Sim_mit_einricht_wz = 1 Then
X_prog_pos = X_prog_pos + Einricht_wz_versatz_x
Y_prog_pos = Y_prog_pos + Einricht_wz_versatz_y
End If
End If
End If
'Hier koordinaten umrechen
New_pos_x_step = X_prog_pos * Steps_plt_x
New_pos_x_step = New_pos_x_step / 10

New_pos_y_step = Y_prog_pos * Steps_plt_y
New_pos_y_step = New_pos_y_step / 10
'Steps an Timer übertragen
Laser_out = Fortschritt
If Laser_out < 101 Then Usartc0_data = Laser_out

Gosub Cnc_set_drive_to_step
Incr Akt_line
Rechnen_prozent = Akt_line
Rechnen_prozent = Rechnen_prozent / Ein_prozent
Fortschritt = Rechnen_prozent
'Fortschritt an laser senden


End If

Null_f_ahrt:
'Taster auswerten
If Enc_tast = 0 Then
   Tast_state = 0
   If Enc_tast = 0 Then Tast_state = 1
   If Tast_state = 1 And Tast_last = 0 Then Taster = 1
   Enc_tast = Tast_state
End If


If Taster = 1 Then
Abbruch = 1
Taster = 0
Laser = 0
Goto E_b_abr
End If
Loop Until Eof(file_handle) <> 0
E_b_abr:
Close #file_handle
Laser = 0
Laser_next = ""
'sende Laser ende
Laser_out = 103
Usartc0_data = Laser_out
'Beladeposition anfahren
New_pos_x_step = Beladepos_x
New_pos_y_step = Beladepos_y
Gosub Cnc_set_drive_to_step
Do
If Step_on = 0 Then Exit Do
Loop
Laser = 0
Menu = 5
Taster = 0






Return


Referenz_fahrt:
'X-Achse
Call Lcd_text( "Ref. fahrt X..." , 1 , 1 , 3 , Black , White)
Motor_x_dir = Richtung_ref_fahrt_x
Do
Toggle Motor_x_step
Waitus Speed_ref_fahrt_x
Loop Until Ref_schalter_x = Endschalter_x_invertiert
Waitus Speed_ref_fahrt_x
Toggle Motor_x_dir
For L = 1 To Weg_ref_frei_fahrt_x Step 1
Toggle Motor_x_step
Waitus Speed_ref_frei_fahrt_x
Next L



Call Lcd_text( "X Referenziert" , 1 , 20 , 3 , Black , White)

'Y Achse

Call Lcd_text( "Ref. fahrt Y..." , 1 , 40 , 3 , Black , White)
Motor_y_dir = Richtung_ref_fahrt_y
Do
Toggle Motor_y_step
Waitus Speed_ref_fahrt_y
Loop Until Ref_schalter_y = Endschalter_y_invertiert
Waitms 200
Toggle Motor_y_dir
For L = 1 To Weg_ref_frei_fahrt_y Step 1
Toggle Motor_y_step
Waitus Speed_ref_frei_fahrt_y
Next L




Call Lcd_text( "Y Referenziert" , 1 , 60 , 3 , Black , White)




Wait 2
Masch_pos_x_step = 0
Masch_pos_y_step = 0
Call Lcd_clear(white)
Gosub Open_log
Print#30 , ""
Print#30 , "##Referenzpunte Angefahren##"
Gosub Close_log

Z_referenz = 1


Return
Cnc_set_drive_to_step:

Do

If Step_on = 0 Then
   If Laser_next = "U"then
      If Bohren_aktiv = 1 Then Waitms Laserbrennzeit
      Laser = 0
      Waitms Laser_stop_zeit
   End If
   If Laser_next = "D" Then
      Laser = 1
      Waitms Laser_start_zeit
   End If
   Laser_next = " "
Exit Do

End If
Loop
If Header_pen = "PU" Then Laser_next = "U"
If Header_pen = "PD" Then Laser_next = "D"







'Wait 2
'End If

'Warten auf maschinenstillstand

'Waitms 4


If Masch_pos_x_step > New_pos_x_step Then
Step_count_x = Masch_pos_x_step - New_pos_x_step
Motor_x_dir = 1
Else
Step_count_x = New_pos_x_step - Masch_pos_x_step
Motor_x_dir = 0
End If

If Masch_pos_y_step > New_pos_y_step Then
Step_count_y = Masch_pos_y_step - New_pos_y_step
Motor_y_dir = 1
Else
Step_count_y = New_pos_y_step - Masch_pos_y_step
Motor_y_dir = 0
End If

If Step_count_x > Step_count_y Then
Long_way = "x"
2te_achse_steps = Step_count_y
Lange_achse = Step_count_x
Else
2te_achse_steps = Step_count_x
Lange_achse = Step_count_y
Long_way = "z"
End If
'Kontur langsame Achse berechnen
2te_achse_single = 2te_achse_steps
Single_q = Lange_achse
2te_achse_scale = Single_q / 2te_achse_single
Single_q = Lange_achse

Step_on = 1
Return


'65500
'65300
Timer_mot:
Test_time = 1
Tcc0_cnt = Timer_arbeits_speed
If Step_on = 1 Then
   If Long_way = "x" Then

      Toggle Motor_x_step
      If Motor_x_dir = 0 Then
         Incr Masch_pos_x_step
         Else
         Decr Masch_pos_x_step
      End If
      Decr Step_count_x

      Compare_2te_achse = Single_q
      If Step_count_x < Compare_2te_achse Then
         If Step_count_y > 0 Then
            Toggle Motor_y_step
            Decr Step_count_y
            If Motor_y_dir = 0 Then
               Incr Masch_pos_y_step
            Else
               Decr Masch_pos_y_step
            End If
         End If
         Single_q = Single_q - 2te_achse_scale
      End If

      If Step_count_x = 0 Then Step_on = 0


   Else
      If Step_count_y > 0 Then
         Toggle Motor_y_step
         If Motor_y_dir = 0 Then
            Incr Masch_pos_y_step
            Else
            Decr Masch_pos_y_step
         End If
         Decr Step_count_y
      End If
      If Step_count_y = 0 Then Step_on = 0
      Compare_2te_achse = Single_q
      If Step_count_y < Compare_2te_achse Then
         If Step_count_x > 0 Then
            Toggle Motor_x_step
               If Motor_x_dir = 0 Then
               Incr Masch_pos_x_step
               Else
               Decr Masch_pos_x_step
               End If
            Decr Step_count_x
         End If
         Single_q = Single_q - 2te_achse_scale
         If Step_count_y = 0 Then Step_on = 0
      End If
   End If
End If

Test_time = 0
Return


Programm_zeilen_zaehlen:
Prg_zeilen = 0
Call Lcd_clear(white)
Call Lcd_text( "Pruefe PRG" , 1 , 1 , 3 , Black , White)
Call Lcd_text( "Anzahl Zeilen" , 1 , 20 , 3 , Black , White)
File_handle = Freefile()
Open Nc_programm For Input As #file_handle
Do
Lineinput #file_handle , Help_str
Incr Prg_zeilen
Loop Until Eof(file_handle) <> 0
Close #file_handle
Help_str = Str(prg_zeilen) + " Lines"
Call Lcd_text(help_str , 1 , 40 , 3 , Black , White)
Wait 3
Call Lcd_clear(white)
Return

Timer_sekunde:
Incr Sekunden
If Sekunden > 59 Then
Incr Minuten
Sekunden = 0
End If

If Minuten > 59 Then
Minuten = 0
Incr Stunden
End If

Incr M_sekunden
If M_sekunden > 59 Then
Incr M_minuten
M_sekunden = 0
End If

If M_minuten > 59 Then
M_minuten = 0
Incr M_stunden
End If
Return

Encode_isr:
Toggle Led_rot
   Bytenc_new.0 = Enc_a                                     'Set bit 0 of bytEnc_new
   Bytenc_new.1 = Enc_b                                     'Set bit 1 of bytEnc_new
   If Bytenc_new <> Bytenc_old Then                         'encoder is changed
      If Bytenc_new = &B00000011 And Bytenc_old = &B00000010 Then Bytincr = 2
      If Bytenc_new = &B00000011 And Bytenc_old = &B00000001 Then Bytincr = 1
      #if Doublestep = 1
               If Bytenc_new = &B00000000 And Bytenc_old = &B00000001 Then Bytincr = 2
         If Bytenc_new = &B00000000 And Bytenc_old = &B00000010 Then Bytincr = 1
      #endif
      Bytenc_old = Bytenc_new                               'old <- new for the next time
   End If
   Select Case Bytincr                                      'Set/show TRX freq.
      Case 2
      If Encode = 0 And Encode_endlos = 0 Then Encode = 1
      Decr Encode

      Case 1
      Incr Encode                                           'Encoder decremented
      If Encode = 0 And Encode_endlos = 0 Then Encode = 65535

   End Select
   Bytincr = 0
Return




Steps_umrechnen:
New_pos_x_step = X_prog_pos * Steps_plt_x
New_pos_x_step = New_pos_x_step / 10

New_pos_y_step = Y_prog_pos * Steps_plt_y
New_pos_y_step = New_pos_y_step / 10
Return

Open_log:
Open Logbuchname For Append As #30
Time_str = Str(m_stunden) + ":"
Time_str = Time_str + Str(m_minuten)
Time_str = Time_str + ":"
Time_str = Time_str + Str(m_sekunden)
Print #30 , ""
Print #30 , "$";
Print #30 , Time_str

Return
Close_log:
Close #30
Return

Lese_par_sd:
B = Split(help_str , Splitt(1) , "=")
Para_dat = Val(splitt(2))
Waitms 10
Return
#if Laser_modul_use = 1
Laser_com:
Rec_c0 = Usartc0_data
Lasermodul_buff = Lasermodul_buff + Chr(rec_c0)
Toggle Led_rot
Wait 1
Return
#endif
