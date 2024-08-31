$nocompile
Gosub Open_log
Print#30 , "Lese Parameter von SD"
Print#5 , "Lese Parameter von SD"
Gosub Close_log

Const Parameter_anzahl = 31
Call Lcd_text( "Read PTT" , 1 , 84 , 3 , White , Transparent)
File_handle = Freefile()
Open "Param.cnf" For Input As #file_handle
Do
Lineinput #file_handle , Help_str
Header = Left(help_str , 5)

If Header = "PTT01" Then
Call Lcd_text( "01" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Steps_plt_x = Para_dat
Incr Chk_read
End If

If Header = "PTT02" Then
Call Lcd_text( "02" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Steps_mm_x = Para_dat
Incr Chk_read
End If

If Header = "PTT03" Then
Call Lcd_text( "03" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Steps_plt_y = Para_dat
Incr Chk_read
End If

If Header = "PTT04" Then
Call Lcd_text( "04" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Steps_mm_y = Para_dat
Incr Chk_read
End If

If Header = "PTT05" Then
Call Lcd_text( "05" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Ignoriere_nullfahrt = Para_dat
Incr Chk_read
Ignoriere_null_pa = Ignoriere_nullfahrt.0
End If

If Header = "PTT06" Then
Call Lcd_text( "06" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Man_steps_per_tic_x = Para_dat
Incr Chk_read
End If

If Header = "PTT07" Then
Call Lcd_text( "07" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Man_steps_per_tic_y = Para_dat
Incr Chk_read
End If

If Header = "PTT08" Then
Call Lcd_text( "08" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Motor_disable_prg_ende = Para_dat.0
Incr Chk_read
End If

If Header = "PTT09" Then
Call Lcd_text( "09" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Richtung_ref_fahrt_x = Para_dat.0
Incr Chk_read
End If

If Header = "PTT10" Then
Call Lcd_text( "10" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Richtung_ref_fahrt_y = Para_dat.0
Incr Chk_read
End If

If Header = "PTT11" Then
Call Lcd_text( "11" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Speed_ref_fahrt_x = Para_dat
Incr Chk_read
End If

If Header = "PTT12" Then
Call Lcd_text( "12" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Speed_ref_fahrt_y = Para_dat
Incr Chk_read
End If

If Header = "PTT16" Then
Call Lcd_text( "16" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Speed_ref_frei_fahrt_x = Para_dat
Incr Chk_read
End If

If Header = "PTT17" Then
Call Lcd_text( "17" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Speed_ref_frei_fahrt_y = Para_dat
Incr Chk_read
End If

If Header = "PTT13" Then
Call Lcd_text( "13" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Weg_ref_frei_fahrt_x = Para_dat
Incr Chk_read
End If

If Header = "PTT14" Then
Call Lcd_text( "14" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Weg_ref_frei_fahrt_y = Para_dat
Incr Chk_read
End If

If Header = "PTT15" Then
Call Lcd_text( "15" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Timer_arbeits_speed = Para_dat
Incr Chk_read
End If

If Header = "PTT18" Then
Call Lcd_text( "18" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Endschalter_x_invertiert = Para_dat.0
Incr Chk_read
End If

If Header = "PTT19" Then
Call Lcd_text( "19" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Endschalter_y_invertiert = Para_dat.0
Incr Chk_read
End If

If Header = "PTT20" Then
Call Lcd_text( "20" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Laserbrennzeit = Para_dat
Incr Chk_read
End If


If Header = "PTT21" Then
Call Lcd_text( "21" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Mm_pro_minute = Para_dat
Incr Chk_read
End If

If Header = "PTT22" Then
Call Lcd_text( "22" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Einricht_wz_aktiv = Para_dat.0
Incr Chk_read
End If

If Header = "PTT23" Then
Call Lcd_text( "23" , 100 , 84 , 3 , Yellow , Black)
Print #5 , Header ; " Gefunden"
Gosub Lese_par_sd
Einricht_wz_versatz_x = Para_dat
Incr Chk_read
End If

If Header = "PTT24" Then
Call Lcd_text( "24" , 100 , 84 , 3 , Yellow , Black)
Gosub Lese_par_sd
Einricht_wz_versatz_y = Para_dat
Incr Chk_read
Print #5 , Header ; " Gefunden" ;
End If

If Header = "PTT25" Then
Call Lcd_text( "25" , 100 , 84 , 3 , Yellow , Black)
Gosub Lese_par_sd
Laser_modul_verbaut = Para_dat.0
Incr Chk_read
Print #5 , Header ; " Gefunden" ;
End If

If Header = "PTT26" Then
Call Lcd_text( "26" , 100 , 84 , 3 , Yellow , Black)
Gosub Lese_par_sd
Teil_einnullen = Para_dat.0
Incr Chk_read
Print #5 , Header ; " Gefunden" ;
End If

If Header = "PTT27" Then
Call Lcd_text( "27" , 100 , 84 , 3 , Yellow , Black)
Gosub Lese_par_sd
Sim_mit_einricht_wz = Para_dat.0
Incr Chk_read
Print #5 , Header ; " Gefunden" ;
End If

If Header = "PTT28" Then
Call Lcd_text( "28" , 100 , 84 , 3 , Yellow , Black)
Gosub Lese_par_sd
Beladepos_x = Para_dat
Incr Chk_read
Print #5 , Header ; " Gefunden" ;
End If

If Header = "PTT29" Then
Call Lcd_text( "29" , 100 , 84 , 3 , Yellow , Black)
Gosub Lese_par_sd
Beladepos_y = Para_dat
Incr Chk_read
Print #5 , Header ; " Gefunden" ;
End If

If Header = "PTT30" Then
Call Lcd_text( "30" , 100 , 84 , 3 , Yellow , Black)
Gosub Lese_par_sd
Laser_start_zeit = Para_dat
Incr Chk_read
Print #5 , Header ; " Gefunden" ;
End If

If Header = "PTT31" Then
Call Lcd_text( "31" , 100 , 84 , 3 , Yellow , Black)
Gosub Lese_par_sd
Laser_stop_zeit = Para_dat
Incr Chk_read
Print #5 , Header ; " Gefunden" ;
End If

Loop Until Eof(file_handle) <> 0
Close #file_handle
'Berechnung des Laserweges / Sekunde
'timer tics / sekunde
Laser_weg_mm = 500000 * 60
'timer interrupts / steps pro sekunde
X_long = 65535 - Timer_arbeits_speed
Laser_weg_mm = Laser_weg_mm / X_long

'Laser weg / mm pro minute
X_long = Steps_mm_x
Laser_weg_mm = Laser_weg_mm / X_long







If Chk_read <> Parameter_anzahl Then
   Call Lcd_text( "ERR" , 100 , 84 , 3 , Red , Black)
   Help_str = "Parameter soll:" + Str(parameter_anzahl)
   Help_str = Help_str + " ist:"
   Help_str = Help_str + Str(chk_read)
   Print#5 ,
   Gosub Open_log
   Print#30 , "Parameter fehlen!!"
   Print#30 , Help_str
   Gosub Close_log
   Gosub Open_log
   Print#30 , "   CNC - ENDE"
   Gosub Close_log
   Gosub Open_log
   Print#30 , "  "
   Gosub Close_log
   Print #5 , "Error Config"
   Do
   nop
   Loop

End If
   Call Lcd_text( "OK" , 100 , 84 , 3 , Green , Black)
   Gosub Open_log
   Print#30 , "Parameter geladen und I.O"
   Gosub Close_log
Print #5 , "Parameter geladen und I.O"