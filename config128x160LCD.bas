$nocompile
'*******************************************************************************
'
'
'----------  Grafikdisplay Arduino 1.8" ----------------------------------------
'
'*******************************************************************************

'
'call Lcd_line(x_Start , Y_start , x_ende , Y_ende , Stiftbreite , Farbe)







'Setup

'---------

'Verwendeter Prozessor      ( 0=Atmega , 1 = ATXmega )
Const Atxmega_set = 1

'SD-Karte wird benutzt?!?
Const Sdcard_use_lcd = 1

'Wird AVR-DOS verwendet ?   ( 0 = nein  ,  1 = Ja )
Const Avr_dos_is_used = 1

'Anmerkung: Bei verwendung von AVR dos kann SPI für SD_Karte UND LCD Verwendet werden.


'Konfiguration der Steuerpins des Displays (Freie Portwahl)
Lcd_dc Alias Portd.2
Lcd_reset Alias Portd.3
Lcd_cs Alias Portd.4
'SS Pin auf Output setzen
'Config Portd.4 = Output



'Konfiguration des Displays, (wagerecht/Senkrecht) und R-G-B order
Const Modus = 0                                             '0=Portrait  1=Landscape
Const Disp_typ = 0                                          'RGB order 0=Black Tab   1=Red Tab



'Hier die Schnittstellen festlegen
'Beim Atx Fileport
#if Atxmega_set = 1
   Config Spid = Hard , Master = Yes , Mode = 0 , Clockdiv = Clk2 , Data_order = Msb
   Open "SPID" For Binary As #39
#else
   #if Avr_dos_is_used = 0
   Config Portb.0 = Output                                  'auch wenn nicht genutzt
   Portb.0 = 1
   Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = High , Phase = 1 , Clockrate = 4 , Noss = 1
   Spiinit
   #endif
#endif

Config Lcd_dc = Output
Config Lcd_reset = Output
Config Lcd_cs = Output
Lcd_cs = 1




Dim Rgb_data(260) As Byte

Const Transparent = &H1000

Const Red = &HF800
Const Green = &H07E0
Const Blue = &H001F
Const White = &HFFFF
Const Black = &H0000
Const Yellow = &HFFE0
Const Cyan = &H0410
Const Magenta = &H8010
Const Brown = &HFC00
Const Olive = &H8400
Const Light_gray = &H8410
Const Dark_gray = &H4208
Const Light_blue = &H841F
Const Light_green = &H87F0
Const Light_cyan = &H87FF
Const Light_red = &HFC10
Const Gray1 = &HC618
Const Gray2 = &HA514
Const Gray3 = &H630C
Const Gray4 = &H4208
Const Gray5 = &H2104
Const Gray6 = &H3186

Const Blue0 = &H1086
Const Blue1 = &H3188
Const Blue2 = &H4314
Const Blue3 = &H861C

Const Cyan0 = &H3D34
Const Cyan1 = &H1DF7

Const Green0 = &H0200
Const Green1 = &H0208

Dim Color_array(12) As Word
Color_array(1) = &HF800
Color_array(2) = &H0400
Color_array(3) = &H001F
Color_array(4) = &HFFFF
Color_array(5) = &H07FF
Color_array(6) = &HF81F
Color_array(7) = &HA145
Color_array(8) = &HFD20
Color_array(9) = &HFE19
Color_array(10) = &HEC1D
Color_array(11) = &H0208
Color_array(12) = &H861C


Declare Sub Lcd_write_command(byval Command As Byte)
Declare Sub Lcd_write_data(byval Da_ta As Byte)
Declare Sub Lcd_write_color(byval Color As Word)
Declare Sub Lcd_set_window(byval Xs As Byte , Byval Ys As Byte , Byval Xe As Byte , Byval Ye As Byte)
Declare Sub Lcd_clear(byval Color As Word)
Declare Sub Lcd_set_pixel(byval X As Byte , Byval Y As Byte , Byval Color As Word)
Declare Sub Lcd_text(byval S As String , Byval Xoffset As Byte , Byval Yoffset As Byte , Byval Fontset As Byte , Byval Forecolor As Word , Byval Backcolor As Word )
Declare Sub Lcd_line(byval X1 As Byte , Byval Y1 As Byte , Byval X2 As Byte , Byval Y2 As Byte , Byval Pen_width As Byte , Byval Color As Word)
Declare Sub Lcd_fill_circle(byval X As Byte , Byval Y As Byte , Byval Radius As Byte , Byval Color1 As Word)
Declare Sub Lcd_circle(byval X As Byte , Byval Y As Byte , Byval Radius As Byte , Byval Fill As Byte , Byval Color As Word)
Declare Sub Lcd_box(byval Xstart As Byte , Byval Ystart As Byte , Byval X_length As Byte , Byval Y_height As Byte , Byval Fill As Byte , Byval Color As Word , Byval Bordercolor As Word)
Declare Sub Lcd_pic(byval Xs As Byte , Byval Ys As Byte , Byval Breite As Byte , Byval Height As Byte , Byval Bnama As String)
'Declare Sub Lcd_draw_bmp(byval Filename As String , Byval Xpos As Word , Byval Ypos As Word)






Wait 1

'*******************************************************************************
' Init the display
'*******************************************************************************

 Lcd_reset = 0
 Waitms 150
 Lcd_reset = 1
 Waitms 150

 Call Lcd_write_command(&H01)                               'Softreset
 Waitms 150
 Call Lcd_write_command(&H11)                               'sleep Mode off
 Waitms 500

 Call Lcd_write_command(&Hb1)                               'frame control normal
 Call Lcd_write_data(&H01)
 Call Lcd_write_data(&H2c)
 Call Lcd_write_data(&H2d)

 Call Lcd_write_command(&Hb2)                               'frame control idle
 Call Lcd_write_data(&H01)
 Call Lcd_write_data(&H2c)
 Call Lcd_write_data(&H2d)

 Call Lcd_write_command(&Hb3)                               'frame control partial
 Call Lcd_write_data(&H01)
 Call Lcd_write_data(&H2c)
 Call Lcd_write_data(&H2d)
 Call Lcd_write_data(&H01)
 Call Lcd_write_data(&H2c)
 Call Lcd_write_data(&H2d)

 Call Lcd_write_command(&Hb4)                               'display inversion
 Call Lcd_write_data(&B0000_0111)                           '07

 Call Lcd_write_command(&Hc0)                               'power control
 Call Lcd_write_data(&H2a)                                  '2a
 Call Lcd_write_data(&H02)
 Call Lcd_write_data(&H84)

 Call Lcd_write_command(&Hc1)                               'power control2
 Call Lcd_write_data(&Hc5)

 Call Lcd_write_command(&Hc2)                               'power control3
 Call Lcd_write_data(&H0a)
 Call Lcd_write_data(&H00)

 Call Lcd_write_command(&Hc3)                               'power control4
 Call Lcd_write_data(&H8a)
 Call Lcd_write_data(&H2a)

 Call Lcd_write_command(&Hc4)                               'power control5
 Call Lcd_write_data(&H8a)
 Call Lcd_write_data(&Hee)

 Call Lcd_write_command(&Hc5)                               'power control
 Call Lcd_write_data(&H0e)

 Call Lcd_write_command(&H20)                               'no invert display

#if Modus = 1                                               'Landscape
 #if Disp_typ = 0
   Call Lcd_write_command(&H36)                             'memory access control
   Call Lcd_write_data(&Ha0)                                'R-G-B  Black tab
 #else
 Call Lcd_write_command(&H36)                               'memory access control
 Call Lcd_write_data(&Ha8)                                  'B-G-R  Red Tab
 #endif
#endif
#if Modus = 0                                               'Portrait
 #if Disp_typ = 0
   Call Lcd_write_command(&H36)                             'memory access control
   Call Lcd_write_data(&Hc0)                                'R-G-B  Black tab
 #else
 Call Lcd_write_command(&H36)                               'memory access control
 Call Lcd_write_data(&Hc8)                                  'B-G-R  Red Tab
 #endif
#endif

 Call Lcd_write_command(&H3a)                               'color mode 16Bit
 Call Lcd_write_data(&H05)

 Call Lcd_write_command(&H2a)                               'column set
 Call Lcd_write_data(&H00)
 Call Lcd_write_data(&H00)
 Call Lcd_write_data(&H00)
 Call Lcd_write_data(&H7f)                                  '127 end     7f

 Call Lcd_write_command(&H2b)                               'row set
 Call Lcd_write_data(&H00)
 Call Lcd_write_data(&H00)
 Call Lcd_write_data(&H00)
 Call Lcd_write_data(&H9f)                                  '159 end   9f
'(
 Call Lcd_write_command(&He0)
 Call Lcd_write_data(&H02)
 Call Lcd_write_data(&H1c)
 Call Lcd_write_data(&H07)
 Call Lcd_write_data(&H12)
 Call Lcd_write_data(&H37)
 Call Lcd_write_data(&H32)
 Call Lcd_write_data(&H29)
 Call Lcd_write_data(&H2d)
 Call Lcd_write_data(&H29)
 Call Lcd_write_data(&H25)
 Call Lcd_write_data(&H2b)
 Call Lcd_write_data(&H39)
 Call Lcd_write_data(&H00)
 Call Lcd_write_data(&H01)
 Call Lcd_write_data(&H03)
 Call Lcd_write_data(&H10)

 Call Lcd_write_command(&He1)
 Call Lcd_write_data(&H03)
 Call Lcd_write_data(&H1d)
 Call Lcd_write_data(&H07)
 Call Lcd_write_data(&H06)
 Call Lcd_write_data(&H2e)
 Call Lcd_write_data(&H2c)
 Call Lcd_write_data(&H29)
 Call Lcd_write_data(&H2d)
 Call Lcd_write_data(&H2e)
 Call Lcd_write_data(&H2e)
 Call Lcd_write_data(&H37)
 Call Lcd_write_data(&H3f)
 Call Lcd_write_data(&H00)
 Call Lcd_write_data(&H00)
 Call Lcd_write_data(&H02)
 Call Lcd_write_data(&H10)
')
Call Lcd_write_command(&He0)
 Call Lcd_write_data(&H0f)
 Call Lcd_write_data(&H1a)
 Call Lcd_write_data(&H0f)
 Call Lcd_write_data(&H18)
 Call Lcd_write_data(&H2f)
 Call Lcd_write_data(&H28)
 Call Lcd_write_data(&H20)
 Call Lcd_write_data(&H22)
 Call Lcd_write_data(&H1f)
 Call Lcd_write_data(&H1b)
 Call Lcd_write_data(&H23)
 Call Lcd_write_data(&H37)
 Call Lcd_write_data(&H00)
 Call Lcd_write_data(&H07)
 Call Lcd_write_data(&H02)
 Call Lcd_write_data(&H10)

 Call Lcd_write_command(&He1)
 Call Lcd_write_data(&H0f)
 Call Lcd_write_data(&H1b)
 Call Lcd_write_data(&H0f)
 Call Lcd_write_data(&H17)
 Call Lcd_write_data(&H33)
 Call Lcd_write_data(&H2c)
 Call Lcd_write_data(&H29)
 Call Lcd_write_data(&H2e)
 Call Lcd_write_data(&H30)
 Call Lcd_write_data(&H30)
 Call Lcd_write_data(&H39)
 Call Lcd_write_data(&H3f)
 Call Lcd_write_data(&H00)
 Call Lcd_write_data(&H07)
 Call Lcd_write_data(&H03)
 Call Lcd_write_data(&H10)


 Call Lcd_write_command(&H29)
 Waitms 100
 Call Lcd_write_command(&H13)


Call Lcd_clear(white)


'#############################################################################
Goto Data_ede_set_end

'*******************************************************************************

$include "Font12x16.font"
'$include "Font8x8.font"
$include "font8x12.font"
'$include "font6x10.font"
'$include "font10x16.font"
'*******************************************************************************



'*******************************************************************************
'  Draw Pic x start -- y start -- Breite -- Höhe
'  von der SD Card in Bin Daten 2 Byte per Pixel
'  umgewandelt mit dem Programm Image2LCD
'*******************************************************************************
#if Sdcard_use_lcd = 1
Sub Lcd_pic(byval Xs As Byte , Byval Ys As Byte , Byval Breite As Byte , Byval Height As Byte , Byval Bnama As String)
  Local Zael As Byte , Xb As Byte
  Local Line_len As Byte , Llen As Word
  Local Free_fi_da As Byte
  Line_len = 2 * Breite

  Xb = Breite + Xs                                          'X end
  Decr Xb
  Call Lcd_set_window(xs , Ys , Xb , Height)
'5 6 5
  Lcd_cs = 1
  Lcd_dc = 1
  Free_fi_da = Freefile()
  Open Bnama For Binary As #free_fi_da

  For Zael = 1 To Height                                    ' bis Y end Position
      Get #free_fi_da , Rgb_data(1) , , Line_len            'Daten einlesen
       Lcd_cs = 0
       #if Atxmega_set = 1
            Print #39 , Rgb_data(1) , Line_len
       #else
            Spiout Rgb_data(1) , Line_len
       #endif
   '  For Llen = 1 To Line_len                               'Pic with 128 Pixel
   '   Spiout Rgb_data(llen) , 1
   '  Next

       Lcd_cs = 1
  Next Zael
  Close #free_fi_da
End Sub
#endif


'*******************************************************************************
' Draw Box x start -- y start -- width -- height -- 1=fill 2=fill with Border 3=no fill -- color -- bordercolor
'*******************************************************************************
Sub Lcd_box(byval Xstart As Byte , Byval Ystart As Byte , Byval X_length As Byte , Byval Y_height As Byte , Byval Fill As Byte , Byval Color As Word , Byval Bordercolor As Word)
   Local Xend As Byte , Yend As Byte
   Local Pixel As Word , Zahl As Word
   Xend = Xstart + X_length
   Yend = Ystart + Y_height
 If Fill = 1 Then
   Call Lcd_set_window(xstart , Ystart , Xend , Yend)
   Incr X_length
   Incr Y_height
   Pixel = X_length * Y_height

   For Zahl = 1 To Pixel
     Call Lcd_write_color(color)
   Next
 Elseif Fill = 2 Then
   Call Lcd_set_window(xstart , Ystart , Xend , Yend)
   Incr X_length
   Incr Y_height
   Pixel = X_length * Y_height

   For Zahl = 1 To Pixel
     Call Lcd_write_color(color)
   Next
   Call Lcd_line(xstart , Ystart , Xend , Ystart , 1 , Bordercolor)
   Call Lcd_line(xstart , Yend , Xend , Yend , 1 , Bordercolor)
   Call Lcd_line(xstart , Ystart , Xstart , Yend , 1 , Bordercolor)
   Call Lcd_line(xend , Ystart , Xend , Yend , 1 , Bordercolor)
 Elseif Fill = 3 Then
   Call Lcd_line(xstart , Ystart , Xend , Ystart , 1 , Color)
   Call Lcd_line(xstart , Yend , Xend , Yend , 1 , Color)
   Call Lcd_line(xstart , Ystart , Xstart , Yend , 1 , Color)
   Call Lcd_line(xend , Ystart , Xend , Yend , 1 , Color)
 End If
End Sub
'*******************************************************************************
'draw Circle fill
'*******************************************************************************
Sub Lcd_fill_circle(byval X As Byte , Byval Y As Byte , Byval Radius As Byte , Byval Color1 As Word)
   Local Xy_radius As Integer , Zahly As Integer , Zahlx As Integer , Y1 As Integer , X1 As Integer
   Local Y11 As Integer , X11 As Integer , Xy As Integer , X2 As Byte , Y2 As Byte
    Xy_radius = Radius * Radius
    Y1 = -radius
    X1 = -radius

   For Zahly = Y1 To Radius
       Y11 = Zahly * Zahly
    For Zahlx = X1 To Radius
       X11 = Zahlx * Zahlx
       Xy = X11 + Y11
       If Xy <= Xy_radius Then
       X2 = X + Zahlx
       Y2 = Y + Zahly
       Call Lcd_set_pixel(x2 , Y2 , Color1)
       End If
    Next
   Next
End Sub


Sub Lcd_line(byval X1 As Byte , Byval Y1 As Byte , Byval X2 As Byte , Byval Y2 As Byte , Byval Pen_width As Byte , Byval Color As Word)
   Local Y As Word , X As Word , X_diff As Single , Y_diff As Single , Pos As Word
   Local X_factor As Single , X_pos As Word , Y_pos As Word , Base As Word , Pen_count As Byte
   Local Xpoint As Byte , Ypoint As Byte

   If X1 > 128 Then X1 = 128
   If X2 > 128 Then X2 = 128
   If Y1 > 160 Then Y1 = 160
   If Y2 > 160 Then Y2 = 160
   Y_diff = Y2 - Y1
   X_diff = X2 - X1
   Pos = 0

   X_factor = Abs(y_diff)
   Y = X_factor
   X_factor = Abs(x_diff)
   X = X_factor

   If Y > X Then
      X_factor = X_diff / Y_diff
      If Y1 > Y2 Then
         Swap Y1 , Y2
         Base = X2
      Else
         Base = X1
      End If
      For Y = Y1 To Y2
         X_diff = Pos * X_factor
         X_pos = X_diff
         X_pos = X_pos + Base
         Xpoint = X_pos
         Ypoint = Y
         Call Lcd_set_pixel(xpoint , Ypoint , Color)        'x_pos   Y
         For Pen_count = 2 To Pen_width
             Call Lcd_write_color(color)
         Next Pen_count
         Incr Pos
      Next Y
   Else
      X_factor = Y_diff / X_diff
      If X1 > X2 Then
          Swap X1 , X2
         Base = Y2
      Else
         Base = Y1
      End If
      For X = X1 To X2
         Y_diff = Pos * X_factor
         Y_pos = Y_diff
         Y_pos = Y_pos + Base
         Xpoint = X
         Ypoint = Y_pos
         Call Lcd_set_pixel(xpoint , Ypoint , Color)
         For Pen_count = 2 To Pen_width
             Call Lcd_write_color(color)
         Next Pen_count
         Incr Pos
      Next X
   End If
End Sub
'*******************************************************************************
' LCD draw Text
'*******************************************************************************
Sub Lcd_text(byval S As String , Xoffset As Byte , Yoffset As Byte , Fontset As Byte , Forecolor As Word , Backcolor As Word )
    Local Tempstring As String * 1 , Temp As Word           'Dim local the variables
    Local A As Word , Pixels As Byte , Count As Byte , Carcount As Byte , Lus As Byte
    Local Row As Byte , Byteseach As Byte , Blocksize As Byte , Dummy As Byte
    Local Colums As Byte , Columcount As Byte , Rowcount As Byte , Stringsize As Byte
    Local Xpos As Byte , Ypos As Byte , Pixel As Word , Pixelcount As Byte
    Stringsize = Len(s) - 1                                 'Size of the text string -1 because we must start with 0

    For Carcount = 0 To Stringsize                          'Loop for the numbers of caracters that must be displayed
      '  If Fontset = 1 Then Restore Font8x8                 'Add or remove here fontset's that you need or not,
         If Fontset = 2 Then Restore Font12x16
         If Fontset = 3 Then Restore Font8x12
       '  If Fontset = 4 Then Restore Font6x10
      '   If Fontset = 5 Then Restore Font10x16
            Temp = Carcount + 1                             'Cut the text string in seperate caracters
            Tempstring = Mid(s , Temp , 1)
            Read Row : Read Byteseach : Read Blocksize : Read Dummy       'Read the first 4 bytes from the font file
            Temp = Asc(tempstring) - 32                     'Font files start with caracter 32
            For Lus = 1 To Temp                             'Do dummie read to point to the correct line in the fontfile
               For Count = 1 To Blocksize
                   Read Pixels
               Next Count
            Next Lus
            Colums = Blocksize / Row                        'Calculate the numbers of colums
            Row = Row * 8                                   'Row is always 8 pixels high = 1 byte, so working with row in steps of 8.
            Row = Row - 1                                   'Want to start with row=0 instead of 1
            Colums = Colums - 1                             'Same for the colums
            For Rowcount = 0 To Row Step 8                  'Loop for numbers of rows
                A = Rowcount + Yoffset
                For Columcount = 0 To Colums                'Loop for numbers of Colums
                    Read Pixels
                    Xpos = Columcount                       'Do some calculation to get the caracter on the correct Xposition
                    Temp = Carcount * Byteseach
                    Xpos = Xpos + Temp
                    Xpos = Xpos + Xoffset
                    For Pixelcount = 0 To 7                 'Loop for 8 pixels to be set or not
                        Ypos = A + Pixelcount               'Each pixel on his own spot
                        Pixel = Pixels.0                    'Set the pixel (or not)
                        If Pixel = 1 Then
                           Pixel = Forecolor
                        Else
                            Pixel = Backcolor
                        End If
                        If Pixel <> Transparent Then
                        Call Lcd_set_pixel(xpos , Ypos , Pixel)
                        End If

                        Shift Pixels , Right                'Shift the byte 1 bit to the right so the next pixel comes availible
                    Next Pixelcount
                Next Columcount
            Next Rowcount
         Next Carcount
End Sub
'*******************************************************************************
'Set Pixel
'*******************************************************************************
Sub Lcd_set_pixel(byval X As Byte , Byval Y As Byte , Byval Color As Word)
   Local Xx As Byte , Yy As Byte
   Xx = X + 1
   Yy = Y + 1
   Call Lcd_set_window(x , Y , Xx , Yy)
   Call Lcd_write_color(color)
End Sub
'*******************************************************************************
'  Clear Display
'*******************************************************************************
Sub Lcd_clear(byval Color As Word)
   Local Zahl As Word
   Local Hb As Byte , Lb As Byte
   Hb = High(color)
   Lb = Low(color)

  Call Lcd_set_window(0 , 0 , 127 , 159)
  Lcd_cs = 0
  Lcd_dc = 1
  For Zahl = 1 To 20480
#if Atxmega_set = 1
   Print #39 , Hb
   Print #39 , Lb
#else
   Spiout Hb , 1
   Spiout Lb , 1
#endif

   Next
  Lcd_cs = 1
End Sub
'*******************************************************************************
'  Set Windows
'*******************************************************************************
Sub Lcd_set_window(byval Xs As Byte , Byval Ys As Byte , Byval Xe As Byte , Byval Ye As Byte)

   Call Lcd_write_command(&H2a)                             'column set x
   Call Lcd_write_data(&H00)
   Call Lcd_write_data(xs)                                  'start
   Call Lcd_write_data(&H00)
   Call Lcd_write_data(xe)                                  'end

   Call Lcd_write_command(&H2b)                             'row set  y
   Call Lcd_write_data(&H00)
   Call Lcd_write_data(ys)                                  'Start
   Call Lcd_write_data(&H00)
   Call Lcd_write_data(ye)                                  'end

   Call Lcd_write_command(&H2c)                             'write to ram
End Sub
'*******************************************************************************
' send Color Data
'*******************************************************************************
Sub Lcd_write_color(byval Color As Word)
  Local Coll As Byte , Colh As Byte
  Coll = Low(color)
  Colh = High(color)

  Lcd_cs = 0
  Lcd_dc = 1

#if Atxmega_set = 1
   Print #39 , Colh
   Print #39 , Coll
#else
   Spiout Colh , 1
   Spiout Coll , 1
#endif



  Lcd_cs = 1
End Sub
'*******************************************************************************
' send Command
'*******************************************************************************
Sub Lcd_write_command(byval Command As Byte)
 Lcd_cs = 0
 Lcd_dc = 0

#if Atxmega_set = 1
   Print #39 , Command
#else
   Spiout Command , 1
#endif
 Lcd_cs = 1
End Sub
'*******************************************************************************
'  send Data
'*******************************************************************************
Sub Lcd_write_data(byval Da_ta As Byte)
 Lcd_cs = 0
 Lcd_dc = 1
#if Atxmega_set = 1
   Print #39 , Da_ta
#else
   Spiout Da_ta , 1
#endif
 Lcd_cs = 1
End Sub

Data_ede_set_end: