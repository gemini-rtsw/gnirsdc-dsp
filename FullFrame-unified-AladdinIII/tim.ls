Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  tim.asm  Page 1



1                                 COMMENT *
2      
3                          This file is used to generate DSP code for the Gen III = ARC-22
4                                  250 MHz timing boards to operate one quadrant of an
5                                  Aladdin III infrared array with one 8-channel ARC-46 video
6                                  board.
7                                  MODIFIED L BOUCHER SO WE DON'T RUN LAST_8INROWS WFM CLOCK
8                             *
9      
10                                   PAGE    132                               ; Printronix page width - 132 columns
11     
12                         ; Include the boot and header files so addressing is easy
13                                   INCLUDE "timboot.asm"
14                         ;  This file is used to generate boot DSP code for the Gen III 250 MHz fiber
15                         ;       optic timing board = ARC22 using a DSP56303 as its main processor.
16     
17                         ; Various addressing control registers
18        FFFFFB           BCR       EQU     $FFFFFB                           ; Bus Control Register
19        FFFFF9           AAR0      EQU     $FFFFF9                           ; Address Attribute Register, channel 0
20        FFFFF8           AAR1      EQU     $FFFFF8                           ; Address Attribute Register, channel 1
21        FFFFF7           AAR2      EQU     $FFFFF7                           ; Address Attribute Register, channel 2
22        FFFFF6           AAR3      EQU     $FFFFF6                           ; Address Attribute Register, channel 3
23        FFFFFD           PCTL      EQU     $FFFFFD                           ; PLL control register
24        FFFFFE           IPRP      EQU     $FFFFFE                           ; Interrupt Priority register - Peripheral
25        FFFFFF           IPRC      EQU     $FFFFFF                           ; Interrupt Priority register - Core
26     
27                         ; Port E is the Synchronous Communications Interface (SCI) port
28        FFFF9F           PCRE      EQU     $FFFF9F                           ; Port Control Register
29        FFFF9E           PRRE      EQU     $FFFF9E                           ; Port Direction Register
30        FFFF9D           PDRE      EQU     $FFFF9D                           ; Port Data Register
31        FFFF9C           SCR       EQU     $FFFF9C                           ; SCI Control Register
32        FFFF9B           SCCR      EQU     $FFFF9B                           ; SCI Clock Control Register
33     
34        FFFF9A           SRXH      EQU     $FFFF9A                           ; SCI Receive Data Register, High byte
35        FFFF99           SRXM      EQU     $FFFF99                           ; SCI Receive Data Register, Middle byte
36        FFFF98           SRXL      EQU     $FFFF98                           ; SCI Receive Data Register, Low byte
37     
38        FFFF97           STXH      EQU     $FFFF97                           ; SCI Transmit Data register, High byte
39        FFFF96           STXM      EQU     $FFFF96                           ; SCI Transmit Data register, Middle byte
40        FFFF95           STXL      EQU     $FFFF95                           ; SCI Transmit Data register, Low byte
41     
42        FFFF94           STXA      EQU     $FFFF94                           ; SCI Transmit Address Register
43        FFFF93           SSR       EQU     $FFFF93                           ; SCI Status Register
44     
45        000009           SCITE     EQU     9                                 ; X:SCR bit set to enable the SCI transmitter
46        000008           SCIRE     EQU     8                                 ; X:SCR bit set to enable the SCI receiver
47        000000           TRNE      EQU     0                                 ; This is set in X:SSR when the transmitter
48                                                                             ;  shift and data registers are both empty
49        000001           TDRE      EQU     1                                 ; This is set in X:SSR when the transmitter
50                                                                             ;  data register is empty
51        000002           RDRF      EQU     2                                 ; X:SSR bit set when receiver register is full
52        00000F           SELSCI    EQU     15                                ; 1 for SCI to backplane, 0 to front connector
53     
54     
55                         ; ESSI Flags
56        000006           TDE       EQU     6                                 ; Set when transmitter data register is empty
57        000007           RDF       EQU     7                                 ; Set when receiver is full of data
58        000010           TE        EQU     16                                ; Transmitter enable
59     
60                         ; Phase Locked Loop initialization
61        050003           PLL_INIT  EQU     $050003                           ; PLL = 25 MHz x 2 = 100 MHz
62     
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timboot.asm  Page 2



63                         ; Port B general purpose I/O
64        FFFFC4           HPCR      EQU     $FFFFC4                           ; Control register (bits 1-6 cleared for GPIO)
65        FFFFC9           HDR       EQU     $FFFFC9                           ; Data register
66        FFFFC8           HDDR      EQU     $FFFFC8                           ; Data Direction Register bits (=1 for output)
67     
68                         ; Port C is Enhanced Synchronous Serial Port 0 = ESSI0
69        FFFFBF           PCRC      EQU     $FFFFBF                           ; Port C Control Register
70        FFFFBE           PRRC      EQU     $FFFFBE                           ; Port C Data direction Register
71        FFFFBD           PDRC      EQU     $FFFFBD                           ; Port C GPIO Data Register
72        FFFFBC           TX00      EQU     $FFFFBC                           ; Transmit Data Register #0
73        FFFFB8           RX0       EQU     $FFFFB8                           ; Receive data register
74        FFFFB7           SSISR0    EQU     $FFFFB7                           ; Status Register
75        FFFFB6           CRB0      EQU     $FFFFB6                           ; Control Register B
76        FFFFB5           CRA0      EQU     $FFFFB5                           ; Control Register A
77     
78                         ; Port D is Enhanced Synchronous Serial Port 1 = ESSI1
79        FFFFAF           PCRD      EQU     $FFFFAF                           ; Port D Control Register
80        FFFFAE           PRRD      EQU     $FFFFAE                           ; Port D Data direction Register
81        FFFFAD           PDRD      EQU     $FFFFAD                           ; Port D GPIO Data Register
82        FFFFAC           TX10      EQU     $FFFFAC                           ; Transmit Data Register 0
83        FFFFA7           SSISR1    EQU     $FFFFA7                           ; Status Register
84        FFFFA6           CRB1      EQU     $FFFFA6                           ; Control Register B
85        FFFFA5           CRA1      EQU     $FFFFA5                           ; Control Register A
86     
87                         ; Timer module addresses
88        FFFF8F           TCSR0     EQU     $FFFF8F                           ; Timer control and status register
89        FFFF8E           TLR0      EQU     $FFFF8E                           ; Timer load register = 0
90        FFFF8D           TCPR0     EQU     $FFFF8D                           ; Timer compare register = exposure time
91        FFFF8C           TCR0      EQU     $FFFF8C                           ; Timer count register = elapsed time
92        FFFF83           TPLR      EQU     $FFFF83                           ; Timer prescaler load register => milliseconds
93        FFFF82           TPCR      EQU     $FFFF82                           ; Timer prescaler count register
94        000000           TIM_BIT   EQU     0                                 ; Set to enable the timer
95        000009           TRM       EQU     9                                 ; Set to enable the timer preloading
96        000015           TCF       EQU     21                                ; Set when timer counter = compare register
97     
98                         ; Board specific addresses and constants
99        FFFFF1           RDFO      EQU     $FFFFF1                           ; Read incoming fiber optic data byte
100       FFFFF2           WRFO      EQU     $FFFFF2                           ; Write fiber optic data replies
101       FFFFF3           WRSS      EQU     $FFFFF3                           ; Write switch state
102       FFFFF5           WRLATCH   EQU     $FFFFF5                           ; Write to a latch
103       010000           RDAD      EQU     $010000                           ; Read A/D values into the DSP
104       000009           EF        EQU     9                                 ; Serial receiver empty flag
105    
106                        ; DSP port A bit equates
107       000000           PWROK     EQU     0                                 ; Power control board says power is OK
108       000001           LED1      EQU     1                                 ; Control one of two LEDs
109       000002           LVEN      EQU     2                                 ; Low voltage power enable
110       000003           HVEN      EQU     3                                 ; High voltage power enable
111       00000E           SSFHF     EQU     14                                ; Switch state FIFO half full flag
112       00000A           EXT_IN0   EQU     10                                ; External digital I/O to the timing board
113       00000B           EXT_IN1   EQU     11
114       00000C           EXT_OUT0  EQU     12
115       00000D           EXT_OUT1  EQU     13
116    
117                        ; Port D equate
118       000001           SSFEF     EQU     1                                 ; Switch state FIFO empty flag
119    
120                        ; Other equates
121       000002           WRENA     EQU     2                                 ; Enable writing to the EEPROM
122    
123                        ; Latch U25 bit equates
124       000000           CDAC      EQU     0                                 ; Clear the analog board DACs
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timboot.asm  Page 3



125       000002           ENCK      EQU     2                                 ; Enable the clock outputs
126       000004           SHUTTER   EQU     4                                 ; Control the shutter
127       000005           TIM_U_RST EQU     5                                 ; Reset the utility board
128    
129                        ; Software status bits, defined at X:<STATUS = X:0
130       000000           ST_RCV    EQU     0                                 ; Set to indicate word is from SCI = utility board
131       000002           IDLMODE   EQU     2                                 ; Set if need to idle after readout
132       000003           ST_SHUT   EQU     3                                 ; Set to indicate shutter is closed, clear for open
133       000004           ST_RDC    EQU     4                                 ; Set if executing 'RDC' command - reading out
134       000005           SPLIT_S   EQU     5                                 ; Set if split serial
135       000006           SPLIT_P   EQU     6                                 ; Set if split parallel
136       000007           MPP       EQU     7                                 ; Set if parallels are in MPP mode
137       000008           NOT_CLR   EQU     8                                 ; Set if not to clear CCD before exposure
138       00000A           TST_IMG   EQU     10                                ; Set if controller is to generate a test image
139       00000B           SHUT      EQU     11                                ; Set if opening shutter at beginning of exposure
140       00000C           ST_DITH   EQU     12                                ; Set if to dither during exposure
141       00000D           ST_SYNC   EQU     13                                ; Set if starting exposure on SYNC = high signal
142       00000E           ST_CNRD   EQU     14                                ; Set if in continous readout mode
143       00000F           ST_DIRTY  EQU     15                                ; Set if waveform tables need to be updated
144       000010           ST_SA     EQU     16                                ; Set if in subarray readout mode
145       000011           ST_CDS    EQU     17                                ; Set for correlated double sample readout
146       000012           ST_RRR    EQU     18                                ; Set if row-by-row reset while reading out and expos
ing
147    
148                        ; Address for the table containing the incoming SCI words
149       000400           SCI_TABLE EQU     $400
150    
151    
152                        ; Specify controller configuration bits of the X:STATUS word
153                        ;   to describe the software capabilities of this application file
154                        ; The bit is set (=1) if the capability is supported by the controller
155    
156    
157                                COMMENT *
158    
159                        BIT #'s         FUNCTION
160                        2,1,0           Video Processor
161                                                000     ARC41, CCD Rev. 3
162                                                001     CCD Gen I
163                                                010     ARC42, dual readout CCD
164                                                011     ARC44, 4-readout IR coadder
165                                                100     ARC45. dual readout CCD
166                                                101     ARC46 = 8-channel IR
167                                                110     ARC48 = 8 channel CCD
168                                                111     ARC47 = 4-channel CCD
169    
170                        4,3             Timing Board
171                                                00      ARC20, Rev. 4, Gen II
172                                                01      Gen I
173                                                10      ARC22, Gen III, 250 MHz
174    
175                        6,5             Utility Board
176                                                00      No utility board
177                                                01      ARC50
178    
179                        7               Shutter
180                                                0       No shutter support
181                                                1       Yes shutter support
182    
183                        9,8             Temperature readout
184                                                00      No temperature readout
185                                                01      Polynomial Diode calibration
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timboot.asm  Page 4



186                                                10      Linear temperature sensor calibration
187    
188                        10              Subarray readout
189                                                0       Not supported
190                                                1       Yes supported
191    
192                        11              Binning
193                                                0       Not supported
194                                                1       Yes supported
195    
196                        12              Split-Serial readout
197                                                0       Not supported
198                                                1       Yes supported
199    
200                        13              Split-Parallel readout
201                                                0       Not supported
202                                                1       Yes supported
203    
204                        14              MPP = Inverted parallel clocks
205                                                0       Not supported
206                                                1       Yes supported
207    
208                        16,15           Clock Driver Board
209                                                00      ARC30 or ARC31
210                                                01      ARC32, CCD and IR
211                                                11      No clock driver board (Gen I)
212    
213                        19,18,17                Special implementations
214                                                000     Somewhere else
215                                                001     Mount Laguna Observatory
216                                                010     NGST Aladdin
217                                                xxx     Other
218                                *
219    
220                        CCDVIDREV3B
221       000000                     EQU     $000000                           ; CCD Video Processor Rev. 3
222       000000           ARC41     EQU     $000000
223       000001           VIDGENI   EQU     $000001                           ; CCD Video Processor Gen I
224       000002           IRREV4    EQU     $000002                           ; IR Video Processor Rev. 4
225       000002           ARC42     EQU     $000002
226       000003           COADDER   EQU     $000003                           ; IR Coadder
227       000003           ARC44     EQU     $000003
228       000004           CCDVIDREV5 EQU    $000004                           ; Differential input CCD video Rev. 5
229       000004           ARC45     EQU     $000004
230       000005           ARC46     EQU     $000005                           ; 8-channel IR video board
231       000006           ARC48     EQU     $000006                           ; 8-channel CCD video board
232       000007           ARC47     EQU     $000007                           ; 4-channel CCD video board
233       000000           TIMREV4   EQU     $000000                           ; Timing Revision 4 = 50 MHz
234       000000           ARC20     EQU     $000000
235       000008           TIMGENI   EQU     $000008                           ; Timing Gen I = 40 MHz
236       000010           TIMREV5   EQU     $000010                           ; Timing Revision 5 = 250 MHz
237       000010           ARC22     EQU     $000010
238       008000           ARC32     EQU     $008000                           ; CCD & IR clock driver board
239       000020           UTILREV3  EQU     $000020                           ; Utility Rev. 3 supported
240       000020           ARC50     EQU     $000020
241       000080           SHUTTER_CC EQU    $000080                           ; Shutter supported
242       000100           TEMP_POLY EQU     $000100                           ; Polynomial calibration
243                        TEMP_LINEAR
244       000200                     EQU     $000200                           ; Linear calibration
245       000400           SUBARRAY  EQU     $000400                           ; Subarray readout supported
246       000800           BINNING   EQU     $000800                           ; Binning supported
247                        SPLIT_SERIAL
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timboot.asm  Page 5



248       001000                     EQU     $001000                           ; Split serial supported
249                        SPLIT_PARALLEL
250       002000                     EQU     $002000                           ; Split parallel supported
251       004000           MPP_CC    EQU     $004000                           ; Inverted clocks supported
252       018000           CLKDRVGENI EQU    $018000                           ; No clock driver board - Gen I
253       020000           MLO       EQU     $020000                           ; Set if Mount Laguna Observatory
254       040000           NGST      EQU     $040000                           ; NGST Aladdin implementation
255       100000           CONT_RD   EQU     $100000                           ; Continuous readout implemented
256    
257                        ; Special address for two words for the DSP to bootstrap code from the EEPROM
258                                  IF      @SCP("HOST","ROM")
265                                  ENDIF
266    
267                                  IF      @SCP("HOST","HOST")
268       P:000000 P:000000                   ORG     P:0,P:0
269       P:000000 P:000000 0C0190            JMP     <INIT
270       P:000001 P:000001 000000            NOP
271                                           ENDIF
272    
273                                 ;  This ISR receives serial words a byte at a time over the asynchronous
274                                 ;    serial link (SCI) and squashes them into a single 24-bit word
275       P:000002 P:000002 602400  SCI_RCV   MOVE              R0,X:<SAVE_R0           ; Save R0
276       P:000003 P:000003 052139            MOVEC             SR,X:<SAVE_SR           ; Save Status Register
277       P:000004 P:000004 60A700            MOVE              X:<SCI_R0,R0            ; Restore R0 = pointer to SCI receive regist
er
278       P:000005 P:000005 542300            MOVE              A1,X:<SAVE_A1           ; Save A1
279       P:000006 P:000006 452200            MOVE              X1,X:<SAVE_X1           ; Save X1
280       P:000007 P:000007 54A600            MOVE              X:<SCI_A1,A1            ; Get SRX value of accumulator contents
281       P:000008 P:000008 45E000            MOVE              X:(R0),X1               ; Get the SCI byte
282       P:000009 P:000009 0AD041            BCLR    #1,R0                             ; Test for the address being $FFF6 = last by
te
283       P:00000A P:00000A 000000            NOP
284       P:00000B P:00000B 000000            NOP
285       P:00000C P:00000C 000000            NOP
286       P:00000D P:00000D 205862            OR      X1,A      (R0)+                   ; Add the byte into the 24-bit word
287       P:00000E P:00000E 0E0013            JCC     <MID_BYT                          ; Not the last byte => only restore register
s
288       P:00000F P:00000F 545C00  END_BYT   MOVE              A1,X:(R4)+              ; Put the 24-bit word into the SCI buffer
289       P:000010 P:000010 60F400            MOVE              #SRXL,R0                ; Re-establish first address of SCI interfac
e
                            FFFF98
290       P:000012 P:000012 2C0000            MOVE              #0,A1                   ; For zeroing out SCI_A1
291       P:000013 P:000013 602700  MID_BYT   MOVE              R0,X:<SCI_R0            ; Save the SCI receiver address
292       P:000014 P:000014 542600            MOVE              A1,X:<SCI_A1            ; Save A1 for next interrupt
293       P:000015 P:000015 05A139            MOVEC             X:<SAVE_SR,SR           ; Restore Status Register
294       P:000016 P:000016 54A300            MOVE              X:<SAVE_A1,A1           ; Restore A1
295       P:000017 P:000017 45A200            MOVE              X:<SAVE_X1,X1           ; Restore X1
296       P:000018 P:000018 60A400            MOVE              X:<SAVE_R0,R0           ; Restore R0
297       P:000019 P:000019 000004            RTI                                       ; Return from interrupt service
298    
299                                 ; Clear error condition and interrupt on SCI receiver
300       P:00001A P:00001A 077013  CLR_ERR   MOVEP             X:SSR,X:RCV_ERR         ; Read SCI status register
                            000025
301       P:00001C P:00001C 077018            MOVEP             X:SRXL,X:RCV_ERR        ; This clears any error
                            000025
302       P:00001E P:00001E 000004            RTI
303    
304       P:00001F P:00001F                   DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
305       P:000030 P:000030                   DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
306       P:000040 P:000040                   DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
307    
308                                 ; Tune the table so the following instruction is at P:$50 exactly.
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timboot.asm  Page 6



309       P:000050 P:000050 0D0002            JSR     SCI_RCV                           ; SCI receive data interrupt
310       P:000051 P:000051 000000            NOP
311       P:000052 P:000052 0D001A            JSR     CLR_ERR                           ; SCI receive error interrupt
312       P:000053 P:000053 000000            NOP
313    
314                                 ; *******************  Command Processing  ******************
315    
316                                 ; Read the header and check it for self-consistency
317       P:000054 P:000054 609F00  START     MOVE              X:<IDL_ADR,R0
318       P:000055 P:000055 018FA0            JSET    #TIM_BIT,X:TCSR0,EXPOSING         ; If exposing go check the timer
                            00045C
319       P:000057 P:000057 0A00A4            JSET    #ST_RDC,X:<STATUS,CONTINUE_READING
                            100000
320       P:000059 P:000059 0AE080            JMP     (R0)
321    
322       P:00005A P:00005A 330700  TST_RCV   MOVE              #<COM_BUF,R3
323       P:00005B P:00005B 0D00A5            JSR     <GET_RCV
324       P:00005C P:00005C 0E005B            JCC     *-1
325    
326                                 ; Check the header and read all the remaining words in the command
327       P:00005D P:00005D 0C00FF  PRC_RCV   JMP     <CHK_HDR                          ; Update HEADER and NWORDS
328       P:00005E P:00005E 578600  PR_RCV    MOVE              X:<NWORDS,B             ; Read this many words total in the command
329       P:00005F P:00005F 000000            NOP
330       P:000060 P:000060 01418C            SUB     #1,B                              ; We've already read the header
331       P:000061 P:000061 000000            NOP
332       P:000062 P:000062 06CF00            DO      B,RD_COM
                            00006A
333       P:000064 P:000064 205B00            MOVE              (R3)+                   ; Increment past what's been read already
334       P:000065 P:000065 0B0080  GET_WRD   JSCLR   #ST_RCV,X:STATUS,CHK_FO
                            0000A9
335       P:000067 P:000067 0B00A0            JSSET   #ST_RCV,X:STATUS,CHK_SCI
                            0000D5
336       P:000069 P:000069 0E0065            JCC     <GET_WRD
337       P:00006A P:00006A 000000            NOP
338       P:00006B P:00006B 330700  RD_COM    MOVE              #<COM_BUF,R3            ; Restore R3 = beginning of the command
339    
340                                 ; Is this command for the timing board?
341       P:00006C P:00006C 448500            MOVE              X:<HEADER,X0
342       P:00006D P:00006D 579B00            MOVE              X:<DMASK,B
343       P:00006E P:00006E 459A4E            AND     X0,B      X:<TIM_DRB,X1           ; Extract destination byte
344       P:00006F P:00006F 20006D            CMP     X1,B                              ; Does header = timing board number?
345       P:000070 P:000070 0EA080            JEQ     <COMMAND                          ; Yes, process it here
346       P:000071 P:000071 0E909D            JLT     <FO_XMT                           ; Send it to fiber optic transmitter
347    
348                                 ; Transmit the command to the utility board over the SCI port
349       P:000072 P:000072 060600            DO      X:<NWORDS,DON_XMT                 ; Transmit NWORDS
                            00007E
350       P:000074 P:000074 60F400            MOVE              #STXL,R0                ; SCI first byte address
                            FFFF95
351       P:000076 P:000076 44DB00            MOVE              X:(R3)+,X0              ; Get the 24-bit word to transmit
352       P:000077 P:000077 060380            DO      #3,SCI_SPT
                            00007D
353       P:000079 P:000079 019381            JCLR    #TDRE,X:SSR,*                     ; Continue ONLY if SCI XMT is empty
                            000079
354       P:00007B P:00007B 445800            MOVE              X0,X:(R0)+              ; Write to SCI, byte pointer + 1
355       P:00007C P:00007C 000000            NOP                                       ; Delay for the status flag to be set
356       P:00007D P:00007D 000000            NOP
357                                 SCI_SPT
358       P:00007E P:00007E 000000            NOP
359                                 DON_XMT
360       P:00007F P:00007F 0C0054            JMP     <START
361    
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timboot.asm  Page 7



362                                 ; Process the receiver entry - is it in the command table ?
363       P:000080 P:000080 0203DF  COMMAND   MOVE              X:(R3+1),B              ; Get the command
364       P:000081 P:000081 205B00            MOVE              (R3)+
365       P:000082 P:000082 205B00            MOVE              (R3)+                   ; Point R3 to the first argument
366       P:000083 P:000083 302800            MOVE              #<COM_TBL,R0            ; Get the command table starting address
367       P:000084 P:000084 062680            DO      #NUM_COM,END_COM                  ; Loop over the command table
                            00008B
368       P:000086 P:000086 47D800            MOVE              X:(R0)+,Y1              ; Get the command table entry
369       P:000087 P:000087 62E07D            CMP     Y1,B      X:(R0),R2               ; Does receiver = table entries address?
370       P:000088 P:000088 0E208B            JNE     <NOT_COM                          ; No, keep looping
371       P:000089 P:000089 00008C            ENDDO                                     ; Restore the DO loop system registers
372       P:00008A P:00008A 0AE280            JMP     (R2)                              ; Jump execution to the command
373       P:00008B P:00008B 205800  NOT_COM   MOVE              (R0)+                   ; Increment the register past the table addr
ess
374                                 END_COM
375       P:00008C P:00008C 0C008D            JMP     <ERROR                            ; The command is not in the table
376    
377                                 ; It's not in the command table - send an error message
378       P:00008D P:00008D 479D00  ERROR     MOVE              X:<ERR,Y1               ; Send the message - there was an error
379       P:00008E P:00008E 0C0090            JMP     <FINISH1                          ; This protects against unknown commands
380    
381                                 ; Send a reply packet - header and reply
382       P:00008F P:00008F 479800  FINISH    MOVE              X:<DONE,Y1              ; Send 'DON' as the reply
383       P:000090 P:000090 578500  FINISH1   MOVE              X:<HEADER,B             ; Get header of incoming command
384       P:000091 P:000091 469C00            MOVE              X:<SMASK,Y0             ; This was the source byte, and is to
385       P:000092 P:000092 330700            MOVE              #<COM_BUF,R3            ;     become the destination byte
386       P:000093 P:000093 46935E            AND     Y0,B      X:<TWO,Y0
387       P:000094 P:000094 0C1ED1            LSR     #8,B                              ; Shift right eight bytes, add it to the
388       P:000095 P:000095 460600            MOVE              Y0,X:<NWORDS            ;     header, and put 2 as the number
389       P:000096 P:000096 469958            ADD     Y0,B      X:<SBRD,Y0              ;     of words in the string
390       P:000097 P:000097 200058            ADD     Y0,B                              ; Add source board's header, set Y1 for abov
e
391       P:000098 P:000098 000000            NOP
392       P:000099 P:000099 575B00            MOVE              B,X:(R3)+               ; Put the new header on the transmitter stac
k
393       P:00009A P:00009A 475B00            MOVE              Y1,X:(R3)+              ; Put the argument on the transmitter stack
394       P:00009B P:00009B 570500            MOVE              B,X:<HEADER
395       P:00009C P:00009C 0C006B            JMP     <RD_COM                           ; Decide where to send the reply, and do it
396    
397                                 ; Transmit words to the host computer over the fiber optics link
398       P:00009D P:00009D 63F400  FO_XMT    MOVE              #COM_BUF,R3
                            000007
399       P:00009F P:00009F 060600            DO      X:<NWORDS,DON_FFO                 ; Transmit all the words in the command
                            0000A3
400       P:0000A1 P:0000A1 57DB00            MOVE              X:(R3)+,B
401       P:0000A2 P:0000A2 0D00EB            JSR     <XMT_WRD
402       P:0000A3 P:0000A3 000000            NOP
403       P:0000A4 P:0000A4 0C0054  DON_FFO   JMP     <START
404    
405                                 ; Check for commands from the fiber optic FIFO and the utility board (SCI)
406       P:0000A5 P:0000A5 0D00A9  GET_RCV   JSR     <CHK_FO                           ; Check for fiber optic command from FIFO
407       P:0000A6 P:0000A6 0E80A8            JCS     <RCV_RTS                          ; If there's a command, check the header
408       P:0000A7 P:0000A7 0D00D5            JSR     <CHK_SCI                          ; Check for an SCI command
409       P:0000A8 P:0000A8 00000C  RCV_RTS   RTS
410    
411                                 ; Because of FIFO metastability require that EF be stable for two tests
412       P:0000A9 P:0000A9 0A8989  CHK_FO    JCLR    #EF,X:HDR,TST2                    ; EF = Low,  Low  => CLR SR, return
                            0000AC
413       P:0000AB P:0000AB 0C00AF            JMP     <TST3                             ;      High, Low  => try again
414       P:0000AC P:0000AC 0A8989  TST2      JCLR    #EF,X:HDR,CLR_CC                  ;      Low,  High => try again
                            0000D1
415       P:0000AE P:0000AE 0C00A9            JMP     <CHK_FO                           ;      High, High => read FIFO
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timboot.asm  Page 8



416       P:0000AF P:0000AF 0A8989  TST3      JCLR    #EF,X:HDR,CHK_FO
                            0000A9
417    
418       P:0000B1 P:0000B1 08F4BB            MOVEP             #$028FE2,X:BCR          ; Slow down RDFO access
                            028FE2
419       P:0000B3 P:0000B3 000000            NOP
420       P:0000B4 P:0000B4 000000            NOP
421       P:0000B5 P:0000B5 5FF000            MOVE                          Y:RDFO,B
                            FFFFF1
422       P:0000B7 P:0000B7 2B0000            MOVE              #0,B2
423       P:0000B8 P:0000B8 0140CE            AND     #$FF,B
                            0000FF
424       P:0000BA P:0000BA 0140CD            CMP     #>$AC,B                           ; It must be $AC to be a valid word
                            0000AC
425       P:0000BC P:0000BC 0E20D1            JNE     <CLR_CC
426       P:0000BD P:0000BD 4EF000            MOVE                          Y:RDFO,Y0   ; Read the MS byte
                            FFFFF1
427       P:0000BF P:0000BF 0C1951            INSERT  #$008010,Y0,B
                            008010
428       P:0000C1 P:0000C1 4EF000            MOVE                          Y:RDFO,Y0   ; Read the middle byte
                            FFFFF1
429       P:0000C3 P:0000C3 0C1951            INSERT  #$008008,Y0,B
                            008008
430       P:0000C5 P:0000C5 4EF000            MOVE                          Y:RDFO,Y0   ; Read the LS byte
                            FFFFF1
431       P:0000C7 P:0000C7 0C1951            INSERT  #$008000,Y0,B
                            008000
432       P:0000C9 P:0000C9 000000            NOP
433       P:0000CA P:0000CA 516300            MOVE              B0,X:(R3)               ; Put the word into COM_BUF
434       P:0000CB P:0000CB 0A0000            BCLR    #ST_RCV,X:<STATUS                 ; Its a command from the host computer
435       P:0000CC P:0000CC 000000  SET_CC    NOP
436       P:0000CD P:0000CD 0AF960            BSET    #0,SR                             ; Valid word => SR carry bit = 1
437       P:0000CE P:0000CE 08F4BB            MOVEP             #$028FE1,X:BCR          ; Restore RDFO access
                            028FE1
438       P:0000D0 P:0000D0 00000C            RTS
439       P:0000D1 P:0000D1 0AF940  CLR_CC    BCLR    #0,SR                             ; Not valid word => SR carry bit = 0
440       P:0000D2 P:0000D2 08F4BB            MOVEP             #$028FE1,X:BCR          ; Restore RDFO access
                            028FE1
441       P:0000D4 P:0000D4 00000C            RTS
442    
443                                 ; Test the SCI (= synchronous communications interface) for new words
444       P:0000D5 P:0000D5 44F000  CHK_SCI   MOVE              X:(SCI_TABLE+33),X0
                            000421
445       P:0000D7 P:0000D7 228E00            MOVE              R4,A
446       P:0000D8 P:0000D8 209000            MOVE              X0,R0
447       P:0000D9 P:0000D9 200045            CMP     X0,A
448       P:0000DA P:0000DA 0EA0D1            JEQ     <CLR_CC                           ; There is no new SCI word
449       P:0000DB P:0000DB 44D800            MOVE              X:(R0)+,X0
450       P:0000DC P:0000DC 446300            MOVE              X0,X:(R3)
451       P:0000DD P:0000DD 220E00            MOVE              R0,A
452       P:0000DE P:0000DE 0140C5            CMP     #(SCI_TABLE+32),A                 ; Wrap it around the circular
                            000420
453       P:0000E0 P:0000E0 0EA0E4            JEQ     <INIT_PROCESSED_SCI               ;   buffer boundary
454       P:0000E1 P:0000E1 547000            MOVE              A1,X:(SCI_TABLE+33)
                            000421
455       P:0000E3 P:0000E3 0C00E9            JMP     <SCI_END
456                                 INIT_PROCESSED_SCI
457       P:0000E4 P:0000E4 56F400            MOVE              #SCI_TABLE,A
                            000400
458       P:0000E6 P:0000E6 000000            NOP
459       P:0000E7 P:0000E7 567000            MOVE              A,X:(SCI_TABLE+33)
                            000421
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timboot.asm  Page 9



460       P:0000E9 P:0000E9 0A0020  SCI_END   BSET    #ST_RCV,X:<STATUS                 ; Its a utility board (SCI) word
461       P:0000EA P:0000EA 0C00CC            JMP     <SET_CC
462    
463                                 ; Transmit the word in B1 to the host computer over the fiber optic data link
464                                 XMT_WRD
465       P:0000EB P:0000EB 08F4BB            MOVEP             #$028FE2,X:BCR          ; Slow down RDFO access
                            028FE2
466       P:0000ED P:0000ED 60F400            MOVE              #FO_HDR+1,R0
                            000002
467       P:0000EF P:0000EF 060380            DO      #3,XMT_WRD1
                            0000F3
468       P:0000F1 P:0000F1 0C1D91            ASL     #8,B,B
469       P:0000F2 P:0000F2 000000            NOP
470       P:0000F3 P:0000F3 535800            MOVE              B2,X:(R0)+
471                                 XMT_WRD1
472       P:0000F4 P:0000F4 60F400            MOVE              #FO_HDR,R0
                            000001
473       P:0000F6 P:0000F6 61F400            MOVE              #WRFO,R1
                            FFFFF2
474       P:0000F8 P:0000F8 060480            DO      #4,XMT_WRD2
                            0000FB
475       P:0000FA P:0000FA 46D800            MOVE              X:(R0)+,Y0              ; Should be MOVEP  X:(R0)+,Y:WRFO
476       P:0000FB P:0000FB 4E6100            MOVE                          Y0,Y:(R1)
477                                 XMT_WRD2
478       P:0000FC P:0000FC 08F4BB            MOVEP             #$028FE1,X:BCR          ; Restore RDFO access
                            028FE1
479       P:0000FE P:0000FE 00000C            RTS
480    
481                                 ; Check the command or reply header in X:(R3) for self-consistency
482       P:0000FF P:0000FF 46E300  CHK_HDR   MOVE              X:(R3),Y0
483       P:000100 P:000100 579600            MOVE              X:<MASK1,B              ; Test for S.LE.3 and D.LE.3 and N.LE.7
484       P:000101 P:000101 20005E            AND     Y0,B
485       P:000102 P:000102 0E208D            JNE     <ERROR                            ; Test failed
486       P:000103 P:000103 579700            MOVE              X:<MASK2,B              ; Test for either S.NE.0 or D.NE.0
487       P:000104 P:000104 20005E            AND     Y0,B
488       P:000105 P:000105 0EA08D            JEQ     <ERROR                            ; Test failed
489       P:000106 P:000106 579500            MOVE              X:<SEVEN,B
490       P:000107 P:000107 20005E            AND     Y0,B                              ; Extract NWORDS, must be > 0
491       P:000108 P:000108 0EA08D            JEQ     <ERROR
492       P:000109 P:000109 44E300            MOVE              X:(R3),X0
493       P:00010A P:00010A 440500            MOVE              X0,X:<HEADER            ; Its a correct header
494       P:00010B P:00010B 550600            MOVE              B1,X:<NWORDS            ; Number of words in the command
495       P:00010C P:00010C 0C005E            JMP     <PR_RCV
496    
497                                 ;  *****************  Boot Commands  *******************
498    
499                                 ; Test Data Link - simply return value received after 'TDL'
500       P:00010D P:00010D 47DB00  TDL       MOVE              X:(R3)+,Y1              ; Get the data value
501       P:00010E P:00010E 0C0090            JMP     <FINISH1                          ; Return from executing TDL command
502    
503                                 ; Read DSP or EEPROM memory ('RDM' address): read memory, reply with value
504       P:00010F P:00010F 47DB00  RDMEM     MOVE              X:(R3)+,Y1
505       P:000110 P:000110 20EF00            MOVE              Y1,B
506       P:000111 P:000111 0140CE            AND     #$0FFFFF,B                        ; Bits 23-20 need to be zeroed
                            0FFFFF
507       P:000113 P:000113 21B000            MOVE              B1,R0                   ; Need the address in an address register
508       P:000114 P:000114 20EF00            MOVE              Y1,B
509       P:000115 P:000115 000000            NOP
510       P:000116 P:000116 0ACF14            JCLR    #20,B,RDX                         ; Test address bit for Program memory
                            00011A
511       P:000118 P:000118 07E087            MOVE              P:(R0),Y1               ; Read from Program Memory
512       P:000119 P:000119 0C0090            JMP     <FINISH1                          ; Send out a header with the value
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timboot.asm  Page 10



513       P:00011A P:00011A 0ACF15  RDX       JCLR    #21,B,RDY                         ; Test address bit for X: memory
                            00011E
514       P:00011C P:00011C 47E000            MOVE              X:(R0),Y1               ; Write to X data memory
515       P:00011D P:00011D 0C0090            JMP     <FINISH1                          ; Send out a header with the value
516       P:00011E P:00011E 0ACF16  RDY       JCLR    #22,B,RDR                         ; Test address bit for Y: memory
                            000122
517       P:000120 P:000120 4FE000            MOVE                          Y:(R0),Y1   ; Read from Y data memory
518       P:000121 P:000121 0C0090            JMP     <FINISH1                          ; Send out a header with the value
519       P:000122 P:000122 0ACF17  RDR       JCLR    #23,B,ERROR                       ; Test address bit for read from EEPROM memo
ry
                            00008D
520       P:000124 P:000124 479400            MOVE              X:<THREE,Y1             ; Convert to word address to a byte address
521       P:000125 P:000125 220600            MOVE              R0,Y0                   ; Get 16-bit address in a data register
522       P:000126 P:000126 2000B8            MPY     Y0,Y1,B                           ; Multiply
523       P:000127 P:000127 20002A            ASR     B                                 ; Eliminate zero fill of fractional multiply
524       P:000128 P:000128 213000            MOVE              B0,R0                   ; Need to address memory
525       P:000129 P:000129 0AD06F            BSET    #15,R0                            ; Set bit so its in EEPROM space
526       P:00012A P:00012A 0D0178            JSR     <RD_WORD                          ; Read word from EEPROM
527       P:00012B P:00012B 21A700            MOVE              B1,Y1                   ; FINISH1 transmits Y1 as its reply
528       P:00012C P:00012C 0C0090            JMP     <FINISH1
529    
530                                 ; Program WRMEM ('WRM' address datum): write to memory, reply 'DON'.
531       P:00012D P:00012D 47DB00  WRMEM     MOVE              X:(R3)+,Y1              ; Get the address to be written to
532       P:00012E P:00012E 20EF00            MOVE              Y1,B
533       P:00012F P:00012F 0140CE            AND     #$0FFFFF,B                        ; Bits 23-20 need to be zeroed
                            0FFFFF
534       P:000131 P:000131 21B000            MOVE              B1,R0                   ; Need the address in an address register
535       P:000132 P:000132 20EF00            MOVE              Y1,B
536       P:000133 P:000133 46DB00            MOVE              X:(R3)+,Y0              ; Get datum into Y0 so MOVE works easily
537       P:000134 P:000134 0ACF14            JCLR    #20,B,WRX                         ; Test address bit for Program memory
                            000138
538       P:000136 P:000136 076086            MOVE              Y0,P:(R0)               ; Write to Program memory
539       P:000137 P:000137 0C008F            JMP     <FINISH
540       P:000138 P:000138 0ACF15  WRX       JCLR    #21,B,WRY                         ; Test address bit for X: memory
                            00013C
541       P:00013A P:00013A 466000            MOVE              Y0,X:(R0)               ; Write to X: memory
542       P:00013B P:00013B 0C008F            JMP     <FINISH
543       P:00013C P:00013C 0ACF16  WRY       JCLR    #22,B,WRR                         ; Test address bit for Y: memory
                            000140
544       P:00013E P:00013E 4E6000            MOVE                          Y0,Y:(R0)   ; Write to Y: memory
545       P:00013F P:00013F 0C008F            JMP     <FINISH
546       P:000140 P:000140 0ACF17  WRR       JCLR    #23,B,ERROR                       ; Test address bit for write to EEPROM
                            00008D
547       P:000142 P:000142 013D02            BCLR    #WRENA,X:PDRC                     ; WR_ENA* = 0 to enable EEPROM writing
548       P:000143 P:000143 460E00            MOVE              Y0,X:<SV_A1             ; Save the datum to be written
549       P:000144 P:000144 479400            MOVE              X:<THREE,Y1             ; Convert word address to a byte address
550       P:000145 P:000145 220600            MOVE              R0,Y0                   ; Get 16-bit address in a data register
551       P:000146 P:000146 2000B8            MPY     Y1,Y0,B                           ; Multiply
552       P:000147 P:000147 20002A            ASR     B                                 ; Eliminate zero fill of fractional multiply
553       P:000148 P:000148 213000            MOVE              B0,R0                   ; Need to address memory
554       P:000149 P:000149 0AD06F            BSET    #15,R0                            ; Set bit so its in EEPROM space
555       P:00014A P:00014A 558E00            MOVE              X:<SV_A1,B1             ; Get the datum to be written
556       P:00014B P:00014B 060380            DO      #3,L1WRR                          ; Loop over three bytes of the word
                            000154
557       P:00014D P:00014D 07588D            MOVE              B1,P:(R0)+              ; Write each EEPROM byte
558       P:00014E P:00014E 0C1C91            ASR     #8,B,B
559       P:00014F P:00014F 469E00            MOVE              X:<C100K,Y0             ; Move right one byte, enter delay = 1 msec
560       P:000150 P:000150 06C600            DO      Y0,L2WRR                          ; Delay by 12 milliseconds for EEPROM write
                            000153
561       P:000152 P:000152 060CA0            REP     #12                               ; Assume 100 MHz DSP56303
562       P:000153 P:000153 000000            NOP
563                                 L2WRR
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timboot.asm  Page 11



564       P:000154 P:000154 000000            NOP                                       ; DO loop nesting restriction
565                                 L1WRR
566       P:000155 P:000155 013D22            BSET    #WRENA,X:PDRC                     ; WR_ENA* = 1 to disable EEPROM writing
567       P:000156 P:000156 0C008F            JMP     <FINISH
568    
569                                 ; Load application code from P: memory into its proper locations
570       P:000157 P:000157 47DB00  LDAPPL    MOVE              X:(R3)+,Y1              ; Application number, not used yet
571       P:000158 P:000158 0D015A            JSR     <LOAD_APPLICATION
572       P:000159 P:000159 0C008F            JMP     <FINISH
573    
574                                 LOAD_APPLICATION
575       P:00015A P:00015A 60F400            MOVE              #$8000,R0               ; Starting EEPROM address
                            008000
576       P:00015C P:00015C 0D0178            JSR     <RD_WORD                          ; Number of words in boot code
577       P:00015D P:00015D 21A600            MOVE              B1,Y0
578       P:00015E P:00015E 479400            MOVE              X:<THREE,Y1
579       P:00015F P:00015F 2000B8            MPY     Y0,Y1,B
580       P:000160 P:000160 20002A            ASR     B
581       P:000161 P:000161 213000            MOVE              B0,R0                   ; EEPROM address of start of P: application
582       P:000162 P:000162 0AD06F            BSET    #15,R0                            ; To access EEPROM
583       P:000163 P:000163 0D0178            JSR     <RD_WORD                          ; Read number of words in application P:
584       P:000164 P:000164 61F400            MOVE              #(X_BOOT_START+1),R1    ; End of boot P: code that needs keeping
                            00022B
585       P:000166 P:000166 06CD00            DO      B1,RD_APPL_P
                            000169
586       P:000168 P:000168 0D0178            JSR     <RD_WORD
587       P:000169 P:000169 07598D            MOVE              B1,P:(R1)+
588                                 RD_APPL_P
589       P:00016A P:00016A 0D0178            JSR     <RD_WORD                          ; Read number of words in application X:
590       P:00016B P:00016B 61F400            MOVE              #END_COMMAND_TABLE,R1
                            000036
591       P:00016D P:00016D 06CD00            DO      B1,RD_APPL_X
                            000170
592       P:00016F P:00016F 0D0178            JSR     <RD_WORD
593       P:000170 P:000170 555900            MOVE              B1,X:(R1)+
594                                 RD_APPL_X
595       P:000171 P:000171 0D0178            JSR     <RD_WORD                          ; Read number of words in application Y:
596       P:000172 P:000172 310100            MOVE              #1,R1                   ; There is no Y: memory in the boot code
597       P:000173 P:000173 06CD00            DO      B1,RD_APPL_Y
                            000176
598       P:000175 P:000175 0D0178            JSR     <RD_WORD
599       P:000176 P:000176 5D5900            MOVE                          B1,Y:(R1)+
600                                 RD_APPL_Y
601       P:000177 P:000177 00000C            RTS
602    
603                                 ; Read one word from EEPROM location R0 into accumulator B1
604       P:000178 P:000178 060380  RD_WORD   DO      #3,L_RDBYTE
                            00017B
605       P:00017A P:00017A 07D88B            MOVE              P:(R0)+,B2
606       P:00017B P:00017B 0C1C91            ASR     #8,B,B
607                                 L_RDBYTE
608       P:00017C P:00017C 00000C            RTS
609    
610                                 ; Come to here on a 'STP' command so 'DON' can be sent
611                                 STOP_IDLE_CLOCKING
612       P:00017D P:00017D 305A00            MOVE              #<TST_RCV,R0            ; Execution address when idle => when not
613       P:00017E P:00017E 601F00            MOVE              R0,X:<IDL_ADR           ;   processing commands or reading out
614       P:00017F P:00017F 0A0002            BCLR    #IDLMODE,X:<STATUS                ; Don't idle after readout
615       P:000180 P:000180 0C008F            JMP     <FINISH
616    
617                                 ; Routines executed after the DSP boots and initializes
618       P:000181 P:000181 305A00  STARTUP   MOVE              #<TST_RCV,R0            ; Execution address when idle => when not
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timboot.asm  Page 12



619       P:000182 P:000182 601F00            MOVE              R0,X:<IDL_ADR           ;   processing commands or reading out
620       P:000183 P:000183 44F400            MOVE              #50000,X0               ; Delay by 500 milliseconds
                            00C350
621       P:000185 P:000185 06C400            DO      X0,L_DELAY
                            000188
622       P:000187 P:000187 06E8A3            REP     #1000
623       P:000188 P:000188 000000            NOP
624                                 L_DELAY
625       P:000189 P:000189 57F400            MOVE              #$020002,B              ; Normal reply after booting is 'SYR'
                            020002
626       P:00018B P:00018B 0D00EB            JSR     <XMT_WRD
627       P:00018C P:00018C 57F400            MOVE              #'SYR',B
                            535952
628       P:00018E P:00018E 0D00EB            JSR     <XMT_WRD
629    
630       P:00018F P:00018F 0C0054            JMP     <START                            ; Start normal command processing
631    
632                                 ; *******************  DSP  INITIALIZATION  CODE  **********************
633                                 ; This code initializes the DSP right after booting, and is overwritten
634                                 ;   by application code
635       P:000190 P:000190 08F4BD  INIT      MOVEP             #PLL_INIT,X:PCTL        ; Initialize PLL to 100 MHz
                            050003
636       P:000192 P:000192 000000            NOP
637    
638                                 ; Set operation mode register OMR to normal expanded
639       P:000193 P:000193 0500BA            MOVEC             #$0000,OMR              ; Operating Mode Register = Normal Expanded
640       P:000194 P:000194 0500BB            MOVEC             #0,SP                   ; Reset the Stack Pointer SP
641    
642                                 ; Program the AA = address attribute pins
643       P:000195 P:000195 08F4B9            MOVEP             #$FFFC21,X:AAR0         ; Y = $FFF000 to $FFFFFF asserts commands
                            FFFC21
644       P:000197 P:000197 08F4B8            MOVEP             #$008909,X:AAR1         ; P = $008000 to $00FFFF accesses the EEPROM
                            008909
645       P:000199 P:000199 08F4B7            MOVEP             #$010C11,X:AAR2         ; X = $010000 to $010FFF reads A/D values
                            010C11
646       P:00019B P:00019B 08F4B6            MOVEP             #$080621,X:AAR3         ; Y = $080000 to $0BFFFF R/W from SRAM
                            080621
647    
648       P:00019D P:00019D 0A0F00            BCLR    #CDAC,X:<LATCH                    ; Enable clearing of DACs
649       P:00019E P:00019E 0A0F02            BCLR    #ENCK,X:<LATCH                    ; Disable clock and DAC output switches
650       P:00019F P:00019F 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Execute these two operations
                            00000F
651    
652                                 ; Program the DRAM memory access and addressing
653       P:0001A1 P:0001A1 08F4BB            MOVEP             #$028FE1,X:BCR          ; Bus Control Register
                            028FE1
654    
655                                 ; Program the Host port B for parallel I/O
656       P:0001A3 P:0001A3 08F484            MOVEP             #>1,X:HPCR              ; All pins enabled as GPIO
                            000001
657       P:0001A5 P:0001A5 08F489            MOVEP             #$810C,X:HDR
                            00810C
658       P:0001A7 P:0001A7 08F488            MOVEP             #$B10E,X:HDDR           ; Data Direction Register
                            00B10E
659                                                                                     ;  (1 for Output, 0 for Input)
660    
661                                 ; Port B conversion from software bits to schematic labels
662                                 ;       PB0 = PWROK             PB08 = PRSFIFO*
663                                 ;       PB1 = LED1              PB09 = EF*
664                                 ;       PB2 = LVEN              PB10 = EXT-IN0
665                                 ;       PB3 = HVEN              PB11 = EXT-IN1
666                                 ;       PB4 = STATUS0           PB12 = EXT-OUT0
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timboot.asm  Page 13



667                                 ;       PB5 = STATUS1           PB13 = EXT-OUT1
668                                 ;       PB6 = STATUS2           PB14 = SSFHF*
669                                 ;       PB7 = STATUS3           PB15 = SELSCI
670    
671                                 ; Program the serial port ESSI0 = Port C for serial communication with
672                                 ;   the utility board
673       P:0001A9 P:0001A9 07F43F            MOVEP             #>0,X:PCRC              ; Software reset of ESSI0
                            000000
674       P:0001AB P:0001AB 07F435            MOVEP             #$180809,X:CRA0         ; Divide 100 MHz by 20 to get 5.0 MHz
                            180809
675                                                                                     ; DC[4:0] = 0 for non-network operation
676                                                                                     ; WL0-WL2 = 3 for 24-bit data words
677                                                                                     ; SSC1 = 0 for SC1 not used
678       P:0001AD P:0001AD 07F436            MOVEP             #$020020,X:CRB0         ; SCKD = 1 for internally generated clock
                            020020
679                                                                                     ; SCD2 = 0 so frame sync SC2 is an output
680                                                                                     ; SHFD = 0 for MSB shifted first
681                                                                                     ; FSL = 0, frame sync length not used
682                                                                                     ; CKP = 0 for rising clock edge transitions
683                                                                                     ; SYN = 0 for asynchronous
684                                                                                     ; TE0 = 1 to enable transmitter #0
685                                                                                     ; MOD = 0 for normal, non-networked mode
686                                                                                     ; TE0 = 0 to NOT enable transmitter #0 yet
687                                                                                     ; RE = 1 to enable receiver
688       P:0001AF P:0001AF 07F43F            MOVEP             #%111001,X:PCRC         ; Control Register (0 for GPIO, 1 for ESSI)
                            000039
689       P:0001B1 P:0001B1 07F43E            MOVEP             #%000110,X:PRRC         ; Data Direction Register (0 for In, 1 for O
ut)
                            000006
690       P:0001B3 P:0001B3 07F43D            MOVEP             #%000100,X:PDRC         ; Data Register - WR_ENA* = 1
                            000004
691    
692                                 ; Port C version = Analog boards
693                                 ;       MOVEP   #$000809,X:CRA0 ; Divide 100 MHz by 20 to get 5.0 MHz
694                                 ;       MOVEP   #$000030,X:CRB0 ; SCKD = 1 for internally generated clock
695                                 ;       MOVEP   #%100000,X:PCRC ; Control Register (0 for GPIO, 1 for ESSI)
696                                 ;       MOVEP   #%000100,X:PRRC ; Data Direction Register (0 for In, 1 for Out)
697                                 ;       MOVEP   #%000000,X:PDRC ; Data Register: 'not used' = 0 outputs
698    
699       P:0001B5 P:0001B5 07F43C            MOVEP             #0,X:TX00               ; Initialize the transmitter to zero
                            000000
700       P:0001B7 P:0001B7 000000            NOP
701       P:0001B8 P:0001B8 000000            NOP
702       P:0001B9 P:0001B9 013630            BSET    #TE,X:CRB0                        ; Enable the SSI transmitter
703    
704                                 ; Conversion from software bits to schematic labels for Port C
705                                 ;       PC0 = SC00 = UTL-T-SCK
706                                 ;       PC1 = SC01 = 2_XMT = SYNC on prototype
707                                 ;       PC2 = SC02 = WR_ENA*
708                                 ;       PC3 = SCK0 = TIM-U-SCK
709                                 ;       PC4 = SRD0 = UTL-T-STD
710                                 ;       PC5 = STD0 = TIM-U-STD
711    
712                                 ; Program the serial port ESSI1 = Port D for serial transmission to
713                                 ;   the analog boards and two parallel I/O input pins
714       P:0001BA P:0001BA 07F42F            MOVEP             #>0,X:PCRD              ; Software reset of ESSI0
                            000000
715       P:0001BC P:0001BC 07F425            MOVEP             #$000809,X:CRA1         ; Divide 100 MHz by 20 to get 5.0 MHz
                            000809
716                                                                                     ; DC[4:0] = 0
717                                                                                     ; WL[2:0] = ALC = 0 for 8-bit data words
718                                                                                     ; SSC1 = 0 for SC1 not used
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timboot.asm  Page 14



719       P:0001BE P:0001BE 07F426            MOVEP             #$000030,X:CRB1         ; SCKD = 1 for internally generated clock
                            000030
720                                                                                     ; SCD2 = 1 so frame sync SC2 is an output
721                                                                                     ; SHFD = 0 for MSB shifted first
722                                                                                     ; CKP = 0 for rising clock edge transitions
723                                                                                     ; TE0 = 0 to NOT enable transmitter #0 yet
724                                                                                     ; MOD = 0 so its not networked mode
725       P:0001C0 P:0001C0 07F42F            MOVEP             #%100000,X:PCRD         ; Control Register (0 for GPIO, 1 for ESSI)
                            000020
726                                                                                     ; PD3 = SCK1, PD5 = STD1 for ESSI
727       P:0001C2 P:0001C2 07F42E            MOVEP             #%000100,X:PRRD         ; Data Direction Register (0 for In, 1 for O
ut)
                            000004
728       P:0001C4 P:0001C4 07F42D            MOVEP             #%000100,X:PDRD         ; Data Register: 'not used' = 0 outputs
                            000004
729       P:0001C6 P:0001C6 07F42C            MOVEP             #0,X:TX10               ; Initialize the transmitter to zero
                            000000
730       P:0001C8 P:0001C8 000000            NOP
731       P:0001C9 P:0001C9 000000            NOP
732       P:0001CA P:0001CA 012630            BSET    #TE,X:CRB1                        ; Enable the SSI transmitter
733    
734                                 ; Conversion from software bits to schematic labels for Port D
735                                 ; PD0 = SC10 = 2_XMT_? input
736                                 ; PD1 = SC11 = SSFEF* input
737                                 ; PD2 = SC12 = PWR_EN
738                                 ; PD3 = SCK1 = TIM-A-SCK
739                                 ; PD4 = SRD1 = PWRRST
740                                 ; PD5 = STD1 = TIM-A-STD
741    
742                                 ; Program the SCI port to communicate with the utility board
743       P:0001CB P:0001CB 07F41C            MOVEP             #$0B04,X:SCR            ; SCI programming: 11-bit asynchronous
                            000B04
744                                                                                     ;   protocol (1 start, 8 data, 1 even parity
,
745                                                                                     ;   1 stop); LSB before MSB; enable receiver
746                                                                                     ;   and its interrupts; transmitter interrup
ts
747                                                                                     ;   disabled.
748       P:0001CD P:0001CD 07F41B            MOVEP             #$0003,X:SCCR           ; SCI clock: utility board data rate =
                            000003
749                                                                                     ;   (390,625 kbits/sec); internal clock.
750       P:0001CF P:0001CF 07F41F            MOVEP             #%011,X:PCRE            ; Port Control Register = RXD, TXD enabled
                            000003
751       P:0001D1 P:0001D1 07F41E            MOVEP             #%000,X:PRRE            ; Port Direction Register (0 = Input)
                            000000
752    
753                                 ;       PE0 = RXD
754                                 ;       PE1 = TXD
755                                 ;       PE2 = SCLK
756    
757                                 ; Program one of the three timers as an exposure timer
758       P:0001D3 P:0001D3 07F403            MOVEP             #$C34F,X:TPLR           ; Prescaler to generate millisecond timer,
                            00C34F
759                                                                                     ;  counting from the system clock / 2 = 50 M
Hz
760       P:0001D5 P:0001D5 07F40F            MOVEP             #$208200,X:TCSR0        ; Clear timer complete bit and enable presca
ler
                            208200
761       P:0001D7 P:0001D7 07F40E            MOVEP             #0,X:TLR0               ; Timer load register
                            000000
762    
763                                 ; Enable interrupts for the SCI port only
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timboot.asm  Page 15



764       P:0001D9 P:0001D9 08F4BF            MOVEP             #$000000,X:IPRC         ; No interrupts allowed
                            000000
765       P:0001DB P:0001DB 08F4BE            MOVEP             #>$80,X:IPRP            ; Enable SCI interrupt only, IPR = 1
                            000080
766       P:0001DD P:0001DD 00FCB8            ANDI    #$FC,MR                           ; Unmask all interrupt levels
767    
768                                 ; Initialize the fiber optic serial receiver circuitry
769       P:0001DE P:0001DE 061480            DO      #20,L_FO_INIT
                            0001E3
770       P:0001E0 P:0001E0 5FF000            MOVE                          Y:RDFO,B
                            FFFFF1
771       P:0001E2 P:0001E2 0605A0            REP     #5
772       P:0001E3 P:0001E3 000000            NOP
773                                 L_FO_INIT
774    
775                                 ; Pulse PRSFIFO* low to revive the CMDRST* instruction and reset the FIFO
776       P:0001E4 P:0001E4 44F400            MOVE              #1000000,X0             ; Delay by 10 milliseconds
                            0F4240
777       P:0001E6 P:0001E6 06C400            DO      X0,*+3
                            0001E8
778       P:0001E8 P:0001E8 000000            NOP
779       P:0001E9 P:0001E9 0A8908            BCLR    #8,X:HDR
780       P:0001EA P:0001EA 0614A0            REP     #20
781       P:0001EB P:0001EB 000000            NOP
782       P:0001EC P:0001EC 0A8928            BSET    #8,X:HDR
783    
784                                 ; Reset the utility board
785       P:0001ED P:0001ED 0A0F05            BCLR    #5,X:<LATCH
786       P:0001EE P:0001EE 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Clear reset utility board bit
                            00000F
787       P:0001F0 P:0001F0 06C8A0            REP     #200                              ; Delay by RESET* low time
788       P:0001F1 P:0001F1 000000            NOP
789       P:0001F2 P:0001F2 0A0F25            BSET    #5,X:<LATCH
790       P:0001F3 P:0001F3 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Clear reset utility board bit
                            00000F
791       P:0001F5 P:0001F5 56F400            MOVE              #200000,A               ; Delay 2 msec for utility boot
                            030D40
792       P:0001F7 P:0001F7 06CE00            DO      A,*+3
                            0001F9
793       P:0001F9 P:0001F9 000000            NOP
794    
795                                 ; Put all the analog switch inputs to low so they draw minimum current
796       P:0001FA P:0001FA 012F23            BSET    #3,X:PCRD                         ; Turn the serial clock on
797       P:0001FB P:0001FB 56F400            MOVE              #$0C3000,A              ; Value of integrate speed and gain switches
                            0C3000
798       P:0001FD P:0001FD 20001B            CLR     B
799       P:0001FE P:0001FE 241000            MOVE              #$100000,X0             ; Increment over board numbers for DAC write
s
800       P:0001FF P:0001FF 45F400            MOVE              #$001000,X1             ; Increment over board numbers for WRSS writ
es
                            001000
801       P:000201 P:000201 060F80            DO      #15,L_ANALOG                      ; Fifteen video processor boards maximum
                            000209
802       P:000203 P:000203 0D020C            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
803       P:000204 P:000204 200040            ADD     X0,A
804       P:000205 P:000205 5F7000            MOVE                          B,Y:WRSS    ; This is for the fast analog switches
                            FFFFF3
805       P:000207 P:000207 0620A3            REP     #800                              ; Delay for the serial data transmission
806       P:000208 P:000208 000000            NOP
807       P:000209 P:000209 200068            ADD     X1,B                              ; Increment the video and clock driver numbe
rs
808                                 L_ANALOG
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timboot.asm  Page 16



809       P:00020A P:00020A 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
810       P:00020B P:00020B 0C0223            JMP     <SKIP
811    
812                                 ; Transmit contents of accumulator A1 over the synchronous serial transmitter
813                                 XMIT_A_WORD
814       P:00020C P:00020C 07F42C            MOVEP             #0,X:TX10               ; This helps, don't know why
                            000000
815       P:00020E P:00020E 547000            MOVE              A1,X:SV_A1
                            00000E
816       P:000210 P:000210 000000            NOP
817       P:000211 P:000211 01A786            JCLR    #TDE,X:SSISR1,*                   ; Start bit
                            000211
818       P:000213 P:000213 07F42C            MOVEP             #$010000,X:TX10
                            010000
819       P:000215 P:000215 060380            DO      #3,L_X
                            00021B
820       P:000217 P:000217 01A786            JCLR    #TDE,X:SSISR1,*                   ; Three data bytes
                            000217
821       P:000219 P:000219 04CCCC            MOVEP             A1,X:TX10
822       P:00021A P:00021A 0C1E90            LSL     #8,A
823       P:00021B P:00021B 000000            NOP
824                                 L_X
825       P:00021C P:00021C 01A786            JCLR    #TDE,X:SSISR1,*                   ; Zeroes to bring transmitter low
                            00021C
826       P:00021E P:00021E 07F42C            MOVEP             #0,X:TX10
                            000000
827       P:000220 P:000220 54F000            MOVE              X:SV_A1,A1
                            00000E
828       P:000222 P:000222 00000C            RTS
829    
830                                 SKIP
831    
832                                 ; Set up the circular SCI buffer, 32 words in size
833       P:000223 P:000223 64F400            MOVE              #SCI_TABLE,R4
                            000400
834       P:000225 P:000225 051FA4            MOVE              #31,M4
835       P:000226 P:000226 647000            MOVE              R4,X:(SCI_TABLE+33)
                            000421
836    
837                                           IF      @SCP("HOST","ROM")
845                                           ENDIF
846    
847       P:000228 P:000228 44F400            MOVE              #>$AC,X0
                            0000AC
848       P:00022A P:00022A 440100            MOVE              X0,X:<FO_HDR
849    
850       P:00022B P:00022B 0C0181            JMP     <STARTUP
851    
852                                 ;  ****************  X: Memory tables  ********************
853    
854                                 ; Define the address in P: space where the table of constants begins
855    
856                                  X_BOOT_START
857       00022A                              EQU     @LCV(L)-2
858    
859                                           IF      @SCP("HOST","ROM")
861                                           ENDIF
862                                           IF      @SCP("HOST","HOST")
863       X:000000 X:000000                   ORG     X:0,X:0
864                                           ENDIF
865    
866                                 ; Special storage area - initialization constants and scratch space
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timboot.asm  Page 17



867       X:000000 X:000000         STATUS    DC      4                                 ; Controller status bits
868    
869       000001                    FO_HDR    EQU     STATUS+1                          ; Fiber optic write bytes
870       000005                    HEADER    EQU     FO_HDR+4                          ; Command header
871       000006                    NWORDS    EQU     HEADER+1                          ; Number of words in the command
872       000007                    COM_BUF   EQU     NWORDS+1                          ; Command buffer
873       00000E                    SV_A1     EQU     COM_BUF+7                         ; Save accumulator A1
874    
875                                           IF      @SCP("HOST","ROM")
880                                           ENDIF
881    
882                                           IF      @SCP("HOST","HOST")
883       X:00000F X:00000F                   ORG     X:$F,X:$F
884                                           ENDIF
885    
886                                 ; Parameter table in P: space to be copied into X: space during
887                                 ;   initialization, and is copied from ROM by the DSP boot
888       X:00000F X:00000F         LATCH     DC      $3A                               ; Starting value in latch chip U25
889                                  EXPOSURE_TIME
890       X:000010 X:000010                   DC      0                                 ; Exposure time in milliseconds
891                                  ELAPSED_TIME
892       X:000011 X:000011                   DC      0                                 ; Time elapsed so far in the exposure
893       X:000012 X:000012         ONE       DC      1                                 ; One
894       X:000013 X:000013         TWO       DC      2                                 ; Two
895       X:000014 X:000014         THREE     DC      3                                 ; Three
896       X:000015 X:000015         SEVEN     DC      7                                 ; Seven
897       X:000016 X:000016         MASK1     DC      $FCFCF8                           ; Mask for checking header
898       X:000017 X:000017         MASK2     DC      $030300                           ; Mask for checking header
899       X:000018 X:000018         DONE      DC      'DON'                             ; Standard reply
900       X:000019 X:000019         SBRD      DC      $020000                           ; Source Identification number
901       X:00001A X:00001A         TIM_DRB   DC      $000200                           ; Destination = timing board number
902       X:00001B X:00001B         DMASK     DC      $00FF00                           ; Mask to get destination board number
903       X:00001C X:00001C         SMASK     DC      $FF0000                           ; Mask to get source board number
904       X:00001D X:00001D         ERR       DC      'ERR'                             ; An error occurred
905       X:00001E X:00001E         C100K     DC      100000                            ; Delay for WRROM = 1 millisec
906       X:00001F X:00001F         IDL_ADR   DC      TST_RCV                           ; Address of idling routine
907       X:000020 X:000020         EXP_ADR   DC      0                                 ; Jump to this address during exposures
908    
909                                 ; Places for saving register values
910       X:000021 X:000021         SAVE_SR   DC      0                                 ; Status Register
911       X:000022 X:000022         SAVE_X1   DC      0
912       X:000023 X:000023         SAVE_A1   DC      0
913       X:000024 X:000024         SAVE_R0   DC      0
914       X:000025 X:000025         RCV_ERR   DC      0
915       X:000026 X:000026         SCI_A1    DC      0                                 ; Contents of accumulator A1 in RCV ISR
916       X:000027 X:000027         SCI_R0    DC      SRXL
917    
918                                 ; Command table
919       000028                    COM_TBL_R EQU     @LCV(R)
920       X:000028 X:000028         COM_TBL   DC      'TDL',TDL                         ; Test Data Link
921       X:00002A X:00002A                   DC      'RDM',RDMEM                       ; Read from DSP or EEPROM memory
922       X:00002C X:00002C                   DC      'WRM',WRMEM                       ; Write to DSP memory
923       X:00002E X:00002E                   DC      'LDA',LDAPPL                      ; Load application from EEPROM to DSP
924       X:000030 X:000030                   DC      'STP',STOP_IDLE_CLOCKING
925       X:000032 X:000032                   DC      'DON',START                       ; Nothing special
926       X:000034 X:000034                   DC      'ERR',START                       ; Nothing special
927    
928                                  END_COMMAND_TABLE
929       000036                              EQU     @LCV(R)
930    
931                                 ; The table at SCI_TABLE is for words received from the utility board, written by
932                                 ;   the interrupt service routine SCI_RCV. Note that it is 32 words long,
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timboot.asm  Page 18



933                                 ;   hard coded, and the 33rd location contains the pointer to words that have
934                                 ;   been processed by moving them from the SCI_TABLE to the COM_BUF.
935    
936                                           IF      @SCP("HOST","ROM")
938                                           ENDIF
939    
940       000036                    END_ADR   EQU     @LCV(L)                           ; End address of P: code written to ROM
941    
942       P:00022C P:00022C                   ORG     P:,P:
943    
944       108015                    CC        EQU     ARC22+ARC32+ARC46+CONT_RD
945    
946                                 ; Put number of words of application in P: for loading application from EEPROM
947       P:00022C P:00022C                   DC      TIMBOOT_X_MEMORY-@LCV(L)-1
948    
949                                 ; Define CLOCK as a macro to produce in-line code to reduce execution time
950                                 CLOCK     MACRO
951  m                                        JCLR    #SSFHF,X:HDR,*                    ; Don't overfill the WRSS FIFO
952  m                                        REP     Y:(R0)+                           ; Repeat
953  m                                        MOVEP   Y:(R0)+,Y:WRSS                    ; Write the waveform to the FIFO
954  m                                        ENDM
955    
956                                 ; Continuously reset and read array, checking for commands every four rows
957                                 CONT_RST
958       P:00022D P:00022D 60F400            MOVE              #FRAME_RESET,R0
                            000183
959                                           CLOCK
963       P:000233 P:000233 60F400            MOVE              #FRAME_RESET,R0
                            000183
964                                           CLOCK
968       P:000239 P:000239 60F400            MOVE              #FRAME_RESET,R0
                            000183
969                                           CLOCK
973       P:00023F P:00023F 60F400            MOVE              #FRAME_RESET,R0
                            000183
974                                           CLOCK
978       P:000245 P:000245 068080            DO      #128,L_RESET
                            00026C
979       P:000247 P:000247 60F400            MOVE              #CLOCK_ROW_1,R0
                            00019F
980                                           CLOCK
984       P:00024D P:00024D 0D026E            JSR     <CLK_COL
985       P:00024E P:00024E 60F400            MOVE              #CLOCK_ROW_2,R0
                            0001A5
986                                           CLOCK
990       P:000254 P:000254 0D026E            JSR     <CLK_COL
991       P:000255 P:000255 60F400            MOVE              #CLOCK_ROW_3,R0
                            0001AB
992                                           CLOCK
996       P:00025B P:00025B 0D026E            JSR     <CLK_COL
997       P:00025C P:00025C 60F400            MOVE              #CLOCK_ROW_4,R0
                            0001B1
998                                           CLOCK
1002      P:000262 P:000262 0D026E            JSR     <CLK_COL
1003      P:000263 P:000263 44F400            MOVE              #(CLK2+SSYNC+S1+S2+SOE+RDES+VRSTOFF+VRSTR),X0
                            00207F
1004      P:000265 P:000265 4C7000            MOVE                          X0,Y:WRSS
                            FFFFF3
1005   
1006      P:000267 P:000267 330700            MOVE              #COM_BUF,R3
1007      P:000268 P:000268 0D00A5            JSR     <GET_RCV                          ; Look for a new command every 4 rows
1008      P:000269 P:000269 0E026C            JCC     <NO_COM                           ; If none, then stay here
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  tim.asm  Page 19



1009      P:00026A P:00026A 00008C            ENDDO
1010      P:00026B P:00026B 0C005D            JMP     <PRC_RCV
1011      P:00026C P:00026C 000000  NO_COM    NOP
1012                                L_RESET
1013      P:00026D P:00026D 0C022D            JMP     <CONT_RST
1014   
1015                                ; Simple clocking routine for resetting and clearing
1016      P:00026E P:00026E 062080  CLK_COL   DO      #32,L_CLOCK
                            000275
1017      P:000270 P:000270 60F400            MOVE              #CLOCK_COLUMN,R0
                            0001B7
1018                                          CLOCK
1022                                L_CLOCK
1023      P:000276 P:000276 00000C            RTS
1024   
1025                                ;  ************************  Readout subroutines  ********************
1026                                ; Normal readout of the whole array
1027   
1028                                NORMAL_READOUT
1029                                ;       ;MOVE   #FRAME_RESET,R0
1030                                ;       ;CLOCK
1031                                ;       JCLR    #ST_CDS,X:STATUS,*+3
1032                                ;       JSR     <READOUT                ; Read the array
1033                                ;       JSR     <WAIT_TO_FINISH_CLOCKING
1034                                ;       MOVE    #L_EXP1,R7              ; Return address at end of exposure
1035                                ;       JMP     <EXPOSE                 ; Delay for specified exposure time
1036                                ;L_EXP1
1037                                ;       JSR     <READOUT
1038                                ;       JMP     <DONE_READOUT
1039   
1040   
1041                                RESET_ARRAY
1042      P:000277 P:000277 60F400            MOVE              #FRAME_RESET,R0
                            000183
1043      P:000279 P:000279 0D0518            JSR     <CLOCK
1044      P:00027A P:00027A 60F400            MOVE              #FRAME_RESET,R0
                            000183
1045      P:00027C P:00027C 0D0518            JSR     <CLOCK
1046      P:00027D P:00027D 60F400            MOVE              #FRAME_RESET,R0
                            000183
1047      P:00027F P:00027F 0D0518            JSR     <CLOCK
1048      P:000280 P:000280 60F400            MOVE              #FRAME_RESET,R0
                            000183
1049      P:000282 P:000282 0D0518            JSR     <CLOCK
1050      P:000283 P:000283 00000C            RTS
1051   
1052                                ; Now start reading out the image with the frame initialization clocks first
1053                                READOUT
1054      P:000284 P:000284 0D0509            JSR     <PCI_READ_IMAGE
1055      P:000285 P:000285 60F400            MOVE              #FRAME_INIT,R0
                            000198
1056                                          CLOCK
1060      P:00028B P:00028B 068080            DO      #128,L_READOUT
                            0002AA
1061      P:00028D P:00028D 60F400            MOVE              #CLOCK_ROW_1,R0
                            00019F
1062                                          CLOCK
1066      P:000293 P:000293 0D0397            JSR     <CLK_COL_AND_READ
1067      P:000294 P:000294 60F400            MOVE              #CLOCK_ROW_2,R0
                            0001A5
1068                                          CLOCK
1072      P:00029A P:00029A 0D0397            JSR     <CLK_COL_AND_READ
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  tim.asm  Page 20



1073      P:00029B P:00029B 60F400            MOVE              #CLOCK_ROW_3,R0
                            0001AB
1074                                          CLOCK
1078      P:0002A1 P:0002A1 0D0397            JSR     <CLK_COL_AND_READ
1079      P:0002A2 P:0002A2 60F400            MOVE              #CLOCK_ROW_4,R0
                            0001B1
1080                                          CLOCK
1084      P:0002A8 P:0002A8 0D0397            JSR     <CLK_COL_AND_READ
1085      P:0002A9 P:0002A9 0D0515            JSR     <WAIT_TO_FINISH_CLOCKING
1086      P:0002AA P:0002AA 000000            NOP
1087                                L_READOUT
1088   
1089      P:0002AB P:0002AB 60F400            MOVE              #CLOCK_ROW_1,R0
                            00019F
1090                                          CLOCK
1094      P:0002B1 P:0002B1 0D0397            JSR     <CLK_COL_AND_READ
1095   
1096      P:0002B2 P:0002B2 60F400            MOVE              #FRAME_INIT,R0          ;deselect last row by initializing
                            000198
1097                                          CLOCK
1101   
1102      P:0002B8 P:0002B8 0D0515            JSR     <WAIT_TO_FINISH_CLOCKING
1103      P:0002B9 P:0002B9 000000            NOP
1104   
1105      P:0002BA P:0002BA 00000C            RTS
1106   
1107   
1108                                NO_READOUT
1109                                ;       JSR     <PCI_READ_IMAGE
1110      P:0002BB P:0002BB 60F400            MOVE              #FRAME_INIT,R0
                            000198
1111                                          CLOCK
1115      P:0002C1 P:0002C1 068080            DO      #128,L_NO_READOUT
                            0002E0
1116      P:0002C3 P:0002C3 60F400            MOVE              #CLOCK_ROW_1,R0
                            00019F
1117                                          CLOCK
1121      P:0002C9 P:0002C9 0D03BD            JSR     <CLK_COL_NO_READ
1122      P:0002CA P:0002CA 60F400            MOVE              #CLOCK_ROW_2,R0
                            0001A5
1123                                          CLOCK
1127      P:0002D0 P:0002D0 0D03BD            JSR     <CLK_COL_NO_READ
1128      P:0002D1 P:0002D1 60F400            MOVE              #CLOCK_ROW_3,R0
                            0001AB
1129                                          CLOCK
1133      P:0002D7 P:0002D7 0D03BD            JSR     <CLK_COL_NO_READ
1134      P:0002D8 P:0002D8 60F400            MOVE              #CLOCK_ROW_4,R0
                            0001B1
1135                                          CLOCK
1139      P:0002DE P:0002DE 0D03BD            JSR     <CLK_COL_NO_READ
1140      P:0002DF P:0002DF 0D0515            JSR     <WAIT_TO_FINISH_CLOCKING
1141      P:0002E0 P:0002E0 000000            NOP
1142                                L_NO_READOUT
1143   
1144      P:0002E1 P:0002E1 60F400            MOVE              #CLOCK_ROW_1,R0
                            00019F
1145                                          CLOCK
1149      P:0002E7 P:0002E7 0D03BD            JSR     <CLK_COL_NO_READ
1150   
1151      P:0002E8 P:0002E8 60F400            MOVE              #FRAME_INIT,R0          ;deselect last row by initializing
                            000198
1152                                          CLOCK
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  tim.asm  Page 21



1156   
1157      P:0002EE P:0002EE 0D0515            JSR     <WAIT_TO_FINISH_CLOCKING
1158      P:0002EF P:0002EF 000000            NOP
1159   
1160      P:0002F0 P:0002F0 00000C            RTS
1161   
1162   
1163                                ; Row-by-row reset and readout, for high illumination levels
1164                                ROW_BY_ROW_RESET_READOUT
1165      P:0002F1 P:0002F1 0D0515            JSR     <WAIT_TO_FINISH_CLOCKING
1166      P:0002F2 P:0002F2 0A0024            BSET    #ST_RDC,X:<STATUS                 ; Set status to reading out
1167      P:0002F3 P:0002F3 57F400            MOVE              #$020104,B              ; Send header word to the FO transmitter
                            020104
1168      P:0002F5 P:0002F5 0D00EB            JSR     <XMT_WRD
1169      P:0002F6 P:0002F6 57F400            MOVE              #'RDA',B
                            524441
1170      P:0002F8 P:0002F8 0D00EB            JSR     <XMT_WRD
1171      P:0002F9 P:0002F9 57F400            MOVE              #1024,B                 ; Number of columns to read
                            000400
1172      P:0002FB P:0002FB 0D00EB            JSR     <XMT_WRD
1173      P:0002FC P:0002FC 0A00B1            JSET    #ST_CDS,X:STATUS,RRR_CDS
                            00033B
1174   
1175                                ; Read out the image in single read mode, row-by-row reset
1176      P:0002FE P:0002FE 57F400            MOVE              #1024,B                 ; Number of rows to read
                            000400
1177      P:000300 P:000300 0D00EB            JSR     <XMT_WRD
1178      P:000301 P:000301 60F400            MOVE              #FRAME_INIT,R0
                            000198
1179                                          CLOCK
1183      P:000307 P:000307 068080            DO      #128,L_RR_RESET_READOUT
                            000339
1184      P:000309 P:000309 60F400            MOVE              #RESET_ROW_12,R0
                            000175
1185                                          CLOCK
1189      P:00030F P:00030F 0D0515            JSR     <WAIT_TO_FINISH_CLOCKING
1190      P:000310 P:000310 67F400            MOVE              #L_RR12,R7
                            000313
1191      P:000312 P:000312 0C044C            JMP     <EXPOSE
1192                                L_RR12
1193      P:000313 P:000313 60F400            MOVE              #CLOCK_RR_ROW_1,R0
                            000115
1194                                          CLOCK
1198      P:000319 P:000319 0D0397            JSR     <CLK_COL_AND_READ
1199      P:00031A P:00031A 60F400            MOVE              #CLOCK_RR_ROW_2,R0
                            00011B
1200                                          CLOCK
1204      P:000320 P:000320 0D0397            JSR     <CLK_COL_AND_READ
1205   
1206      P:000321 P:000321 60F400            MOVE              #RESET_ROW_34,R0
                            00017C
1207                                          CLOCK
1211      P:000327 P:000327 0D0515            JSR     <WAIT_TO_FINISH_CLOCKING
1212      P:000328 P:000328 67F400            MOVE              #L_RR34,R7
                            00032B
1213      P:00032A P:00032A 0C044C            JMP     <EXPOSE
1214                                L_RR34
1215      P:00032B P:00032B 60F400            MOVE              #CLOCK_RR_ROW_3,R0
                            000121
1216                                          CLOCK
1220      P:000331 P:000331 0D0397            JSR     <CLK_COL_AND_READ
1221      P:000332 P:000332 60F400            MOVE              #CLOCK_RR_ROW_4,R0
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  tim.asm  Page 22



                            000127
1222                                          CLOCK
1226      P:000338 P:000338 0D0397            JSR     <CLK_COL_AND_READ
1227      P:000339 P:000339 000000            NOP
1228                                L_RR_RESET_READOUT
1229   
1230      P:00033A P:00033A 0C0387            JMP     <DONE_READOUT
1231   
1232                                ; Read out the image in CDS mode, row-by-row reset
1233      P:00033B P:00033B 57F400  RRR_CDS   MOVE              #1024,B
                            000400
1234      P:00033D P:00033D 0D00EB            JSR     <XMT_WRD                          ; Number of rows to read
1235      P:00033E P:00033E 60F400            MOVE              #FRAME_INIT,R0
                            000198
1236                                          CLOCK
1240      P:000344 P:000344 068080            DO      #128,CDS_RR_RESET_READOUT
                            000386
1241      P:000346 P:000346 60F400            MOVE              #CLOCK_CDS_RESET_ROW_1,R0
                            000151
1242                                          CLOCK
1246      P:00034C P:00034C 0D0397            JSR     <CLK_COL_AND_READ
1247      P:00034D P:00034D 60F400            MOVE              #CLOCK_CDS_RESET_ROW_2,R0
                            00015A
1248                                          CLOCK
1252      P:000353 P:000353 0D0397            JSR     <CLK_COL_AND_READ
1253      P:000354 P:000354 0D0515            JSR     <WAIT_TO_FINISH_CLOCKING
1254      P:000355 P:000355 67F400            MOVE              #CDS_RR1,R7
                            000358
1255      P:000357 P:000357 0C044C            JMP     <EXPOSE
1256                                CDS_RR1
1257      P:000358 P:000358 60F400            MOVE              #CLOCK_RR_ROW_1,R0
                            000115
1258                                          CLOCK
1262      P:00035E P:00035E 0D0397            JSR     <CLK_COL_AND_READ
1263      P:00035F P:00035F 60F400            MOVE              #CLOCK_RR_ROW_2,R0
                            00011B
1264                                          CLOCK
1268      P:000365 P:000365 0D0397            JSR     <CLK_COL_AND_READ
1269   
1270      P:000366 P:000366 60F400            MOVE              #CLOCK_CDS_RESET_ROW_3,R0
                            000163
1271                                          CLOCK
1275      P:00036C P:00036C 0D0397            JSR     <CLK_COL_AND_READ
1276      P:00036D P:00036D 60F400            MOVE              #CLOCK_CDS_RESET_ROW_4,R0
                            00016C
1277                                          CLOCK
1281      P:000373 P:000373 0D0397            JSR     <CLK_COL_AND_READ
1282      P:000374 P:000374 0D0515            JSR     <WAIT_TO_FINISH_CLOCKING
1283      P:000375 P:000375 67F400            MOVE              #CDS_RR3,R7
                            000378
1284      P:000377 P:000377 0C044C            JMP     <EXPOSE
1285                                CDS_RR3
1286      P:000378 P:000378 60F400            MOVE              #CLOCK_RR_ROW_3,R0
                            000121
1287                                          CLOCK
1291      P:00037E P:00037E 0D0397            JSR     <CLK_COL_AND_READ
1292      P:00037F P:00037F 60F400            MOVE              #CLOCK_RR_ROW_4,R0
                            000127
1293                                          CLOCK
1297      P:000385 P:000385 0D0397            JSR     <CLK_COL_AND_READ
1298      P:000386 P:000386 000000            NOP
1299                                CDS_RR_RESET_READOUT
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  tim.asm  Page 23



1300   
1301                                ; This is code for continuous readout - check if more frames are needed
1302                                DONE_READOUT
1303      P:000387 P:000387 5E8D00            MOVE                          Y:<N_FRAMES,A ; Are we in continuous readout mode?
1304      P:000388 P:000388 014185            CMP     #1,A
1305      P:000389 P:000389 0EF390            JLE     <RDA_END
1306      P:00038A P:00038A 0A0004            BCLR    #ST_RDC,X:<STATUS                 ; Set status to not reading out
1307      P:00038B P:00038B 0D0515            JSR     <WAIT_TO_FINISH_CLOCKING
1308   
1309                                ; Check for a command once. Only the ABORT command should be issued.
1310      P:00038C P:00038C 330700            MOVE              #COM_BUF,R3
1311      P:00038D P:00038D 0D00A5            JSR     <GET_RCV                          ; Was a command received?
1312      P:00038E P:00038E 0E0499            JCC     <NEXT_FRAME                       ; If no, get the next frame
1313      P:00038F P:00038F 0C005D            JMP     <PRC_RCV                          ; If yes, go process it
1314   
1315                                ; Restore the controller to non-image data transfer and idling if necessary
1316      P:000390 P:000390 60F400  RDA_END   MOVE              #CONT_RST,R0            ; Process commands, don't idle,
                            00022D
1317      P:000392 P:000392 601F00            MOVE              R0,X:<IDL_ADR           ;    during the exposure
1318      P:000393 P:000393 0A0004            BCLR    #ST_RDC,X:<STATUS                 ; Set status to not reading out
1319      P:000394 P:000394 0C0054            JMP     <START
1320   
1321   
1322                                ;  ********  End of readout routines  ****************
1323   
1324                                ; Simple implementation
1325      P:000395 P:000395 010F20  CONTRD    BSET    #TIM_BIT,X:TCSR0                  ; Enable the timer
1326      P:000396 P:000396 0C0054            JMP     <START
1327   
1328   
1329   
1330                                CLK_COL_AND_READ
1331   
1332      P:000397 P:000397 062080            DO      #32,L_CLOCK_COLUMN_AND_READ
                            0003B7
1333   
1334      P:000399 P:000399 60F400            MOVE              #RD_COLS1,R0
                            0001F9
1335                                          CLOCK
1339   
1340      P:00039F P:00039F 060B40            DO      Y:<NDS,SAMPLE_A3
                            0003A7
1341      P:0003A1 P:0003A1 60F400            MOVE              #SAMPLE_COL,R0
                            0001FF
1342                                          CLOCK
1346      P:0003A7 P:0003A7 000000            NOP
1347                                SAMPLE_A3
1348   
1349   
1350      P:0003A8 P:0003A8 60F400            MOVE              #RD_COLS2,R0
                            0001FC
1351                                          CLOCK
1355   
1356   
1357      P:0003AE P:0003AE 060B40            DO      Y:<NDS,SAMPLE_A4
                            0003B6
1358      P:0003B0 P:0003B0 60F400            MOVE              #SAMPLE_COL,R0
                            0001FF
1359                                          CLOCK
1363      P:0003B6 P:0003B6 000000            NOP
1364                                SAMPLE_A4
1365   
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  tim.asm  Page 24



1366   
1367      P:0003B7 P:0003B7 000000            NOP
1368   
1369                                L_CLOCK_COLUMN_AND_READ
1370   
1371                                          CLOCK
1375   
1376      P:0003BC P:0003BC 00000C            RTS
1377   
1378   
1379                                CLK_COL_NO_READ
1380   
1381      P:0003BD P:0003BD 062080            DO      #32,L_CLOCK_COLUMN_NO_READ
                            0003CB
1382   
1383      P:0003BF P:0003BF 60F400            MOVE              #RD_COLS1,R0
                            0001F9
1384                                          CLOCK
1388   
1389      P:0003C5 P:0003C5 60F400            MOVE              #RD_COLS2,R0
                            0001FC
1390                                          CLOCK
1394   
1395      P:0003CB P:0003CB 000000            NOP
1396   
1397                                L_CLOCK_COLUMN_NO_READ
1398   
1399                                          CLOCK
1403   
1404      P:0003D0 P:0003D0 00000C            RTS
1405   
1406   
1407   
1408   
1409   
1410   
1411   
1412   
1413                                ; ******  Include many routines not directly needed for readout  *******
1414                                          INCLUDE "timIRmisc.asm"
1415                                ; Miscellaneous IR array control routines, common to all detector types
1416   
1417                                POWER_OFF
1418      P:0003D1 P:0003D1 0D0430            JSR     <CLEAR_SWITCHES_AND_DACS          ; Clear switches and DACs
1419      P:0003D2 P:0003D2 0A8922            BSET    #LVEN,X:HDR                       ; Turn off low +/- 6.5, +/- 16.5 supplies
1420      P:0003D3 P:0003D3 0A8923            BSET    #HVEN,X:HDR                       ; Turn off high +36 supply
1421      P:0003D4 P:0003D4 0C008F            JMP     <FINISH
1422   
1423                                ; Start power-on cycle
1424                                POWER_ON
1425      P:0003D5 P:0003D5 0D0430            JSR     <CLEAR_SWITCHES_AND_DACS          ; Clear all analog switches
1426      P:0003D6 P:0003D6 0D03E0            JSR     <PON                              ; Turn on the power control board
1427      P:0003D7 P:0003D7 0A8980            JCLR    #PWROK,X:HDR,PWR_ERR              ; Test if the power turned on properly
                            0003DD
1428      P:0003D9 P:0003D9 60F400            MOVE              #CONT_RST,R0            ; Put controller in continuous readout
                            00022D
1429      P:0003DB P:0003DB 601F00            MOVE              R0,X:<IDL_ADR           ;   state
1430      P:0003DC P:0003DC 0C008F            JMP     <FINISH
1431   
1432                                ; The power failed to turn on because of an error on the power control board
1433      P:0003DD P:0003DD 0A8922  PWR_ERR   BSET    #LVEN,X:HDR                       ; Turn off the low voltage emable line
1434      P:0003DE P:0003DE 0A8923            BSET    #HVEN,X:HDR                       ; Turn off the high voltage emable line
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timIRmisc.asm  Page 25



1435      P:0003DF P:0003DF 0C008D            JMP     <ERROR
1436   
1437                                ; Now ramp up the low voltages (+/- 6.5V, 16.5V) and delay them to turn on
1438      P:0003E0 P:0003E0 0A0F20  PON       BSET    #CDAC,X:<LATCH                    ; Disable clearing of DACs
1439      P:0003E1 P:0003E1 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Write it to the hardware
                            00000F
1440   
1441                                ; Write all the bias voltages to the DACs
1442                                SET_BIASES_L
1443      P:0003E3 P:0003E3 012F23            BSET    #3,X:PCRD                         ; Turn the serial clock on
1444      P:0003E4 P:0003E4 0A0F01            BCLR    #1,X:<LATCH                       ; Separate updates of clock driver
1445      P:0003E5 P:0003E5 09F4B3            MOVEP             #$002000,Y:WRSS         ; Set clock driver switches low
                            002000
1446      P:0003E7 P:0003E7 09F4B3            MOVEP             #$003000,Y:WRSS
                            003000
1447      P:0003E9 P:0003E9 0A8902            BCLR    #LVEN,X:HDR                       ; LVEN = Low => Turn on +/- 6.5V,
1448      P:0003EA P:0003EA 0A8923            BSET    #HVEN,X:HDR
1449      P:0003EB P:0003EB 56F400            MOVE              #>40,A                  ; Delay for the power to turn on
                            000028
1450      P:0003ED P:0003ED 0D04DC            JSR     <MILLISEC_DELAY
1451   
1452                                ; Write the values to the clock driver and DC bias supplies
1453      P:0003EE P:0003EE 60F400            MOVE              #BIASES_L,R0            ; Turn on the power before writing to
                            000043
1454      P:0003F0 P:0003F0 0D0528            JSR     <SET_DAC                          ;  the DACs since the MAX829 DAcs need
1455      P:0003F1 P:0003F1 60F400            MOVE              #CLOCKS,R0              ;  power to be written to
                            000011
1456      P:0003F3 P:0003F3 0D0528            JSR     <SET_DAC
1457      P:0003F4 P:0003F4 0D0523            JSR     <PAL_DLY
1458   
1459      P:0003F5 P:0003F5 0A0F22            BSET    #ENCK,X:<LATCH                    ; Enable the output switches
1460      P:0003F6 P:0003F6 09F0B5            MOVEP             X:LATCH,Y:WRLATCH
                            00000F
1461      P:0003F8 P:0003F8 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1462      P:0003F9 P:0003F9 00000C            RTS
1463   
1464                                ; Write all the bias voltages to the DACs
1465                                SET_BIASES
1466      P:0003FA P:0003FA 012F23            BSET    #3,X:PCRD                         ; Turn the serial clock on
1467      P:0003FB P:0003FB 0A0F01            BCLR    #1,X:<LATCH                       ; Separate updates of clock driver
1468      P:0003FC P:0003FC 09F4B3            MOVEP             #$002000,Y:WRSS         ; Set clock driver switches low
                            002000
1469      P:0003FE P:0003FE 09F4B3            MOVEP             #$003000,Y:WRSS
                            003000
1470      P:000400 P:000400 0A8902            BCLR    #LVEN,X:HDR                       ; LVEN = Low => Turn on +/- 6.5V,
1471      P:000401 P:000401 0A8923            BSET    #HVEN,X:HDR
1472      P:000402 P:000402 56F400            MOVE              #>40,A                  ; Delay for the power to turn on
                            000028
1473      P:000404 P:000404 0D04DC            JSR     <MILLISEC_DELAY
1474   
1475                                ; Write the values to the clock driver and DC bias supplies
1476      P:000405 P:000405 60F400            MOVE              #BIASES,R0              ; Turn on the power before writing to
                            0000CF
1477      P:000407 P:000407 0D0528            JSR     <SET_DAC                          ;  the DACs since the MAX829 DAcs need
1478      P:000408 P:000408 60F400            MOVE              #CLOCKS,R0              ;  power to be written to
                            000011
1479      P:00040A P:00040A 0D0528            JSR     <SET_DAC
1480      P:00040B P:00040B 0D0523            JSR     <PAL_DLY
1481   
1482      P:00040C P:00040C 0A0F22            BSET    #ENCK,X:<LATCH                    ; Enable the output switches
1483      P:00040D P:00040D 09F0B5            MOVEP             X:LATCH,Y:WRLATCH
                            00000F
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timIRmisc.asm  Page 26



1484      P:00040F P:00040F 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1485      P:000410 P:000410 00000C            RTS
1486   
1487                                ; Write all the bias voltages to the DACs
1488                                SET_BIASES_H
1489      P:000411 P:000411 012F23            BSET    #3,X:PCRD                         ; Turn the serial clock on
1490      P:000412 P:000412 0A0F01            BCLR    #1,X:<LATCH                       ; Separate updates of clock driver
1491      P:000413 P:000413 09F4B3            MOVEP             #$002000,Y:WRSS         ; Set clock driver switches low
                            002000
1492      P:000415 P:000415 09F4B3            MOVEP             #$003000,Y:WRSS
                            003000
1493      P:000417 P:000417 0A8902            BCLR    #LVEN,X:HDR                       ; LVEN = Low => Turn on +/- 6.5V,
1494      P:000418 P:000418 0A8923            BSET    #HVEN,X:HDR
1495      P:000419 P:000419 56F400            MOVE              #>40,A                  ; Delay for the power to turn on
                            000028
1496      P:00041B P:00041B 0D04DC            JSR     <MILLISEC_DELAY
1497   
1498                                ; Write the values to the clock driver and DC bias supplies
1499      P:00041C P:00041C 60F400            MOVE              #BIASES_H,R0            ; Turn on the power before writing to
                            000089
1500      P:00041E P:00041E 0D0528            JSR     <SET_DAC                          ;  the DACs since the MAX829 DAcs need
1501      P:00041F P:00041F 60F400            MOVE              #CLOCKS,R0              ;  power to be written to
                            000011
1502      P:000421 P:000421 0D0528            JSR     <SET_DAC
1503      P:000422 P:000422 0D0523            JSR     <PAL_DLY
1504   
1505      P:000423 P:000423 0A0F22            BSET    #ENCK,X:<LATCH                    ; Enable the output switches
1506      P:000424 P:000424 09F0B5            MOVEP             X:LATCH,Y:WRLATCH
                            00000F
1507      P:000426 P:000426 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1508      P:000427 P:000427 00000C            RTS
1509   
1510   
1511                                SET_BIAS_VOLTAGES_L
1512      P:000428 P:000428 0D03E3            JSR     <SET_BIASES_L
1513      P:000429 P:000429 0C008F            JMP     <FINISH
1514   
1515                                SET_BIAS_VOLTAGES
1516      P:00042A P:00042A 0D03FA            JSR     <SET_BIASES
1517      P:00042B P:00042B 0C008F            JMP     <FINISH
1518   
1519                                SET_BIAS_VOLTAGES_H
1520      P:00042C P:00042C 0D0411            JSR     <SET_BIASES_H
1521      P:00042D P:00042D 0C008F            JMP     <FINISH
1522   
1523      P:00042E P:00042E 0D0430  CLR_SWS   JSR     <CLEAR_SWITCHES_AND_DACS
1524      P:00042F P:00042F 0C008F            JMP     <FINISH
1525   
1526                                CLEAR_SWITCHES_AND_DACS
1527      P:000430 P:000430 0A0F00            BCLR    #CDAC,X:<LATCH                    ; Clear all the DACs
1528      P:000431 P:000431 0A0F02            BCLR    #ENCK,X:<LATCH                    ; Disable all the output switches
1529      P:000432 P:000432 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Write it to the hardware
                            00000F
1530      P:000434 P:000434 012F23            BSET    #3,X:PCRD                         ; Turn the serial clock on
1531      P:000435 P:000435 56F400            MOVE              #$0C3000,A              ; Value of integrate speed and gain switches
                            0C3000
1532      P:000437 P:000437 20001B            CLR     B
1533      P:000438 P:000438 241000            MOVE              #$100000,X0             ; Increment over board numbers for DAC write
s
1534      P:000439 P:000439 45F400            MOVE              #$001000,X1             ; Increment over board numbers for WRSS writ
es
                            001000
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timIRmisc.asm  Page 27



1535      P:00043B P:00043B 060F80            DO      #15,L_VIDEO                       ; Fifteen video processor boards maximum
                            000442
1536      P:00043D P:00043D 0D020C            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
1537      P:00043E P:00043E 200040            ADD     X0,A
1538      P:00043F P:00043F 5F7000            MOVE                          B,Y:WRSS
                            FFFFF3
1539      P:000441 P:000441 0D0523            JSR     <PAL_DLY                          ; Delay for the serial data transmission
1540      P:000442 P:000442 200068            ADD     X1,B
1541                                L_VIDEO
1542      P:000443 P:000443 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1543      P:000444 P:000444 00000C            RTS
1544   
1545                                ; Fast clear of the array, executed as a command
1546      P:000445 P:000445 60F400  CLEAR     MOVE              #FRAME_RESET,R0
                            000183
1547                                          CLOCK
1551      P:00044B P:00044B 0C008F            JMP     <FINISH
1552   
1553                                ; Start the exposure timer and monitor its progress
1554                                EXPOSE
1555      P:00044C P:00044C 07F40E            MOVEP             #0,X:TLR0               ; Load 0 into counter timer
                            000000
1556      P:00044E P:00044E 240000            MOVE              #0,X0
1557      P:00044F P:00044F 441100            MOVE              X0,X:<ELAPSED_TIME      ; Set elapsed exposure time to zero
1558      P:000450 P:000450 579000            MOVE              X:<EXPOSURE_TIME,B
1559      P:000451 P:000451 20000B            TST     B                                 ; Special test for zero exposure time
1560      P:000452 P:000452 0EA45E            JEQ     <END_EXP                          ; Don't even start an exposure
1561      P:000453 P:000453 01418C            SUB     #1,B                              ; Timer counts from X:TCPR0+1 to zero
1562      P:000454 P:000454 010F20            BSET    #TIM_BIT,X:TCSR0                  ; Enable the timer #0
1563      P:000455 P:000455 577000            MOVE              B,X:TCPR0
                            FFFF8D
1564                                CHK_RCV
1565      P:000457 P:000457 0A8989            JCLR    #EF,X:HDR,CHK_TIM                 ; Simple test for fast execution
                            00045C
1566      P:000459 P:000459 330700            MOVE              #COM_BUF,R3             ; The beginning of the command buffer
1567      P:00045A P:00045A 0D00A5            JSR     <GET_RCV                          ; Check for an incoming command
1568      P:00045B P:00045B 0E805D            JCS     <PRC_RCV                          ; If command is received, go check it
1569                                CHK_TIM
1570      P:00045C P:00045C 018F95            JCLR    #TCF,X:TCSR0,CHK_RCV              ; Wait for timer to equal compare value
                            000457
1571                                END_EXP
1572      P:00045E P:00045E 010F00            BCLR    #TIM_BIT,X:TCSR0                  ; Disable the timer
1573      P:00045F P:00045F 0AE780            JMP     (R7)                              ; This contains the return address
1574   
1575                                ;  *****************  Start the exposure  *****************
1576   
1577                                START_EXPOSURE
1578      P:000460 P:000460 0D04B5            JSR     <INIT_PCI_IMAGE_ADDRESS
1579   
1580      P:000461 P:000461 0D0277            JSR     <RESET_ARRAY                      ; Clear out the FPA
1581   
1582      P:000462 P:000462 060A40            DO      Y:<NFS,RD1_END                    ; Fowler sampling
                            000466
1583      P:000464 P:000464 0D04B5            JSR     <INIT_PCI_IMAGE_ADDRESS
1584      P:000465 P:000465 0D0284            JSR     <READOUT                          ; Read out the FPA
1585      P:000466 P:000466 000000            NOP
1586   
1587                                RD1_END
1588   
1589   
1590   
1591   
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timIRmisc.asm  Page 28



1592      P:000467 P:000467 67F400            MOVE              #L_SEX1,R7              ; Return address at end of exposure
                            00046A
1593      P:000469 P:000469 0C044C            JMP     <EXPOSE                           ; Delay for specified exposure time
1594                                L_SEX1
1595   
1596   
1597   
1598   
1599   
1600      P:00046A P:00046A 060A40            DO      Y:<NFS,RD2_END                    ; Fowler sampling
                            00046E
1601      P:00046C P:00046C 0D04B5            JSR     <INIT_PCI_IMAGE_ADDRESS
1602      P:00046D P:00046D 0D0284            JSR     <READOUT                          ; Read out the FPA
1603      P:00046E P:00046E 000000            NOP
1604                                RD2_END
1605   
1606      P:00046F P:00046F 000000            NOP
1607      P:000470 P:000470 0C0054            JMP     <START
1608   
1609   
1610   
1611                                ; ***************** Start Read up the Ramp linear *****************
1612   
1613                                START_RR_LINEAR
1614      P:000471 P:000471 0D04B5            JSR     <INIT_PCI_IMAGE_ADDRESS
1615      P:000472 P:000472 0D0277            JSR     <RESET_ARRAY                      ; Clear out the FPA
1616   
1617   
1618      P:000473 P:000473 200013            CLR     A
1619      P:000474 P:000474 5E8A00            MOVE                          Y:<NFS,A
1620      P:000475 P:000475 014184            SUB     #1,A                              ; subtract one readout from the loop and do 
the readout at the end
1621      P:000476 P:000476 000000            NOP
1622   
1623      P:000477 P:000477 06CE00            DO      A,RRL_END                         ; number of samples
                            00047D
1624      P:000479 P:000479 0D0284            JSR     <READOUT                          ; Read out the FPA
1625   
1626   
1627      P:00047A P:00047A 67F400            MOVE              #L_SEX2,R7              ; Return address at end of exposure
                            00047D
1628      P:00047C P:00047C 0C044C            JMP     <EXPOSE                           ; Delay for specified exposure time
1629                                L_SEX2
1630   
1631   
1632      P:00047D P:00047D 000000            NOP
1633                                RRL_END
1634   
1635      P:00047E P:00047E 0D0284            JSR     <READOUT                          ; final readout after all exposures
1636   
1637      P:00047F P:00047F 0C0054            JMP     <START
1638   
1639   
1640   
1641   
1642                                ; ***************** Start Read up the Ramp exponential *****************
1643   
1644   
1645   
1646   
1647                                START_RR_EXP
1648      P:000480 P:000480 0D04B5            JSR     <INIT_PCI_IMAGE_ADDRESS
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timIRmisc.asm  Page 29



1649      P:000481 P:000481 0D0277            JSR     <RESET_ARRAY                      ; Clear out the FPA
1650   
1651   
1652      P:000482 P:000482 200013            CLR     A
1653      P:000483 P:000483 5E8A00            MOVE                          Y:<NFS,A
1654      P:000484 P:000484 014184            SUB     #1,A                              ; subtract one readout from the loop and do 
the readout at the end
1655      P:000485 P:000485 000000            NOP
1656   
1657      P:000486 P:000486 06CE00            DO      A,RRE_END                         ; read up the ramp exponential
                            00048C
1658   
1659      P:000488 P:000488 0D0284            JSR     <READOUT                          ; Read out the FPA
1660   
1661   
1662      P:000489 P:000489 67F400            MOVE              #L_SEX3,R7              ; Return address at end of exposure
                            00048C
1663      P:00048B P:00048B 0C044C            JMP     <EXPOSE                           ; Delay for specified exposure time
1664                                L_SEX3
1665   
1666   
1667      P:00048C P:00048C 000000            NOP
1668                                RRE_END
1669   
1670      P:00048D P:00048D 0D0284            JSR     <READOUT                          ; final readout after all exposures
1671   
1672      P:00048E P:00048E 0C0054            JMP     <START
1673   
1674   
1675   
1676   
1677                                ; Test for continuous readout
1678                                ;       MOVE    Y:<N_FRAMES,A
1679                                ;       CMP     #1,A
1680                                ;       JLE     <INIT_PCI_BOARD
1681   
1682                                INIT_FRAME_COUNT
1683      P:00048F P:00048F 0D0515            JSR     <WAIT_TO_FINISH_CLOCKING
1684      P:000490 P:000490 57F400            MOVE              #$020102,B              ; Initialize the PCI frame counter
                            020102
1685      P:000492 P:000492 0D00EB            JSR     <XMT_WRD
1686      P:000493 P:000493 57F400            MOVE              #'IFC',B
                            494643
1687      P:000495 P:000495 0D00EB            JSR     <XMT_WRD
1688      P:000496 P:000496 240000            MOVE              #0,X0
1689      P:000497 P:000497 4C0E00            MOVE                          X0,Y:<I_FRAME ; Initialize the frame number
1690      P:000498 P:000498 0C04A5            JMP     <INIT_PCI_BOARD
1691   
1692                                ; Start up the next frame of the coaddition series
1693                                NEXT_FRAME
1694      P:000499 P:000499 5E8E00            MOVE                          Y:<I_FRAME,A ; Get the # of frames coadded so far
1695      P:00049A P:00049A 014180            ADD     #1,A
1696      P:00049B P:00049B 4C8D00            MOVE                          Y:<N_FRAMES,X0 ; See if we've coadded enough frames
1697      P:00049C P:00049C 5C0E00            MOVE                          A1,Y:<I_FRAME ; Increment the coaddition frame counter
1698      P:00049D P:00049D 200045            CMP     X0,A
1699      P:00049E P:00049E 0E1390            JGE     <RDA_END                          ; End of coaddition sequence
1700   
1701      P:00049F P:00049F 5E8F00            MOVE                          Y:<IBUFFER,A ; Get the position in the buffer
1702      P:0004A0 P:0004A0 014180            ADD     #1,A
1703      P:0004A1 P:0004A1 4C9000            MOVE                          Y:<N_FPB,X0
1704      P:0004A2 P:0004A2 5C0F00            MOVE                          A1,Y:<IBUFFER
1705      P:0004A3 P:0004A3 200045            CMP     X0,A
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timIRmisc.asm  Page 30



1706      P:0004A4 P:0004A4 0E94AD            JLT     <SEX_1                            ; Test if the frame buffer is full
1707   
1708                                INIT_PCI_BOARD
1709      P:0004A5 P:0004A5 240000            MOVE              #0,X0
1710      P:0004A6 P:0004A6 4C0F00            MOVE                          X0,Y:<IBUFFER ; IBUFFER counts from 0 to N_FPB
1711      P:0004A7 P:0004A7 57F400            MOVE              #$020102,B
                            020102
1712      P:0004A9 P:0004A9 0D00EB            JSR     <XMT_WRD
1713      P:0004AA P:0004AA 57F400            MOVE              #'IIA',B                ; Initialize the PCI image address
                            494941
1714      P:0004AC P:0004AC 0D00EB            JSR     <XMT_WRD
1715   
1716                                ; Start the exposure
1717      P:0004AD P:0004AD 0A00AA  SEX_1     JSET    #TST_IMG,X:STATUS,SYNTHETIC_IMAGE
                            0004E8
1718      P:0004AF P:0004AF 56F400            MOVE              #$0c1000,A              ; Reset video processor FIFOs
                            0C1000
1719      P:0004B1 P:0004B1 0D0502            JSR     <WR_BIAS
1720      P:0004B2 P:0004B2 0A00B2            JSET    #ST_RRR,X:STATUS,ROW_BY_ROW_RESET_READOUT
                            0002F1
1721      P:0004B4 P:0004B4 0C0277            JMP     <NORMAL_READOUT
1722   
1723   
1724                                ; ********************* Initialize PCI image address ***********************
1725                                INIT_PCI_IMAGE_ADDRESS
1726      P:0004B5 P:0004B5 57F400            MOVE              #$020102,B              ; Initialize the PCI image address
                            020102
1727      P:0004B7 P:0004B7 0D00EB            JSR     <XMT_WRD
1728      P:0004B8 P:0004B8 57F400            MOVE              #'IIA',B
                            494941
1729      P:0004BA P:0004BA 0D00EB            JSR     <XMT_WRD
1730      P:0004BB P:0004BB 00000C            RTS
1731   
1732   
1733                                ; Set the desired exposure time
1734                                SET_EXPOSURE_TIME
1735      P:0004BC P:0004BC 46DB00            MOVE              X:(R3)+,Y0
1736      P:0004BD P:0004BD 461000            MOVE              Y0,X:EXPOSURE_TIME
1737      P:0004BE P:0004BE 018F80            JCLR    #TIM_BIT,X:TCSR0,FINISH           ; Return if exposure not occurring
                            00008F
1738      P:0004C0 P:0004C0 467000            MOVE              Y0,X:TCPR0              ; Update timer if exposure in progress
                            FFFF8D
1739      P:0004C2 P:0004C2 0C008F            JMP     <FINISH
1740   
1741                                ; Read the time remaining until the exposure ends
1742                                READ_EXPOSURE_TIME
1743      P:0004C3 P:0004C3 018FA0            JSET    #TIM_BIT,X:TCSR0,RD_TIM           ; Read DSP timer if its running
                            0004C7
1744      P:0004C5 P:0004C5 479100            MOVE              X:<ELAPSED_TIME,Y1
1745      P:0004C6 P:0004C6 0C0090            JMP     <FINISH1
1746      P:0004C7 P:0004C7 47F000  RD_TIM    MOVE              X:TCR0,Y1               ; Read elapsed exposure time
                            FFFF8C
1747      P:0004C9 P:0004C9 0C0090            JMP     <FINISH1
1748   
1749                                ; Pause the exposure - close the shutter and stop the timer
1750                                PAUSE_EXPOSURE
1751      P:0004CA P:0004CA 07700C            MOVEP             X:TCR0,X:ELAPSED_TIME   ; Save the elapsed exposure time
                            000011
1752      P:0004CC P:0004CC 010F00            BCLR    #TIM_BIT,X:TCSR0                  ; Disable the DSP exposure timer
1753      P:0004CD P:0004CD 0C008F            JMP     <FINISH
1754   
1755                                ; Resume the exposure - open the shutter if needed and restart the timer
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timIRmisc.asm  Page 31



1756                                RESUME_EXPOSURE
1757      P:0004CE P:0004CE 07F00E            MOVEP             X:ELAPSED_TIME,X:TLR0   ; Restore elapsed exposure time
                            000011
1758      P:0004D0 P:0004D0 010F20            BSET    #TIM_BIT,X:TCSR0                  ; Re-enable the DSP exposure timer
1759      P:0004D1 P:0004D1 0C008F  L_RES     JMP     <FINISH
1760   
1761                                ; Special ending after abort command to send a 'DON' to the host computer
1762                                ; Abort exposure - close the shutter, stop the timer and resume idle mode
1763                                ABORT_EXPOSURE
1764      P:0004D2 P:0004D2 010F00            BCLR    #TIM_BIT,X:TCSR0                  ; Disable the DSP exposure timer
1765      P:0004D3 P:0004D3 60F400            MOVE              #CONT_RST,R0
                            00022D
1766      P:0004D5 P:0004D5 601F00            MOVE              R0,X:<IDL_ADR
1767      P:0004D6 P:0004D6 0D0515            JSR     <WAIT_TO_FINISH_CLOCKING
1768      P:0004D7 P:0004D7 0A0004            BCLR    #ST_RDC,X:<STATUS                 ; Set status to not reading out
1769      P:0004D8 P:0004D8 06A08F            DO      #4000,*+3                         ; Wait 40 microsec for the fiber
                            0004DA
1770      P:0004DA P:0004DA 000000            NOP                                       ;  optic to clear out
1771      P:0004DB P:0004DB 0C008F            JMP     <FINISH
1772   
1773                                ; Short delay for the array to settle down after a global reset
1774                                MILLISEC_DELAY
1775      P:0004DC P:0004DC 200003            TST     A
1776      P:0004DD P:0004DD 0E24DF            JNE     <DLY_IT
1777      P:0004DE P:0004DE 00000C            RTS
1778      P:0004DF P:0004DF 07F40E  DLY_IT    MOVEP             #0,X:TLR0               ; Load 0 into counter timer
                            000000
1779      P:0004E1 P:0004E1 010F20            BSET    #TIM_BIT,X:TCSR0                  ; Enable the timer #0
1780      P:0004E2 P:0004E2 567000            MOVE              A,X:TCPR0               ; Desired elapsed time
                            FFFF8D
1781      P:0004E4 P:0004E4 018F95  CNT_DWN   JCLR    #TCF,X:TCSR0,CNT_DWN              ; Wait here for timer to count down
                            0004E4
1782      P:0004E6 P:0004E6 010F00            BCLR    #TIM_BIT,X:TCSR0
1783      P:0004E7 P:0004E7 00000C            RTS
1784   
1785                                ; Generate a synthetic image by simply incrementing the pixel counts
1786                                SYNTHETIC_IMAGE
1787      P:0004E8 P:0004E8 0D0509            JSR     <PCI_READ_IMAGE
1788                                                                                    ;CLR    A
1789                                ;       DO      Y:<NPR,LPR_TST          ; Loop over each line readout
1790      P:0004E9 P:0004E9 060182            DO      #513,LPR_TST                      ; Loop over each line readout
                            0004F4
1791      P:0004EB P:0004EB 060140            DO      Y:<NSR,LSR_TST                    ; Loop over number of pixels per line
                            0004F2
1792      P:0004ED P:0004ED 0614A0            REP     #20                               ; #20 => 1.0 microsec per pixel
1793      P:0004EE P:0004EE 000000            NOP
1794                                ;       ADD     #1,A                    ; Pixel data = Pixel data + 1
1795      P:0004EF P:0004EF 000000            NOP
1796      P:0004F0 P:0004F0 21CF00            MOVE              A,B
1797      P:0004F1 P:0004F1 0D04F8            JSR     <XMT_PIX                          ; Transmit the pixel data
1798      P:0004F2 P:0004F2 000000            NOP
1799                                LSR_TST
1800      P:0004F3 P:0004F3 014180            ADD     #1,A                              ; Pixel data = Pixel data + 1
1801      P:0004F4 P:0004F4 000000            NOP
1802                                LPR_TST
1803      P:0004F5 P:0004F5 0140C0            ADD     #10000,A
                            002710
1804      P:0004F7 P:0004F7 00000C            RTS
1805   
1806                                ; Transmit the 16-bit pixel datum in B1 to the host computer
1807      P:0004F8 P:0004F8 0C1DA1  XMT_PIX   ASL     #16,B,B
1808      P:0004F9 P:0004F9 000000            NOP
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timIRmisc.asm  Page 32



1809      P:0004FA P:0004FA 216500            MOVE              B2,X1
1810      P:0004FB P:0004FB 0C1D91            ASL     #8,B,B
1811      P:0004FC P:0004FC 000000            NOP
1812      P:0004FD P:0004FD 216400            MOVE              B2,X0
1813      P:0004FE P:0004FE 000000            NOP
1814      P:0004FF P:0004FF 09C532            MOVEP             X1,Y:WRFO
1815      P:000500 P:000500 09C432            MOVEP             X0,Y:WRFO
1816      P:000501 P:000501 00000C            RTS
1817   
1818                                ; Write a number to an analog board over the serial link
1819      P:000502 P:000502 012F23  WR_BIAS   BSET    #3,X:PCRD                         ; Turn on the serial clock
1820      P:000503 P:000503 0D0523            JSR     <PAL_DLY
1821      P:000504 P:000504 0D020C            JSR     <XMIT_A_WORD                      ; Transmit it to TIM-A-STD
1822      P:000505 P:000505 0D0523            JSR     <PAL_DLY
1823      P:000506 P:000506 012F03            BCLR    #3,X:PCRD                         ; Turn off the serial clock
1824      P:000507 P:000507 0D0523            JSR     <PAL_DLY
1825      P:000508 P:000508 00000C            RTS
1826   
1827                                ; Alert the PCI interface board that images are coming soon
1828                                ;   Image size = 512columns x 512 x # of Fowler samples x 2 if CDS
1829   
1830                                PCI_READ_IMAGE
1831      P:000509 P:000509 57F400            MOVE              #$020104,B              ; Send header word to the FO transmitter
                            020104
1832      P:00050B P:00050B 0D00EB            JSR     <XMT_WRD
1833      P:00050C P:00050C 57F400            MOVE              #'RDA',B
                            524441
1834      P:00050E P:00050E 0D00EB            JSR     <XMT_WRD
1835      P:00050F P:00050F 5F8100            MOVE                          Y:<NSR,B    ; Number of columns to read
1836      P:000510 P:000510 0D00EB            JSR     <XMT_WRD
1837                                ;       MOVE    Y:<NPR,B
1838      P:000511 P:000511 57F400            MOVE              #513,B
                            000201
1839      P:000513 P:000513 0D00EB            JSR     <XMT_WRD                          ; Number of rows to read
1840      P:000514 P:000514 00000C            RTS
1841   
1842                                ; Wait for the clocking to be complete before proceeding
1843                                WAIT_TO_FINISH_CLOCKING
1844      P:000515 P:000515 01ADA1            JSET    #SSFEF,X:PDRD,*                   ; Wait for the SS FIFO to be empty
                            000515
1845      P:000517 P:000517 00000C            RTS
1846   
1847                                ; This MOVEP instruction executes in 30 nanosec, 20 nanosec for the MOVEP,
1848                                ;   and 10 nanosec for the wait state that is required for SRAM writes and
1849                                ;   FIFO setup times. It looks reliable, so will be used for now.
1850   
1851                                ; Core subroutine for clocking
1852                                CLOCK
1853      P:000518 P:000518 0A898E            JCLR    #SSFHF,X:HDR,*                    ; Only write to FIFO if < half full
                            000518
1854      P:00051A P:00051A 000000            NOP
1855      P:00051B P:00051B 0A898E            JCLR    #SSFHF,X:HDR,CLOCK                ; Guard against metastability
                            000518
1856      P:00051D P:00051D 4CD800            MOVE                          Y:(R0)+,X0  ; # of waveform entries
1857      P:00051E P:00051E 06C400            DO      X0,CLK1                           ; Repeat X0 times
                            000520
1858      P:000520 P:000520 09D8F3            MOVEP             Y:(R0)+,Y:WRSS          ; 30 nsec Write the waveform to the SS
1859                                CLK1
1860      P:000521 P:000521 000000            NOP
1861      P:000522 P:000522 00000C            RTS                                       ; Return from subroutine
1862   
1863                                ; Delay for serial writes to the PALs and DACs by 8 microsec
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timIRmisc.asm  Page 33



1864      P:000523 P:000523 062083  PAL_DLY   DO      #800,DLY                          ; Wait 8 usec for serial data transmission
                            000525
1865      P:000525 P:000525 000000            NOP
1866      P:000526 P:000526 000000  DLY       NOP
1867      P:000527 P:000527 00000C            RTS
1868   
1869                                ; Read DAC values from a table, and write them to the DACs
1870      P:000528 P:000528 065840  SET_DAC   DO      Y:(R0)+,L_DAC                     ; Repeat Y:(R0)+ times
                            00052F
1871      P:00052A P:00052A 5ED800            MOVE                          Y:(R0)+,A   ; Read the table entry
1872      P:00052B P:00052B 0D020C            JSR     <XMIT_A_WORD                      ; Transmit it to TIM-A-STD
1873      P:00052C P:00052C 000000            NOP
1874      P:00052D P:00052D 0D0523            JSR     <PAL_DLY
1875      P:00052E P:00052E 0D0523            JSR     <PAL_DLY
1876      P:00052F P:00052F 000000            NOP
1877      P:000530 P:000530 00000C  L_DAC     RTS
1878   
1879                                ; Let the host computer read the controller configuration
1880                                READ_CONTROLLER_CONFIGURATION
1881      P:000531 P:000531 4F8800            MOVE                          Y:<CONFIG,Y1 ; Just transmit the configuration
1882      P:000532 P:000532 0C0090            JMP     <FINISH1
1883   
1884                                ; Set a particular DAC numbers, for setting DC bias voltages, clock driver
1885                                ;   voltages and video processor offset
1886                                ;
1887                                ; SBN  #BOARD  #DAC  ['CLK' or 'VID'] voltage
1888                                ;
1889                                ;                               #BOARD is from 0 to 15
1890                                ;                               #DAC number
1891                                ;                               #voltage is from 0 to 4095
1892   
1893                                SET_BIAS_NUMBER                                     ; Set bias number
1894      P:000533 P:000533 012F23            BSET    #3,X:PCRD                         ; Turn on the serial clock
1895      P:000534 P:000534 56DB00            MOVE              X:(R3)+,A               ; First argument is board number, 0 to 15
1896      P:000535 P:000535 0614A0            REP     #20
1897      P:000536 P:000536 200033            LSL     A
1898      P:000537 P:000537 000000            NOP
1899      P:000538 P:000538 21C500            MOVE              A,X1                    ; Save the board number
1900      P:000539 P:000539 56DB00            MOVE              X:(R3)+,A               ; Second argument is DAC number
1901      P:00053A P:00053A 000000            NOP
1902      P:00053B P:00053B 5C0000            MOVE                          A1,Y:0      ; Save the DAC number for a little while
1903      P:00053C P:00053C 57DB00            MOVE              X:(R3)+,B               ; Third argument is 'VID' or 'CLK' string
1904      P:00053D P:00053D 0140CD            CMP     #'VID',B
                            564944
1905      P:00053F P:00053F 0EA579            JEQ     <ERR_SBN                          ; Video board offsets aren't supported
1906      P:000540 P:000540 0140CD            CMP     #'CLK',B
                            434C4B
1907      P:000542 P:000542 0E2579            JNE     <ERR_SBN
1908   
1909                                ; For ARC32 do some trickiness to set the chip select and address bits
1910      P:000543 P:000543 218F00            MOVE              A1,B
1911      P:000544 P:000544 060EA0            REP     #14
1912      P:000545 P:000545 200033            LSL     A
1913      P:000546 P:000546 240E00            MOVE              #$0E0000,X0
1914      P:000547 P:000547 200046            AND     X0,A
1915      P:000548 P:000548 44F400            MOVE              #>7,X0
                            000007
1916      P:00054A P:00054A 20004E            AND     X0,B                              ; Get 3 least significant bits of clock #
1917      P:00054B P:00054B 01408D            CMP     #0,B
1918      P:00054C P:00054C 0E254F            JNE     <CLK_1
1919      P:00054D P:00054D 0ACE68            BSET    #8,A
1920      P:00054E P:00054E 0C056A            JMP     <BD_SET
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timIRmisc.asm  Page 34



1921      P:00054F P:00054F 01418D  CLK_1     CMP     #1,B
1922      P:000550 P:000550 0E2553            JNE     <CLK_2
1923      P:000551 P:000551 0ACE69            BSET    #9,A
1924      P:000552 P:000552 0C056A            JMP     <BD_SET
1925      P:000553 P:000553 01428D  CLK_2     CMP     #2,B
1926      P:000554 P:000554 0E2557            JNE     <CLK_3
1927      P:000555 P:000555 0ACE6A            BSET    #10,A
1928      P:000556 P:000556 0C056A            JMP     <BD_SET
1929      P:000557 P:000557 01438D  CLK_3     CMP     #3,B
1930      P:000558 P:000558 0E255B            JNE     <CLK_4
1931      P:000559 P:000559 0ACE6B            BSET    #11,A
1932      P:00055A P:00055A 0C056A            JMP     <BD_SET
1933      P:00055B P:00055B 01448D  CLK_4     CMP     #4,B
1934      P:00055C P:00055C 0E255F            JNE     <CLK_5
1935      P:00055D P:00055D 0ACE6D            BSET    #13,A
1936      P:00055E P:00055E 0C056A            JMP     <BD_SET
1937      P:00055F P:00055F 01458D  CLK_5     CMP     #5,B
1938      P:000560 P:000560 0E2563            JNE     <CLK_6
1939      P:000561 P:000561 0ACE6E            BSET    #14,A
1940      P:000562 P:000562 0C056A            JMP     <BD_SET
1941      P:000563 P:000563 01468D  CLK_6     CMP     #6,B
1942      P:000564 P:000564 0E2567            JNE     <CLK_7
1943      P:000565 P:000565 0ACE6F            BSET    #15,A
1944      P:000566 P:000566 0C056A            JMP     <BD_SET
1945      P:000567 P:000567 01478D  CLK_7     CMP     #7,B
1946      P:000568 P:000568 0E256A            JNE     <BD_SET
1947      P:000569 P:000569 0ACE70            BSET    #16,A
1948   
1949      P:00056A P:00056A 200062  BD_SET    OR      X1,A                              ; Add on the board number
1950      P:00056B P:00056B 000000            NOP
1951      P:00056C P:00056C 21C400            MOVE              A,X0
1952      P:00056D P:00056D 56DB00            MOVE              X:(R3)+,A               ; Fourth argument is voltage value, 0 to $ff
f
1953      P:00056E P:00056E 0604A0            REP     #4
1954      P:00056F P:00056F 200023            LSR     A                                 ; Convert 12 bits to 8 bits for ARC32
1955      P:000570 P:000570 46F400            MOVE              #>$FF,Y0                ; Mask off just 8 bits
                            0000FF
1956      P:000572 P:000572 200056            AND     Y0,A
1957      P:000573 P:000573 200042            OR      X0,A
1958      P:000574 P:000574 000000            NOP
1959      P:000575 P:000575 0D020C            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
1960      P:000576 P:000576 0D0523            JSR     <PAL_DLY                          ; Wait for the number to be sent
1961      P:000577 P:000577 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1962      P:000578 P:000578 0C008F            JMP     <FINISH
1963      P:000579 P:000579 56DB00  ERR_SBN   MOVE              X:(R3)+,A               ; Read and discard the fourth argument
1964      P:00057A P:00057A 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1965      P:00057B P:00057B 0C008D            JMP     <ERROR
1966   
1967                                ; Specify the MUX value to be output on the clock driver board
1968                                ; Command syntax is  SMX  #clock_driver_board #MUX1 #MUX2
1969                                ;                               #clock_driver_board from 0 to 15
1970                                ;                               #MUX1, #MUX2 from 0 to 23
1971   
1972      P:00057C P:00057C 012F23  SET_MUX   BSET    #3,X:PCRD                         ; Turn on the serial clock
1973      P:00057D P:00057D 56DB00            MOVE              X:(R3)+,A               ; Clock driver board number
1974      P:00057E P:00057E 0614A0            REP     #20
1975      P:00057F P:00057F 200033            LSL     A
1976      P:000580 P:000580 44F400            MOVE              #$001000,X0             ; Bits to select MUX on ARC32 board
                            001000
1977      P:000582 P:000582 200042            OR      X0,A
1978      P:000583 P:000583 000000            NOP
1979      P:000584 P:000584 218500            MOVE              A1,X1                   ; Move here for later use
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timIRmisc.asm  Page 35



1980   
1981                                ; Get the first MUX number
1982      P:000585 P:000585 56DB00            MOVE              X:(R3)+,A               ; Get the first MUX number
1983      P:000586 P:000586 200003            TST     A
1984      P:000587 P:000587 0E95CC            JLT     <ERR_SM1
1985      P:000588 P:000588 44F400            MOVE              #>24,X0                 ; Check for argument less than 32
                            000018
1986      P:00058A P:00058A 200045            CMP     X0,A
1987      P:00058B P:00058B 0E15CC            JGE     <ERR_SM1
1988      P:00058C P:00058C 21CF00            MOVE              A,B
1989      P:00058D P:00058D 44F400            MOVE              #>7,X0
                            000007
1990      P:00058F P:00058F 20004E            AND     X0,B
1991      P:000590 P:000590 44F400            MOVE              #>$18,X0
                            000018
1992      P:000592 P:000592 200046            AND     X0,A
1993      P:000593 P:000593 0E2596            JNE     <SMX_1                            ; Test for 0 <= MUX number <= 7
1994      P:000594 P:000594 0ACD63            BSET    #3,B1
1995      P:000595 P:000595 0C05A1            JMP     <SMX_A
1996      P:000596 P:000596 44F400  SMX_1     MOVE              #>$08,X0
                            000008
1997      P:000598 P:000598 200045            CMP     X0,A                              ; Test for 8 <= MUX number <= 15
1998      P:000599 P:000599 0E259C            JNE     <SMX_2
1999      P:00059A P:00059A 0ACD64            BSET    #4,B1
2000      P:00059B P:00059B 0C05A1            JMP     <SMX_A
2001      P:00059C P:00059C 44F400  SMX_2     MOVE              #>$10,X0
                            000010
2002      P:00059E P:00059E 200045            CMP     X0,A                              ; Test for 16 <= MUX number <= 23
2003      P:00059F P:00059F 0E25CC            JNE     <ERR_SM1
2004      P:0005A0 P:0005A0 0ACD65            BSET    #5,B1
2005      P:0005A1 P:0005A1 20006A  SMX_A     OR      X1,B1                             ; Add prefix to MUX numbers
2006      P:0005A2 P:0005A2 000000            NOP
2007      P:0005A3 P:0005A3 21A700            MOVE              B1,Y1
2008   
2009                                ; Add on the second MUX number
2010      P:0005A4 P:0005A4 56DB00            MOVE              X:(R3)+,A               ; Get the next MUX number
2011      P:0005A5 P:0005A5 200003            TST     A
2012      P:0005A6 P:0005A6 0E95CD            JLT     <ERR_SM2
2013      P:0005A7 P:0005A7 44F400            MOVE              #>24,X0                 ; Check for argument less than 32
                            000018
2014      P:0005A9 P:0005A9 200045            CMP     X0,A
2015      P:0005AA P:0005AA 0E15CD            JGE     <ERR_SM2
2016      P:0005AB P:0005AB 0606A0            REP     #6
2017      P:0005AC P:0005AC 200033            LSL     A
2018      P:0005AD P:0005AD 000000            NOP
2019      P:0005AE P:0005AE 21CF00            MOVE              A,B
2020      P:0005AF P:0005AF 44F400            MOVE              #$1C0,X0
                            0001C0
2021      P:0005B1 P:0005B1 20004E            AND     X0,B
2022      P:0005B2 P:0005B2 44F400            MOVE              #>$600,X0
                            000600
2023      P:0005B4 P:0005B4 200046            AND     X0,A
2024      P:0005B5 P:0005B5 0E25B8            JNE     <SMX_3                            ; Test for 0 <= MUX number <= 7
2025      P:0005B6 P:0005B6 0ACD69            BSET    #9,B1
2026      P:0005B7 P:0005B7 0C05C3            JMP     <SMX_B
2027      P:0005B8 P:0005B8 44F400  SMX_3     MOVE              #>$200,X0
                            000200
2028      P:0005BA P:0005BA 200045            CMP     X0,A                              ; Test for 8 <= MUX number <= 15
2029      P:0005BB P:0005BB 0E25BE            JNE     <SMX_4
2030      P:0005BC P:0005BC 0ACD6A            BSET    #10,B1
2031      P:0005BD P:0005BD 0C05C3            JMP     <SMX_B
2032      P:0005BE P:0005BE 44F400  SMX_4     MOVE              #>$400,X0
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timIRmisc.asm  Page 36



                            000400
2033      P:0005C0 P:0005C0 200045            CMP     X0,A                              ; Test for 16 <= MUX number <= 23
2034      P:0005C1 P:0005C1 0E25CD            JNE     <ERR_SM2
2035      P:0005C2 P:0005C2 0ACD6B            BSET    #11,B1
2036      P:0005C3 P:0005C3 200078  SMX_B     ADD     Y1,B                              ; Add prefix to MUX numbers
2037      P:0005C4 P:0005C4 000000            NOP
2038      P:0005C5 P:0005C5 21AE00            MOVE              B1,A
2039      P:0005C6 P:0005C6 0140C6            AND     #$F01FFF,A                        ; Just to be sure
                            F01FFF
2040      P:0005C8 P:0005C8 0D020C            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
2041      P:0005C9 P:0005C9 0D0523            JSR     <PAL_DLY                          ; Delay for all this to happen
2042      P:0005CA P:0005CA 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
2043      P:0005CB P:0005CB 0C008F            JMP     <FINISH
2044      P:0005CC P:0005CC 56DB00  ERR_SM1   MOVE              X:(R3)+,A               ; Throw off the last argument
2045      P:0005CD P:0005CD 012F03  ERR_SM2   BCLR    #3,X:PCRD                         ; Turn the serial clock off
2046      P:0005CE P:0005CE 0C008D            JMP     <ERROR
2047   
2048   
2049                                CORRELATED_DOUBLE_SAMPLE
2050      P:0005CF P:0005CF 44DB00            MOVE              X:(R3)+,X0              ; Get the command argument
2051      P:0005D0 P:0005D0 0AC420            JSET    #0,X0,CDS_SET
                            0005D4
2052      P:0005D2 P:0005D2 0A0011            BCLR    #ST_CDS,X:STATUS
2053      P:0005D3 P:0005D3 0C008F            JMP     <FINISH
2054      P:0005D4 P:0005D4 0A0031  CDS_SET   BSET    #ST_CDS,X:STATUS
2055      P:0005D5 P:0005D5 0C008F            JMP     <FINISH
2056   
2057                                SELECT_ROW_BY_ROW_RESET
2058      P:0005D6 P:0005D6 44DB00            MOVE              X:(R3)+,X0              ; Get the command argument
2059      P:0005D7 P:0005D7 0AC420            JSET    #0,X0,RR_SET
                            0005DB
2060      P:0005D9 P:0005D9 0A0012            BCLR    #ST_RRR,X:STATUS
2061      P:0005DA P:0005DA 0C008F            JMP     <FINISH
2062      P:0005DB P:0005DB 0A0032  RR_SET    BSET    #ST_RRR,X:STATUS
2063      P:0005DC P:0005DC 0C008F            JMP     <FINISH
2064   
2065                                ;******************************************************************************
2066                                ; Set number of Fowler samples per frame
2067                                ;******************************************************************************
2068   
2069                                SET_NUMBER_OF_FOWLER_SAMPLES
2070      P:0005DD P:0005DD 44DB00            MOVE              X:(R3)+,X0
2071      P:0005DE P:0005DE 4C0A00            MOVE                          X0,Y:<NFS   ; Number of Fowler samples
2072      P:0005DF P:0005DF 0C008F            JMP     <FINISH
2073   
2074   
2075                                ;******************************************************************************
2076                                ; Set number of digital samples
2077                                ;******************************************************************************
2078   
2079   
2080   
2081                                SET_NUMBER_OF_DIGITAL_SAMPLES
2082      P:0005E0 P:0005E0 44DB00            MOVE              X:(R3)+,X0
2083      P:0005E1 P:0005E1 4C0B00            MOVE                          X0,Y:<NDS   ; Number of Digital samples
2084   
2085      P:0005E2 P:0005E2 200013            CLR     A
2086      P:0005E3 P:0005E3 000000            NOP
2087      P:0005E4 P:0005E4 060B40            DO      Y:<NDS,CALC_NSR
                            0005E8
2088      P:0005E6 P:0005E6 0140C0            ADD     #2048,A                           ; columns in 4 quadrants times NDS
                            000800
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timIRmisc.asm  Page 37



2089      P:0005E8 P:0005E8 000000            NOP
2090                                CALC_NSR
2091   
2092      P:0005E9 P:0005E9 5E0100            MOVE                          A,Y:<NSR    ; Number of columns
2093   
2094      P:0005EA P:0005EA 0C008F            JMP     <FINISH
2095   
2096   
2097   
2098                                ;******************************************************************************
2099                                ; Set number of clockouts
2100                                ;******************************************************************************
2101   
2102   
2103                                SET_NUMBER_OF_CLOCKOUTS
2104      P:0005EB P:0005EB 44DB00            MOVE              X:(R3)+,X0
2105      P:0005EC P:0005EC 4C0C00            MOVE                          X0,Y:<NCO   ; Number of Clockouts
2106      P:0005ED P:0005ED 0C008F            JMP     <FINISH
2107   
2108   
2109                                ;******************************************************************************
2110                                ; Reset the Array
2111                                ;******************************************************************************
2112   
2113                                CLOCKOUT_ARRAY_CMD
2114   
2115      P:0005EE P:0005EE 060C40            DO      Y:<NCO,CLK_OUT_END
                            0005F2
2116                                ;        JSR    <RESET_ARRAY            ; Clear out the FPA
2117      P:0005F0 P:0005F0 0D04B5            JSR     <INIT_PCI_IMAGE_ADDRESS
2118      P:0005F1 P:0005F1 0D02BB            JSR     <NO_READOUT
2119      P:0005F2 P:0005F2 000000            NOP
2120                                CLK_OUT_END
2121   
2122      P:0005F3 P:0005F3 0C008F            JMP     <FINISH
2123   
2124   
2125                                RESET_ARRAY_CMD
2126   
2127      P:0005F4 P:0005F4 0D0277            JSR     <RESET_ARRAY                      ; Clear out the FPA
2128      P:0005F5 P:0005F5 0C008F            JMP     <FINISH
2129   
2130                                RESET_READOUT_CMD
2131      P:0005F6 P:0005F6 0D0277            JSR     <RESET_ARRAY                      ; Clear out the FPA
2132      P:0005F7 P:0005F7 0D04B5            JSR     <INIT_PCI_IMAGE_ADDRESS
2133      P:0005F8 P:0005F8 0D0284            JSR     <READOUT                          ; Read out the FPA
2134      P:0005F9 P:0005F9 0C008F            JMP     <FINISH
2135   
2136                                READOUT_ARRAY_CMD
2137      P:0005FA P:0005FA 0D04B5            JSR     <INIT_PCI_IMAGE_ADDRESS
2138      P:0005FB P:0005FB 0D0284            JSR     <READOUT                          ; Read out the FPA
2139      P:0005FC P:0005FC 0C008F            JMP     <FINISH
2140   
2141                                ;******************************************************************************
2142                                ; Set the number of RESET frame.
2143                                ;SET_NUMBER_OF_RESET
2144                                ;       MOVE    X:(R3)+,X0
2145                                ;       MOVE    X0,Y:<NRESET
2146                                ;       JMP     <FINISH
2147   
2148   
2149                                ; Continuous readout commands
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  timIRmisc.asm  Page 38



2150                                SET_NUMBER_OF_FRAMES                                ; Number of frames to obtain
2151      P:0005FD P:0005FD 44DB00            MOVE              X:(R3)+,X0              ;   in an exposure sequence
2152      P:0005FE P:0005FE 4C0D00            MOVE                          X0,Y:<N_FRAMES
2153      P:0005FF P:0005FF 0C008F            JMP     <FINISH
2154   
2155                                SET_NUMBER_OF_FRAMES_PER_BUFFER                     ; Number of frames in each image
2156      P:000600 P:000600 44DB00            MOVE              X:(R3)+,X0              ;   buffer in the host computer
2157      P:000601 P:000601 4C1000            MOVE                          X0,Y:<N_FPB ;   system memory
2158      P:000602 P:000602 0C008F            JMP     <FINISH
2159   
2160   
2161                                 TIMBOOT_X_MEMORY
2162      000603                              EQU     @LCV(L)
2163   
2164                                ;  ****************  Setup memory tables in X: space ********************
2165   
2166                                ; Define the address in P: space where the table of constants begins
2167   
2168                                          IF      @SCP("HOST","HOST")
2169      X:000036 X:000036                   ORG     X:END_COMMAND_TABLE,X:END_COMMAND_TABLE
2170                                          ENDIF
2171   
2172                                          IF      @SCP("HOST","ROM")
2174                                          ENDIF
2175   
2176                                ; Application commands
2177      X:000036 X:000036                   DC      'PON',POWER_ON
2178      X:000038 X:000038                   DC      'POF',POWER_OFF
2179      X:00003A X:00003A                   DC      'SBL',SET_BIAS_VOLTAGES_L
2180      X:00003C X:00003C                   DC      'SBV',SET_BIAS_VOLTAGES
2181      X:00003E X:00003E                   DC      'SBH',SET_BIAS_VOLTAGES_H
2182      X:000040 X:000040                   DC      'IDL',FINISH
2183      X:000042 X:000042                   DC      'CLR',CLEAR
2184   
2185                                ; Exposure and readout control routines
2186      X:000044 X:000044                   DC      'SET',SET_EXPOSURE_TIME
2187      X:000046 X:000046                   DC      'RET',READ_EXPOSURE_TIME
2188      X:000048 X:000048                   DC      'SEX',START_EXPOSURE
2189      X:00004A X:00004A                   DC      'SRL',START_RR_LINEAR
2190      X:00004C X:00004C                   DC      'SRE',START_RR_EXP
2191      X:00004E X:00004E                   DC      'PEX',PAUSE_EXPOSURE
2192      X:000050 X:000050                   DC      'REX',RESUME_EXPOSURE
2193      X:000052 X:000052                   DC      'AEX',ABORT_EXPOSURE
2194      X:000054 X:000054                   DC      'ABR',ABORT_EXPOSURE
2195      X:000056 X:000056                   DC      'CDS',CORRELATED_DOUBLE_SAMPLE
2196      X:000058 X:000058                   DC      'RRR',SELECT_ROW_BY_ROW_RESET
2197      X:00005A X:00005A                   DC      'SFS',SET_NUMBER_OF_FOWLER_SAMPLES
2198      X:00005C X:00005C                   DC      'SDS',SET_NUMBER_OF_DIGITAL_SAMPLES
2199      X:00005E X:00005E                   DC      'SNC',SET_NUMBER_OF_CLOCKOUTS
2200      X:000060 X:000060                   DC      'COA',CLOCKOUT_ARRAY_CMD
2201      X:000062 X:000062                   DC      'RAR',RESET_ARRAY_CMD
2202      X:000064 X:000064                   DC      'RRO',RESET_READOUT_CMD
2203      X:000066 X:000066                   DC      'ROR',READOUT_ARRAY_CMD
2204   
2205                                ; Support routines
2206      X:000068 X:000068                   DC      'SBN',SET_BIAS_NUMBER
2207      X:00006A X:00006A                   DC      'SMX',SET_MUX
2208      X:00006C X:00006C                   DC      'CSW',CLR_SWS
2209      X:00006E X:00006E                   DC      'RCC',READ_CONTROLLER_CONFIGURATION
2210   
2211                                ; Continuous readout commands
2212      X:000070 X:000070                   DC      'SNF',SET_NUMBER_OF_FRAMES
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  tim.asm  Page 39



2213      X:000072 X:000072                   DC      'FPB',SET_NUMBER_OF_FRAMES_PER_BUFFER
2214   
2215                                 END_APPLICATON_COMMAND_TABLE
2216      000074                              EQU     @LCV(L)
2217   
2218                                          IF      @SCP("HOST","HOST")
2219      000026                    NUM_COM   EQU     (@LCV(R)-COM_TBL_R)/2             ; Number of boot +
2220                                                                                    ;  application commands
2221      00045C                    EXPOSING  EQU     CHK_TIM                           ; Address if exposing
2222                                 CONTINUE_READING
2223      100000                              EQU     CONT_RD                           ; Address if reading out
2224                                          ENDIF
2225   
2226                                          IF      @SCP("HOST","ROM")
2228                                          ENDIF
2229   
2230                                ; Now let's go for the timing waveform tables
2231                                          IF      @SCP("HOST","HOST")
2232      Y:000000 Y:000000                   ORG     Y:0,Y:0
2233                                          ENDIF
2234   
2235      Y:000000 Y:000000         GAIN      DC      END_APPLICATON_Y_MEMORY-@LCV(L)-1
2236   
2237      Y:000001 Y:000001         NSR       DC      12288                             ; 512 x6DS x4 for 4 Quadrants
2238      Y:000002 Y:000002         NPR       DC      1024                              ; 2048 = 2(CDS) x NFS=1 x 512
2239      Y:000003 Y:000003         NSCLR     DC      0                                 ; Not used
2240      Y:000004 Y:000004         NPCLR     DC      0                                 ; Not used
2241      Y:000005 Y:000005         DUMMY     DC      0,0                               ; Binning parameters (reserved)
2242      Y:000007 Y:000007         TST_DAT   DC      0                                 ; Temporary definition for test images
2243      Y:000008 Y:000008         CONFIG    DC      CC                                ; Controller configuration
2244      Y:000009 Y:000009         TRM_ADR   DC      0                                 ; Test RAM memory error address
2245      Y:00000A Y:00000A         NFS       DC      1                                 ; Number of Fowler samples
2246      Y:00000B Y:00000B         NDS       DC      1                                 ; Number of Digital samples
2247      Y:00000C Y:00000C         NCO       DC      0                                 ; Number of clockouts
2248   
2249                                ; Continuous readout parameters
2250      Y:00000D Y:00000D         N_FRAMES  DC      1                                 ; Total number of frames to read out
2251      Y:00000E Y:00000E         I_FRAME   DC      0                                 ; Number of frames read out so far
2252      Y:00000F Y:00000F         IBUFFER   DC      0                                 ; Number of frames read into the PCI buffer
2253      Y:000010 Y:000010         N_FPB     DC      0                                 ; Number of frames per PCI image buffer
2254   
2255                                ; Include the waveform table for the designated IR array
2256                                          INCLUDE "AladdinIII.waveforms"            ; Readout and clocking waveform file
2257                                       COMMENT *
2258   
2259                                Waveform tables for Aladdin III IR array to be used with one ARC-46 =
2260                                        8-channel video processor boards and Gen III = ARC22 = 250 MHz
2261                                        timing board and ARC-32 clock driver board.
2262                                Modified Feb. 2009 for row-by-row reset for high flux observations
2263   
2264                                        *
2265   
2266      000001                    AD        EQU     $000001                           ; Bit to start A/D conversion
2267      000002                    XFER      EQU     $000002                           ; Bit to transfer A/D counts into the A/D FI
FO
2268      00F7C0                    SXMIT     EQU     $00F7C0                           ; Transmit 32 pixels = 4 Aladdin quadrants
2269   
2270                                ; Definitions of readout variables
2271      002000                    CLK2      EQU     $002000                           ; Clock driver board lower half
2272      003000                    CLK3      EQU     $003000                           ; Clock driver board upper half
2273      000000                    VIDEO     EQU     $000000                           ; Video processor board switches
2274   
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  AladdinIII.waveforms  Page 40



2275                                ; Various delay parameters
2276      100000                    DLY0      EQU     $100000
2277      180000                    DLY1      EQU     $180000                           ; 1.0 microsec
2278      320000                    DLY2      EQU     $320000                           ; 2.0 microsec
2279      640000                    DLY4      EQU     $640000                           ; 4.0 microsec
2280      930000                    DLY6      EQU     $930000                           ; 6.0 microsec
2281   
2282      130000                    DLYA      EQU     $130000                           ; Pixel readout delay parameters
2283      040000                    DLYB      EQU     $040000
2284      C00000                    DLYG      EQU     $C00000
2285   
2286      0C0000                    XMT_DLY   EQU     $0C0000                           ; Delay per SXMIT for the fiber optic transm
itter
2287   
2288                                ; Voltages for operating the Aladdin III focal plane array. The clock driver
2289                                ;   needs to be jumpered for bipolar operation because of the output source
2290                                ;   load resistor driver, VSSOUT = +1.0
2291   
2292   
2293                                ; Voltages for operating the Aladdin III focal plane array ORIGINAL
2294                                ;CLK_HI         EQU     +0.0    ; Clock voltage low
2295                                ;CLK_LO         EQU     -5.0    ; Clock voltage low
2296                                ;VRW_LO         EQU     -4.0    ; VrowON low voltage
2297                                ;VRST_HI                EQU     -3.5    ; VrstG high voltage
2298                                ;VRST_LO                EQU     -5.8    ; VrstG low voltage
2299                                ;ZERO           EQU      0.0    ; Unused clock driver voltage
2300      000002                    ADREF     EQU     +2                                ; A/D converter voltage reference
2301      00000D                    Vmax      EQU     13                                ; Maximum clock driver voltage, clock board
2302      2.600000E+001             Vmax1     EQU     2.0*Vmax
2303      7.500000E+000             Vmax2     EQU     7.5                               ; 2 x Maximum clock driver voltage
2304      1.500000E+001             Vmax3     EQU     2.0*Vmax2
2305   
2306                                ; Voltages for operating the Aladdin III focal plane array TWEAKED BY LUC AS NASA IRTF
2307      -5.000000E-001            CLK_HI    EQU     -0.5                              ; Clock voltage high
2308      -5.800000E+000            CLK_LO    EQU     -5.8                              ; Clock voltage low
2309      -4.000000E+000            VRW_LO    EQU     -4.0                              ; VrowON low voltage
2310      -3.500000E+000            VRST_HI   EQU     -3.5                              ; VrstG high voltage
2311      -5.800000E+000            VRST_LO   EQU     -5.8                              ; VrstG low voltage
2312      0.000000E+000             ZERO      EQU     0.0                               ; Unused clock driver voltage
2313   
2314   
2315                                ; Define switch state bits for CLK2 = bottom of clock board
2316      000001                    SSYNC     EQU     1                                 ; Slow Sync             Pin #1
2317      000002                    S1        EQU     2                                 ; Slow phase 1          Pin #2
2318      000004                    S2        EQU     4                                 ; Slow phase 2          Pin #3
2319      000008                    SOE       EQU     8                                 ; Odd/Even row select   Pin #4
2320      000010                    RDES      EQU     $10                               ; Row deselect          Pin #5
2321      000020                    VRSTOFF   EQU     $20                               ; Global reset = VrstG  Pin #6
2322      000040                    VRSTR     EQU     $40                               ; Row reset bias        Pin #7
2323      000080                    VROWON    EQU     $80                               ; Bias to row enable    Pin #8
2324   
2325                                ; Define switch state bits for CLK3 = top of clock board
2326      000001                    FSYNC     EQU     1                                 ; Fast sync             Pin #13
2327      000002                    F1        EQU     2                                 ; Fast phase 1          Pin #14
2328      000004                    F2        EQU     4                                 ; Fast phase 2          Pin #15
2329   
2330                                ; Aladdin III DC bias voltage definition
2331                                ; Per Peter Onaka, "you shouldn't forward bias the InSb = VDDUC should always be more negative t
han VDET."
2332                                ; FIXME
2333      -2.800000E+000            VGGCL     EQU     -2.8                              ; p16 Board2 Column Clamp Clock, was -3.1V b
ut UIST sets it to 0V and IRTF defines it at -3.1V but never switches it
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  AladdinIII.waveforms  Page 41



2334      -2.800000E+000            VDDCL     EQU     -2.8                              ; p17 Board2 Column Clamp Bias  was -3.6V no
w as UIST
2335      -4.000000E+000            VDDUC     EQU     -4.0                              ; p33 Board1 Negative Unit Cell Bias set to 
same as VdetCom for warm testing else -4V
2336      -5.950000E+000            VNROW     EQU     -5.95                             ; p31 Board2 Negative row supply
2337      -5.950000E+000            VNCOL     EQU     -5.95                             ; p15 Board2 Negative column supply
2338      -1.500000E+000            VDDOUT    EQU     -1.5                              ; p17 Board1 Drain voltage for drivers  was 
-1.2 now as UIST
2339      -3.200000E+000            VDETCOM_L EQU     -3.2                              ; p32 Board1 Detector Common not for MUX sho
uld be same as VdduC for warm testing else -3.4V
2340      -3.400000E+000            VDETCOM   EQU     -3.4                              ; p32 Board1 Detector Common not for MUX sho
uld be same as VdduC for warm testing else -3.4V
2341      -3.600000E+000            VDETCOM_H EQU     -3.6                              ; p32 Board1 Detector Common not for MUX sho
uld be same as VdduC for warm testing else -3.4V
2342      -2.000000E+000            IREF      EQU     -2.0                              ; p16 Board1 Reference current for Iidle and
 Islew
2343      4.500000E+000             VSSOUT    EQU     +4.5                              ; Source follower load voltage
2344      -5.000000E-001            VROWOFF   EQU     -0.5                              ; p33 Board2 Applied to SF transistor gate M
2 when row is not selected
2345   
2346                                ;V1             EQU -0.8                ; Voltages to test the video boards and firmware
2347                                ;V2             EQU     -0.9            ; Set in conjunction with offset and gain settings
2348                                ;V3             EQU     -1                      ; for testing of each video board with the jumpe
r connector
2349                                ;V4             EQU     -1.2
2350                                ;V5             EQU     -1.4
2351                                ;V6             EQU     -1.5
2352                                ;V7             EQU     +5.0
2353   
2354                                ; Video offset variable
2355                                ;OFFSET EQU     $760            ; for operation of the Aladdin III array -
2356                                                                                    ;   64k DN at -1.0 volts input => full well
2357                                                                                    ;    0k DN at -2.0 volts input => dark
2358                                                                                    ; Increase offset to lower image counts
2359   
2360      0007B0                    OFFSETB1  EQU     $7B0                              ; with slow int gain $760 gives 4kADU dark w
ith fast 8A0
2361      0007B0                    OFFSETB2  EQU     $7B0                              ; with fast int gain
2362      0007B0                    OFFSETB3  EQU     $7B0                              ; with fast int gain
2363      0007B0                    OFFSETB4  EQU     $7B0                              ; with fast int gain
2364   
2365      0007B0                    OFFSET0   EQU     OFFSETB1
2366      0007B0                    OFFSET1   EQU     OFFSETB1
2367      0007B0                    OFFSET2   EQU     OFFSETB1
2368      0007B0                    OFFSET3   EQU     OFFSETB1
2369      0007B0                    OFFSET4   EQU     OFFSETB1
2370      0007B0                    OFFSET5   EQU     OFFSETB1
2371      0007B0                    OFFSET6   EQU     OFFSETB1
2372      0007B0                    OFFSET7   EQU     OFFSETB1
2373   
2374      0007B0                    OFFSET8   EQU     OFFSETB2
2375      0007B0                    OFFSET9   EQU     OFFSETB2
2376      0007B0                    OFFSET10  EQU     OFFSETB2
2377      0007B0                    OFFSET11  EQU     OFFSETB2
2378      0007B0                    OFFSET12  EQU     OFFSETB2
2379      0007B0                    OFFSET13  EQU     OFFSETB2
2380      0007B0                    OFFSET14  EQU     OFFSETB2
2381      0007B0                    OFFSET15  EQU     OFFSETB2
2382   
2383      0007B0                    OFFSET16  EQU     OFFSETB3
2384      0007B0                    OFFSET17  EQU     OFFSETB3
2385      0007B0                    OFFSET18  EQU     OFFSETB3
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  AladdinIII.waveforms  Page 42



2386      0007B0                    OFFSET19  EQU     OFFSETB3
2387      0007B0                    OFFSET20  EQU     OFFSETB3
2388      0007B0                    OFFSET21  EQU     OFFSETB3
2389      0007B0                    OFFSET22  EQU     OFFSETB3
2390      0007B0                    OFFSET23  EQU     OFFSETB3
2391   
2392      0007B0                    OFFSET24  EQU     OFFSETB4
2393      0007B0                    OFFSET25  EQU     OFFSETB4
2394      0007B0                    OFFSET26  EQU     OFFSETB4
2395      0007B0                    OFFSET27  EQU     OFFSETB4
2396      0007B0                    OFFSET28  EQU     OFFSETB4
2397      0007B0                    OFFSET29  EQU     OFFSETB4
2398      0007B0                    OFFSET30  EQU     OFFSETB4
2399      0007B0                    OFFSET31  EQU     OFFSETB4
2400   
2401                                ; Copy of the clocking bit definition for easy reference
2402                                ;       DC      CLK2+DELAY+SSYNC+S1+S2+SOE+RDES+VRSTOFF+VRSTR+VROWON
2403                                ;       DC      CLK3+DELAY+FSYNC+F1+F2
2404   
2405   
2406   
2407      Y:000011 Y:000011         CLOCKS    DC      END_CLOCKS-CLOCKS-1
2408      Y:000012 Y:000012                   DC      $2A0080                           ; DAC = unbuffered mode
2409      Y:000013 Y:000013                   DC      $200100+@CVI(((CLK_HI+Vmax)/Vmax)*255) ; Pin #1, SSYNC
2410      Y:000014 Y:000014                   DC      $200200+@CVI(((CLK_LO+Vmax)/Vmax)*255)
2411      Y:000015 Y:000015                   DC      $200400+@CVI(((CLK_HI+Vmax)/Vmax)*255) ; Pin #2, S1
2412      Y:000016 Y:000016                   DC      $200800+@CVI(((CLK_LO+Vmax)/Vmax)*255)
2413      Y:000017 Y:000017                   DC      $202000+@CVI(((CLK_HI+Vmax)/Vmax)*255) ; Pin #3, S2
2414      Y:000018 Y:000018                   DC      $204000+@CVI(((CLK_LO+Vmax)/Vmax)*255)
2415      Y:000019 Y:000019                   DC      $208000+@CVI(((CLK_HI+Vmax)/Vmax)*255) ; Pin #4, SOE
2416      Y:00001A Y:00001A                   DC      $210000+@CVI(((CLK_LO+Vmax)/Vmax)*255)
2417      Y:00001B Y:00001B                   DC      $220100+@CVI(((CLK_HI+Vmax)/Vmax)*255) ; Pin #5, RDES
2418      Y:00001C Y:00001C                   DC      $220200+@CVI(((CLK_LO+Vmax)/Vmax)*255)
2419      Y:00001D Y:00001D                   DC      $220400+@CVI(((VRST_HI+Vmax)/Vmax)*255) ; Pin #6, VRSTOFF
2420      Y:00001E Y:00001E                   DC      $220800+@CVI(((VRST_LO+Vmax)/Vmax)*255) ;   = VrstG
2421      Y:00001F Y:00001F                   DC      $222000+@CVI(((VRST_HI+Vmax)/Vmax)*255) ; Pin #7, VRSTR
2422      Y:000020 Y:000020                   DC      $224000+@CVI(((VRST_LO+Vmax)/Vmax)*255)
2423      Y:000021 Y:000021                   DC      $228000+@CVI(((CLK_HI+Vmax)/Vmax)*255) ; Pin #8, VROWON
2424      Y:000022 Y:000022                   DC      $230000+@CVI(((VRW_LO+Vmax)/Vmax)*255)
2425      Y:000023 Y:000023                   DC      $240100+@CVI(((ZERO+Vmax)/Vmax)*255) ; Pin #9, Unused
2426      Y:000024 Y:000024                   DC      $240200+@CVI(((ZERO+Vmax)/Vmax)*255)
2427      Y:000025 Y:000025                   DC      $240400+@CVI(((ZERO+Vmax)/Vmax)*255) ; Pin #10, Unused
2428      Y:000026 Y:000026                   DC      $240800+@CVI(((ZERO+Vmax)/Vmax)*255)
2429      Y:000027 Y:000027                   DC      $242000+@CVI(((ZERO+Vmax)/Vmax)*255) ; Pin #11, Unused
2430      Y:000028 Y:000028                   DC      $244000+@CVI(((ZERO+Vmax)/Vmax)*255)
2431      Y:000029 Y:000029                   DC      $248000+@CVI(((ZERO+Vmax)/Vmax)*255) ; Pin #12, Unused
2432      Y:00002A Y:00002A                   DC      $250000+@CVI(((ZERO+Vmax)/Vmax)*255)
2433   
2434                                ; Upper bank
2435      Y:00002B Y:00002B                   DC      $260100+@CVI(((CLK_HI+Vmax)/Vmax)*255) ; Pin #13, FSYNC
2436      Y:00002C Y:00002C                   DC      $260200+@CVI(((CLK_LO+Vmax)/Vmax)*255)
2437      Y:00002D Y:00002D                   DC      $260400+@CVI(((CLK_HI+Vmax)/Vmax)*255) ; Pin #14, F1
2438      Y:00002E Y:00002E                   DC      $260800+@CVI(((CLK_LO+Vmax)/Vmax)*255)
2439      Y:00002F Y:00002F                   DC      $262000+@CVI(((CLK_HI+Vmax)/Vmax)*255) ; Pin #15, F2
2440      Y:000030 Y:000030                   DC      $264000+@CVI(((CLK_LO+Vmax)/Vmax)*255)
2441      Y:000031 Y:000031                   DC      $268000+@CVI(((ZERO+Vmax)/Vmax)*255)
2442      Y:000032 Y:000032                   DC      $270000+@CVI(((ZERO+Vmax)/Vmax)*255)
2443      Y:000033 Y:000033                   DC      $280100+@CVI(((ZERO+Vmax)/Vmax)*255)
2444      Y:000034 Y:000034                   DC      $280200+@CVI(((ZERO+Vmax)/Vmax)*255)
2445      Y:000035 Y:000035                   DC      $280400+@CVI(((ZERO+Vmax)/Vmax)*255)
2446      Y:000036 Y:000036                   DC      $280800+@CVI(((ZERO+Vmax)/Vmax)*255)
2447      Y:000037 Y:000037                   DC      $282000+@CVI(((ZERO+Vmax)/Vmax)*255)
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  AladdinIII.waveforms  Page 43



2448      Y:000038 Y:000038                   DC      $284000+@CVI(((ZERO+Vmax)/Vmax)*255)
2449      Y:000039 Y:000039                   DC      $288000+@CVI(((ZERO+Vmax)/Vmax)*255)
2450      Y:00003A Y:00003A                   DC      $290000+@CVI(((ZERO+Vmax)/Vmax)*255)
2451      Y:00003B Y:00003B                   DC      $2A0100+@CVI(((ZERO+Vmax)/Vmax)*255)
2452      Y:00003C Y:00003C                   DC      $2A0200+@CVI(((ZERO+Vmax)/Vmax)*255)
2453      Y:00003D Y:00003D                   DC      $2A0400+@CVI(((ZERO+Vmax)/Vmax)*255)
2454      Y:00003E Y:00003E                   DC      $2A0800+@CVI(((ZERO+Vmax)/Vmax)*255)
2455      Y:00003F Y:00003F                   DC      $2A2000+@CVI(((ZERO+Vmax)/Vmax)*255)
2456      Y:000040 Y:000040                   DC      $2A4000+@CVI(((ZERO+Vmax)/Vmax)*255)
2457      Y:000041 Y:000041                   DC      $2A8000+@CVI(((ZERO+Vmax)/Vmax)*255)
2458      Y:000042 Y:000042                   DC      $2B0000+@CVI(((ZERO+Vmax)/Vmax)*255)
2459                                END_CLOCKS
2460   
2461                                ; Video offset assignments
2462      Y:000043 Y:000043         BIASES_L  DC      END_BIASES_L-BIASES_L-1
2463   
2464                                ; Integrator gain and a few other things
2465                                ;       DC      $0c3001                 ; Integrate 1, R = 4k, Low gain, Slow
2466                                ;       DC      $0c3000                 ; Integrate 2, High gain
2467      Y:000044 Y:000044                   DC      $0c3000                           ; Integrate 2, High gain
2468      Y:000045 Y:000045                   DC      $1c3000                           ; Integrate 2, High gain
2469      Y:000046 Y:000046                   DC      $2c3000                           ; Integrate 2, High gain
2470      Y:000047 Y:000047                   DC      $3c3000                           ; Integrate 2, High gain
2471      Y:000048 Y:000048                   DC      $0c1000                           ; Reset image data FIFOs
2472      Y:000049 Y:000049                   DC      $0c0000+@CVI((ADREF+5.0)/10.0*4095)
2473      Y:00004A Y:00004A                   DC      $1c0000+@CVI((ADREF+5.0)/10.0*4095)
2474      Y:00004B Y:00004B                   DC      $2c0000+@CVI((ADREF+5.0)/10.0*4095)
2475      Y:00004C Y:00004C                   DC      $3c0000+@CVI((ADREF+5.0)/10.0*4095)
2476   
2477                                ; Video processor offset voltages to bring the video withing range of the A/D ARC46#1
2478      Y:00004D Y:00004D                   DC      $0e0000+OFFSET0                   ; Output #0
2479      Y:00004E Y:00004E                   DC      $0e4000+OFFSET1                   ; Output #1
2480      Y:00004F Y:00004F                   DC      $0e8000+OFFSET2                   ; Output #2
2481      Y:000050 Y:000050                   DC      $0ec000+OFFSET3                   ; Output #3
2482      Y:000051 Y:000051                   DC      $0f0000+OFFSET4                   ; Output #4
2483      Y:000052 Y:000052                   DC      $0f4000+OFFSET5                   ; Output #5
2484      Y:000053 Y:000053                   DC      $0f8000+OFFSET6                   ; Output #6
2485      Y:000054 Y:000054                   DC      $0fc000+OFFSET7                   ; Output #7
2486   
2487                                ; Video processor offset voltages to bring the video withing range of the A/D ARC46#2
2488      Y:000055 Y:000055                   DC      $1e0000+OFFSET8                   ; Output #0
2489      Y:000056 Y:000056                   DC      $1e4000+OFFSET9                   ; Output #1
2490      Y:000057 Y:000057                   DC      $1e8000+OFFSET10                  ; Output #2
2491      Y:000058 Y:000058                   DC      $1ec000+OFFSET11                  ; Output #3
2492      Y:000059 Y:000059                   DC      $1f0000+OFFSET12                  ; Output #4
2493      Y:00005A Y:00005A                   DC      $1f4000+OFFSET13                  ; Output #5
2494      Y:00005B Y:00005B                   DC      $1f8000+OFFSET14                  ; Output #6
2495      Y:00005C Y:00005C                   DC      $1fc000+OFFSET15                  ; Output #7
2496   
2497                                ; Video processor offset voltages to bring the video withing range of the A/D ARC46#3
2498      Y:00005D Y:00005D                   DC      $2e0000+OFFSET16                  ; Output #0
2499      Y:00005E Y:00005E                   DC      $2e4000+OFFSET17                  ; Output #1
2500      Y:00005F Y:00005F                   DC      $2e8000+OFFSET18                  ; Output #2
2501      Y:000060 Y:000060                   DC      $2ec000+OFFSET19                  ; Output #3
2502      Y:000061 Y:000061                   DC      $2f0000+OFFSET20                  ; Output #4
2503      Y:000062 Y:000062                   DC      $2f4000+OFFSET21                  ; Output #5
2504      Y:000063 Y:000063                   DC      $2f8000+OFFSET22                  ; Output #6
2505      Y:000064 Y:000064                   DC      $2fc000+OFFSET23                  ; Output #7
2506   
2507                                ; Video processor offset voltages to bring the video withing range of the A/D ARC46#4
2508      Y:000065 Y:000065                   DC      $3e0000+OFFSET24                  ; Output #0
2509      Y:000066 Y:000066                   DC      $3e4000+OFFSET25                  ; Output #1
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  AladdinIII.waveforms  Page 44



2510      Y:000067 Y:000067                   DC      $3e8000+OFFSET26                  ; Output #2
2511      Y:000068 Y:000068                   DC      $3ec000+OFFSET27                  ; Output #3
2512      Y:000069 Y:000069                   DC      $3f0000+OFFSET28                  ; Output #4
2513      Y:00006A Y:00006A                   DC      $3f4000+OFFSET29                  ; Output #5
2514      Y:00006B Y:00006B                   DC      $3f8000+OFFSET30                  ; Output #6
2515      Y:00006C Y:00006C                   DC      $3fc000+OFFSET31                  ; Output #7
2516   
2517   
2518                                ; Note that BIAS BO1(p17) and BO2(p33) should be used for higher currents biasses because
2519                                ; they have 100 ohm filtering resistors (R345/350) , versus 1k on the other pins.
2520                                ; Video board #1, Bipolar -7.5 to +7.5 volts supplies
2521      Y:00006D Y:00006D                   DC      $0c4000+@CVI((VDDOUT+Vmax2)/Vmax3*4095) ; Pin #17 VDDOUT
2522      Y:00006E Y:00006E                   DC      $0c8000+@CVI((VDDUC+Vmax2)/Vmax3*4095) ; Pin #33 VDDUC
2523      Y:00006F Y:00006F                   DC      $0cc000+@CVI((IREF+Vmax2)/Vmax3*4095) ; Pin #16 IREF
2524      Y:000070 Y:000070                   DC      $0d0000+@CVI((VDETCOM_L+Vmax2)/Vmax3*4095) ; Pin #32 VDETCOM
2525      Y:000071 Y:000071                   DC      $0d4000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #15 NC
2526      Y:000072 Y:000072                   DC      $0d8000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #31 NC
2527      Y:000073 Y:000073                   DC      $0dc000+@CVI((VSSOUT+Vmax2)/Vmax3*4095) ; Pin #14 NC but provides output sourc
e follower source voltage = 5V
2528   
2529                                ; Video board #2
2530      Y:000074 Y:000074                   DC      $1c4000+@CVI((VDDCL+Vmax2)/Vmax3*4095) ; Pin #17 VDDCL
2531      Y:000075 Y:000075                   DC      $1c8000+@CVI((VROWOFF+Vmax2)/Vmax3*4095) ; Pin #33 VROWOFF
2532      Y:000076 Y:000076                   DC      $1cc000+@CVI((VGGCL+Vmax2)/Vmax3*4095) ; Pin #16 VGGCL
2533      Y:000077 Y:000077                   DC      $1d0000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #32 NC
2534      Y:000078 Y:000078                   DC      $1d4000+@CVI((VNCOL+Vmax2)/Vmax3*4095) ; Pin #15 VNCOL
2535      Y:000079 Y:000079                   DC      $1d8000+@CVI((VNROW+Vmax2)/Vmax3*4095) ; Pin #31 VNROW
2536      Y:00007A Y:00007A                   DC      $1dc000+@CVI((VSSOUT+Vmax2)/Vmax3*4095) ; Pin #14 NC but provides output sourc
e follower source voltage = 5V
2537   
2538                                ; Video board #3, Bipolar -7.5 to +7.5 volts supplies
2539      Y:00007B Y:00007B                   DC      $2c4000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #17 NC
2540      Y:00007C Y:00007C                   DC      $2c8000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #33 NC
2541      Y:00007D Y:00007D                   DC      $2cc000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #16 NC
2542      Y:00007E Y:00007E                   DC      $2d0000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #32 NC
2543      Y:00007F Y:00007F                   DC      $2d4000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #15 NC
2544      Y:000080 Y:000080                   DC      $2d8000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #31 NC
2545      Y:000081 Y:000081                   DC      $2dc000+@CVI((VSSOUT+Vmax2)/Vmax3*4095) ; Pin #14 NC but provides output sourc
e follower source voltage = 5V
2546   
2547                                ; Video board #4
2548      Y:000082 Y:000082                   DC      $3c4000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #17 NC
2549      Y:000083 Y:000083                   DC      $3c8000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #33 NC
2550      Y:000084 Y:000084                   DC      $3cc000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #16 NC
2551      Y:000085 Y:000085                   DC      $3d0000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #32 NC
2552      Y:000086 Y:000086                   DC      $3d4000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #15 NC
2553      Y:000087 Y:000087                   DC      $3d8000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #31 NC
2554      Y:000088 Y:000088                   DC      $3dc000+@CVI((VSSOUT+Vmax2)/Vmax3*4095) ; Pin #14 NC but provides output sourc
e follower source voltage = 5V
2555   
2556                                END_BIASES_L
2557   
2558                                ; Video offset assignments
2559      Y:000089 Y:000089         BIASES_H  DC      END_BIASES_H-BIASES_H-1
2560   
2561   
2562                                ; Integrator gain and a few other things
2563                                ;       DC      $0c3001                 ; Integrate 1, R = 4k, Low gain, Slow
2564                                ;       DC      $0c3000                 ; Integrate 2, High gain
2565      Y:00008A Y:00008A                   DC      $0c3000                           ; Integrate 2, High gain
2566      Y:00008B Y:00008B                   DC      $1c3000                           ; Integrate 2, High gain
2567      Y:00008C Y:00008C                   DC      $2c3000                           ; Integrate 2, High gain
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  AladdinIII.waveforms  Page 45



2568      Y:00008D Y:00008D                   DC      $3c3000                           ; Integrate 2, High gain
2569      Y:00008E Y:00008E                   DC      $0c1000                           ; Reset image data FIFOs
2570      Y:00008F Y:00008F                   DC      $0c0000+@CVI((ADREF+5.0)/10.0*4095)
2571      Y:000090 Y:000090                   DC      $1c0000+@CVI((ADREF+5.0)/10.0*4095)
2572      Y:000091 Y:000091                   DC      $2c0000+@CVI((ADREF+5.0)/10.0*4095)
2573      Y:000092 Y:000092                   DC      $3c0000+@CVI((ADREF+5.0)/10.0*4095)
2574   
2575                                ; Video processor offset voltages to bring the video withing range of the A/D ARC46#1
2576      Y:000093 Y:000093                   DC      $0e0000+OFFSET0                   ; Output #0
2577      Y:000094 Y:000094                   DC      $0e4000+OFFSET1                   ; Output #1
2578      Y:000095 Y:000095                   DC      $0e8000+OFFSET2                   ; Output #2
2579      Y:000096 Y:000096                   DC      $0ec000+OFFSET3                   ; Output #3
2580      Y:000097 Y:000097                   DC      $0f0000+OFFSET4                   ; Output #4
2581      Y:000098 Y:000098                   DC      $0f4000+OFFSET5                   ; Output #5
2582      Y:000099 Y:000099                   DC      $0f8000+OFFSET6                   ; Output #6
2583      Y:00009A Y:00009A                   DC      $0fc000+OFFSET7                   ; Output #7
2584   
2585                                ; Video processor offset voltages to bring the video withing range of the A/D ARC46#2
2586      Y:00009B Y:00009B                   DC      $1e0000+OFFSET8                   ; Output #0
2587      Y:00009C Y:00009C                   DC      $1e4000+OFFSET9                   ; Output #1
2588      Y:00009D Y:00009D                   DC      $1e8000+OFFSET10                  ; Output #2
2589      Y:00009E Y:00009E                   DC      $1ec000+OFFSET11                  ; Output #3
2590      Y:00009F Y:00009F                   DC      $1f0000+OFFSET12                  ; Output #4
2591      Y:0000A0 Y:0000A0                   DC      $1f4000+OFFSET13                  ; Output #5
2592      Y:0000A1 Y:0000A1                   DC      $1f8000+OFFSET14                  ; Output #6
2593      Y:0000A2 Y:0000A2                   DC      $1fc000+OFFSET15                  ; Output #7
2594   
2595                                ; Video processor offset voltages to bring the video withing range of the A/D ARC46#3
2596      Y:0000A3 Y:0000A3                   DC      $2e0000+OFFSET16                  ; Output #0
2597      Y:0000A4 Y:0000A4                   DC      $2e4000+OFFSET17                  ; Output #1
2598      Y:0000A5 Y:0000A5                   DC      $2e8000+OFFSET18                  ; Output #2
2599      Y:0000A6 Y:0000A6                   DC      $2ec000+OFFSET19                  ; Output #3
2600      Y:0000A7 Y:0000A7                   DC      $2f0000+OFFSET20                  ; Output #4
2601      Y:0000A8 Y:0000A8                   DC      $2f4000+OFFSET21                  ; Output #5
2602      Y:0000A9 Y:0000A9                   DC      $2f8000+OFFSET22                  ; Output #6
2603      Y:0000AA Y:0000AA                   DC      $2fc000+OFFSET23                  ; Output #7
2604   
2605                                ; Video processor offset voltages to bring the video withing range of the A/D ARC46#4
2606      Y:0000AB Y:0000AB                   DC      $3e0000+OFFSET24                  ; Output #0
2607      Y:0000AC Y:0000AC                   DC      $3e4000+OFFSET25                  ; Output #1
2608      Y:0000AD Y:0000AD                   DC      $3e8000+OFFSET26                  ; Output #2
2609      Y:0000AE Y:0000AE                   DC      $3ec000+OFFSET27                  ; Output #3
2610      Y:0000AF Y:0000AF                   DC      $3f0000+OFFSET28                  ; Output #4
2611      Y:0000B0 Y:0000B0                   DC      $3f4000+OFFSET29                  ; Output #5
2612      Y:0000B1 Y:0000B1                   DC      $3f8000+OFFSET30                  ; Output #6
2613      Y:0000B2 Y:0000B2                   DC      $3fc000+OFFSET31                  ; Output #7
2614   
2615   
2616                                ; Note that BIAS BO1(p17) and BO2(p33) should be used for higher currents biasses because
2617                                ; they have 100 ohm filtering resistors (R345/350) , versus 1k on the other pins.
2618                                ; Video board #1, Bipolar -7.5 to +7.5 volts supplies
2619      Y:0000B3 Y:0000B3                   DC      $0c4000+@CVI((VDDOUT+Vmax2)/Vmax3*4095) ; Pin #17 VDDOUT
2620      Y:0000B4 Y:0000B4                   DC      $0c8000+@CVI((VDDUC+Vmax2)/Vmax3*4095) ; Pin #33 VDDUC
2621      Y:0000B5 Y:0000B5                   DC      $0cc000+@CVI((IREF+Vmax2)/Vmax3*4095) ; Pin #16 IREF
2622      Y:0000B6 Y:0000B6                   DC      $0d0000+@CVI((VDETCOM_H+Vmax2)/Vmax3*4095) ; Pin #32 VDETCOM
2623      Y:0000B7 Y:0000B7                   DC      $0d4000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #15 NC
2624      Y:0000B8 Y:0000B8                   DC      $0d8000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #31 NC
2625      Y:0000B9 Y:0000B9                   DC      $0dc000+@CVI((VSSOUT+Vmax2)/Vmax3*4095) ; Pin #14 NC but provides output sourc
e follower source voltage = 5V
2626   
2627                                ; Video board #2
2628      Y:0000BA Y:0000BA                   DC      $1c4000+@CVI((VDDCL+Vmax2)/Vmax3*4095) ; Pin #17 VDDCL
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  AladdinIII.waveforms  Page 46



2629      Y:0000BB Y:0000BB                   DC      $1c8000+@CVI((VROWOFF+Vmax2)/Vmax3*4095) ; Pin #33 VROWOFF
2630      Y:0000BC Y:0000BC                   DC      $1cc000+@CVI((VGGCL+Vmax2)/Vmax3*4095) ; Pin #16 VGGCL
2631      Y:0000BD Y:0000BD                   DC      $1d0000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #32 NC
2632      Y:0000BE Y:0000BE                   DC      $1d4000+@CVI((VNCOL+Vmax2)/Vmax3*4095) ; Pin #15 VNCOL
2633      Y:0000BF Y:0000BF                   DC      $1d8000+@CVI((VNROW+Vmax2)/Vmax3*4095) ; Pin #31 VNROW
2634      Y:0000C0 Y:0000C0                   DC      $1dc000+@CVI((VSSOUT+Vmax2)/Vmax3*4095) ; Pin #14 NC but provides output sourc
e follower source voltage = 5V
2635   
2636                                ; Video board #3, Bipolar -7.5 to +7.5 volts supplies
2637      Y:0000C1 Y:0000C1                   DC      $2c4000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #17 NC
2638      Y:0000C2 Y:0000C2                   DC      $2c8000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #33 NC
2639      Y:0000C3 Y:0000C3                   DC      $2cc000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #16 NC
2640      Y:0000C4 Y:0000C4                   DC      $2d0000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #32 NC
2641      Y:0000C5 Y:0000C5                   DC      $2d4000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #15 NC
2642      Y:0000C6 Y:0000C6                   DC      $2d8000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #31 NC
2643      Y:0000C7 Y:0000C7                   DC      $2dc000+@CVI((VSSOUT+Vmax2)/Vmax3*4095) ; Pin #14 NC but provides output sourc
e follower source voltage = 5V
2644   
2645                                ; Video board #4
2646      Y:0000C8 Y:0000C8                   DC      $3c4000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #17 NC
2647      Y:0000C9 Y:0000C9                   DC      $3c8000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #33 NC
2648      Y:0000CA Y:0000CA                   DC      $3cc000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #16 NC
2649      Y:0000CB Y:0000CB                   DC      $3d0000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #32 NC
2650      Y:0000CC Y:0000CC                   DC      $3d4000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #15 NC
2651      Y:0000CD Y:0000CD                   DC      $3d8000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #31 NC
2652      Y:0000CE Y:0000CE                   DC      $3dc000+@CVI((VSSOUT+Vmax2)/Vmax3*4095) ; Pin #14 NC but provides output sourc
e follower source voltage = 5V
2653   
2654                                END_BIASES_H
2655   
2656   
2657                                ; Video offset assignments
2658      Y:0000CF Y:0000CF         BIASES    DC      END_BIASES-BIASES-1
2659   
2660                                ; Integrator gain and a few other things
2661                                ;       DC      $0c3001                 ; Integrate 1, R = 4k, Low gain, Slow
2662                                ;       DC      $0c3000                 ; Integrate 2, High gain
2663      Y:0000D0 Y:0000D0                   DC      $0c3000                           ; Integrate 2, High gain
2664      Y:0000D1 Y:0000D1                   DC      $1c3000                           ; Integrate 2, High gain
2665      Y:0000D2 Y:0000D2                   DC      $2c3000                           ; Integrate 2, High gain
2666      Y:0000D3 Y:0000D3                   DC      $3c3000                           ; Integrate 2, High gain
2667      Y:0000D4 Y:0000D4                   DC      $0c1000                           ; Reset image data FIFOs
2668      Y:0000D5 Y:0000D5                   DC      $0c0000+@CVI((ADREF+5.0)/10.0*4095)
2669      Y:0000D6 Y:0000D6                   DC      $1c0000+@CVI((ADREF+5.0)/10.0*4095)
2670      Y:0000D7 Y:0000D7                   DC      $2c0000+@CVI((ADREF+5.0)/10.0*4095)
2671      Y:0000D8 Y:0000D8                   DC      $3c0000+@CVI((ADREF+5.0)/10.0*4095)
2672   
2673                                ; Video processor offset voltages to bring the video withing range of the A/D ARC46#1
2674      Y:0000D9 Y:0000D9                   DC      $0e0000+OFFSET0                   ; Output #0
2675      Y:0000DA Y:0000DA                   DC      $0e4000+OFFSET1                   ; Output #1
2676      Y:0000DB Y:0000DB                   DC      $0e8000+OFFSET2                   ; Output #2
2677      Y:0000DC Y:0000DC                   DC      $0ec000+OFFSET3                   ; Output #3
2678      Y:0000DD Y:0000DD                   DC      $0f0000+OFFSET4                   ; Output #4
2679      Y:0000DE Y:0000DE                   DC      $0f4000+OFFSET5                   ; Output #5
2680      Y:0000DF Y:0000DF                   DC      $0f8000+OFFSET6                   ; Output #6
2681      Y:0000E0 Y:0000E0                   DC      $0fc000+OFFSET7                   ; Output #7
2682   
2683                                ; Video processor offset voltages to bring the video withing range of the A/D ARC46#2
2684      Y:0000E1 Y:0000E1                   DC      $1e0000+OFFSET8                   ; Output #0
2685      Y:0000E2 Y:0000E2                   DC      $1e4000+OFFSET9                   ; Output #1
2686      Y:0000E3 Y:0000E3                   DC      $1e8000+OFFSET10                  ; Output #2
2687      Y:0000E4 Y:0000E4                   DC      $1ec000+OFFSET11                  ; Output #3
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  AladdinIII.waveforms  Page 47



2688      Y:0000E5 Y:0000E5                   DC      $1f0000+OFFSET12                  ; Output #4
2689      Y:0000E6 Y:0000E6                   DC      $1f4000+OFFSET13                  ; Output #5
2690      Y:0000E7 Y:0000E7                   DC      $1f8000+OFFSET14                  ; Output #6
2691      Y:0000E8 Y:0000E8                   DC      $1fc000+OFFSET15                  ; Output #7
2692   
2693                                ; Video processor offset voltages to bring the video withing range of the A/D ARC46#3
2694      Y:0000E9 Y:0000E9                   DC      $2e0000+OFFSET16                  ; Output #0
2695      Y:0000EA Y:0000EA                   DC      $2e4000+OFFSET17                  ; Output #1
2696      Y:0000EB Y:0000EB                   DC      $2e8000+OFFSET18                  ; Output #2
2697      Y:0000EC Y:0000EC                   DC      $2ec000+OFFSET19                  ; Output #3
2698      Y:0000ED Y:0000ED                   DC      $2f0000+OFFSET20                  ; Output #4
2699      Y:0000EE Y:0000EE                   DC      $2f4000+OFFSET21                  ; Output #5
2700      Y:0000EF Y:0000EF                   DC      $2f8000+OFFSET22                  ; Output #6
2701      Y:0000F0 Y:0000F0                   DC      $2fc000+OFFSET23                  ; Output #7
2702   
2703                                ; Video processor offset voltages to bring the video withing range of the A/D ARC46#4
2704      Y:0000F1 Y:0000F1                   DC      $3e0000+OFFSET24                  ; Output #0
2705      Y:0000F2 Y:0000F2                   DC      $3e4000+OFFSET25                  ; Output #1
2706      Y:0000F3 Y:0000F3                   DC      $3e8000+OFFSET26                  ; Output #2
2707      Y:0000F4 Y:0000F4                   DC      $3ec000+OFFSET27                  ; Output #3
2708      Y:0000F5 Y:0000F5                   DC      $3f0000+OFFSET28                  ; Output #4
2709      Y:0000F6 Y:0000F6                   DC      $3f4000+OFFSET29                  ; Output #5
2710      Y:0000F7 Y:0000F7                   DC      $3f8000+OFFSET30                  ; Output #6
2711      Y:0000F8 Y:0000F8                   DC      $3fc000+OFFSET31                  ; Output #7
2712   
2713   
2714                                ; Note that BIAS BO1(p17) and BO2(p33) should be used for higher currents biasses because
2715                                ; they have 100 ohm filtering resistors (R345/350) , versus 1k on the other pins.
2716                                ; Video board #1, Bipolar -7.5 to +7.5 volts supplies
2717      Y:0000F9 Y:0000F9                   DC      $0c4000+@CVI((VDDOUT+Vmax2)/Vmax3*4095) ; Pin #17 VDDOUT
2718      Y:0000FA Y:0000FA                   DC      $0c8000+@CVI((VDDUC+Vmax2)/Vmax3*4095) ; Pin #33 VDDUC
2719      Y:0000FB Y:0000FB                   DC      $0cc000+@CVI((IREF+Vmax2)/Vmax3*4095) ; Pin #16 IREF
2720      Y:0000FC Y:0000FC                   DC      $0d0000+@CVI((VDETCOM+Vmax2)/Vmax3*4095) ; Pin #32 VDETCOM
2721      Y:0000FD Y:0000FD                   DC      $0d4000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #15 NC
2722      Y:0000FE Y:0000FE                   DC      $0d8000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #31 NC
2723      Y:0000FF Y:0000FF                   DC      $0dc000+@CVI((VSSOUT+Vmax2)/Vmax3*4095) ; Pin #14 NC but provides output sourc
e follower source voltage = 5V
2724   
2725                                ; Video board #2
2726      Y:000100 Y:000100                   DC      $1c4000+@CVI((VDDCL+Vmax2)/Vmax3*4095) ; Pin #17 VDDCL
2727      Y:000101 Y:000101                   DC      $1c8000+@CVI((VROWOFF+Vmax2)/Vmax3*4095) ; Pin #33 VROWOFF
2728      Y:000102 Y:000102                   DC      $1cc000+@CVI((VGGCL+Vmax2)/Vmax3*4095) ; Pin #16 VGGCL
2729      Y:000103 Y:000103                   DC      $1d0000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #32 NC
2730      Y:000104 Y:000104                   DC      $1d4000+@CVI((VNCOL+Vmax2)/Vmax3*4095) ; Pin #15 VNCOL
2731      Y:000105 Y:000105                   DC      $1d8000+@CVI((VNROW+Vmax2)/Vmax3*4095) ; Pin #31 VNROW
2732      Y:000106 Y:000106                   DC      $1dc000+@CVI((VSSOUT+Vmax2)/Vmax3*4095) ; Pin #14 NC but provides output sourc
e follower source voltage = 5V
2733   
2734                                ; Video board #3, Bipolar -7.5 to +7.5 volts supplies
2735      Y:000107 Y:000107                   DC      $2c4000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #17 NC
2736      Y:000108 Y:000108                   DC      $2c8000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #33 NC
2737      Y:000109 Y:000109                   DC      $2cc000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #16 NC
2738      Y:00010A Y:00010A                   DC      $2d0000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #32 NC
2739      Y:00010B Y:00010B                   DC      $2d4000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #15 NC
2740      Y:00010C Y:00010C                   DC      $2d8000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #31 NC
2741      Y:00010D Y:00010D                   DC      $2dc000+@CVI((VSSOUT+Vmax2)/Vmax3*4095) ; Pin #14 NC but provides output sourc
e follower source voltage = 5V
2742   
2743                                ; Video board #4
2744      Y:00010E Y:00010E                   DC      $3c4000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #17 NC
2745      Y:00010F Y:00010F                   DC      $3c8000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #33 NC
2746      Y:000110 Y:000110                   DC      $3cc000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #16 NC
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  AladdinIII.waveforms  Page 48



2747      Y:000111 Y:000111                   DC      $3d0000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #32 NC
2748      Y:000112 Y:000112                   DC      $3d4000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #15 NC
2749      Y:000113 Y:000113                   DC      $3d8000+@CVI((ZERO+Vmax2)/Vmax3*4095) ; Pin #31 NC
2750      Y:000114 Y:000114                   DC      $3dc000+@CVI((VSSOUT+Vmax2)/Vmax3*4095) ; Pin #14 NC but provides output sourc
e follower source voltage = 5V
2751                                END_BIASES
2752                                          INCLUDE "CLOCK_ROW_RST.waveforms"         ;
2753                                      COMMENT *
2754   
2755   
2756                                   *
2757   
2758   
2759   
2760                                CLOCK_RR_ROW_1
2761      Y:000115 Y:000115                   DC      END_CLOCK_RR_ROW_1-CLOCK_RR_ROW_1-1
2762      Y:000116 Y:000116                   DC      CLK2+DLY1+SSYNC+S1+00+SOE+RDES+VRSTOFF+VRSTR+VROWON
2763      Y:000117 Y:000117                   DC      CLK3+DLY2+00000+F1+F2
2764      Y:000118 Y:000118                   DC      CLK3+DLY1+FSYNC+F1+F2
2765      Y:000119 Y:000119                   DC      CLK3+DLY2+FSYNC+00+F2
2766      Y:00011A Y:00011A                   DC      CLK3+DLY0+FSYNC+F1+F2
2767                                END_CLOCK_RR_ROW_1
2768   
2769                                CLOCK_RR_ROW_2
2770      Y:00011B Y:00011B                   DC      END_CLOCK_RR_ROW_2-CLOCK_RR_ROW_2-1
2771      Y:00011C Y:00011C                   DC      CLK2+DLY2+SSYNC+S1+00+000+RDES+VRSTOFF+VRSTR+VROWON
2772      Y:00011D Y:00011D                   DC      CLK3+DLY2+00000+F1+F2
2773      Y:00011E Y:00011E                   DC      CLK3+DLY1+FSYNC+F1+F2
2774      Y:00011F Y:00011F                   DC      CLK3+DLY2+FSYNC+00+F2
2775      Y:000120 Y:000120                   DC      CLK3+DLY0+FSYNC+F1+F2
2776                                END_CLOCK_RR_ROW_2
2777   
2778                                CLOCK_RR_ROW_3
2779      Y:000121 Y:000121                   DC      END_CLOCK_RR_ROW_3-CLOCK_RR_ROW_3-1
2780      Y:000122 Y:000122                   DC      CLK2+DLY1+SSYNC+00+S2+SOE+RDES+VRSTOFF+VRSTR+VROWON
2781      Y:000123 Y:000123                   DC      CLK3+DLY2+00000+F1+F2
2782      Y:000124 Y:000124                   DC      CLK3+DLY1+FSYNC+F1+F2
2783      Y:000125 Y:000125                   DC      CLK3+DLY2+FSYNC+00+F2
2784      Y:000126 Y:000126                   DC      CLK3+DLY0+FSYNC+F1+F2
2785                                END_CLOCK_RR_ROW_3
2786   
2787                                CLOCK_RR_ROW_4
2788      Y:000127 Y:000127                   DC      END_CLOCK_RR_ROW_4-CLOCK_RR_ROW_4-1
2789      Y:000128 Y:000128                   DC      CLK2+DLY2+SSYNC+00+S2+000+RDES+VRSTOFF+VRSTR+VROWON
2790      Y:000129 Y:000129                   DC      CLK3+DLY2+00000+F1+F2
2791      Y:00012A Y:00012A                   DC      CLK3+DLY1+FSYNC+F1+F2
2792      Y:00012B Y:00012B                   DC      CLK3+DLY2+FSYNC+00+F2
2793      Y:00012C Y:00012C                   DC      CLK3+DLY0+FSYNC+F1+F2
2794                                END_CLOCK_RR_ROW_4
2795   
2796   
2797   
2798                                CLOCK_RESET_ROW_1
2799      Y:00012D Y:00012D                   DC      END_CLOCK_RESET_ROW_1-CLOCK_RESET_ROW_1-1
2800      Y:00012E Y:00012E                   DC      CLK2+DLY2+SSYNC+S1+00+SOE+RDES+VRSTOFF+VRSTR+000000
2801      Y:00012F Y:00012F                   DC      CLK3+DLY0+00000+F1+F2
2802      Y:000130 Y:000130                   DC      CLK2+DLY2+SSYNC+S1+00+SOE+RDES+VRSTOFF+00000+000000
2803      Y:000131 Y:000131                   DC      CLK3+DLY4+FSYNC+F1+F2
2804      Y:000132 Y:000132                   DC      CLK2+DLY1+SSYNC+S1+00+SOE+RDES+VRSTOFF+VRSTR+000000
2805      Y:000133 Y:000133                   DC      CLK2+DLY1+SSYNC+S1+00+SOE+RDES+VRSTOFF+VRSTR+VROWON
2806      Y:000134 Y:000134                   DC      CLK3+DLY2+FSYNC+00+F2
2807      Y:000135 Y:000135                   DC      CLK3+DLY0+FSYNC+F1+F2
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  CLOCK_ROW_RST.waveforms  Page 49



2808                                END_CLOCK_RESET_ROW_1
2809   
2810                                CLOCK_RESET_ROW_2
2811      Y:000136 Y:000136                   DC      END_CLOCK_RESET_ROW_2-CLOCK_RESET_ROW_2-1
2812      Y:000137 Y:000137                   DC      CLK2+DLY2+SSYNC+S1+00+000+RDES+VRSTOFF+VRSTR+VROWON
2813      Y:000138 Y:000138                   DC      CLK3+DLY0+00000+F1+F2
2814      Y:000139 Y:000139                   DC      CLK2+DLY2+SSYNC+S1+00+000+RDES+VRSTOFF+VRSTR+VROWON
2815      Y:00013A Y:00013A                   DC      CLK3+DLY4+FSYNC+F1+F2
2816      Y:00013B Y:00013B                   DC      CLK2+DLY1+SSYNC+S1+00+000+RDES+VRSTOFF+VRSTR+VROWON
2817      Y:00013C Y:00013C                   DC      CLK2+DLY1+SSYNC+S1+00+000+RDES+VRSTOFF+VRSTR+VROWON
2818      Y:00013D Y:00013D                   DC      CLK3+DLY2+FSYNC+00+F2
2819      Y:00013E Y:00013E                   DC      CLK3+DLY0+FSYNC+F1+F2
2820                                END_CLOCK_RESET_ROW_2
2821   
2822                                CLOCK_RESET_ROW_3
2823      Y:00013F Y:00013F                   DC      END_CLOCK_RESET_ROW_3-CLOCK_RESET_ROW_3-1
2824      Y:000140 Y:000140                   DC      CLK2+DLY2+SSYNC+00+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2825      Y:000141 Y:000141                   DC      CLK3+DLY0+00000+F1+F2
2826      Y:000142 Y:000142                   DC      CLK2+DLY2+SSYNC+00+S2+SOE+RDES+VRSTOFF+00000+000000
2827      Y:000143 Y:000143                   DC      CLK3+DLY4+FSYNC+F1+F2
2828      Y:000144 Y:000144                   DC      CLK2+DLY1+SSYNC+00+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2829      Y:000145 Y:000145                   DC      CLK2+DLY1+SSYNC+00+S2+SOE+RDES+VRSTOFF+VRSTR+VROWON
2830      Y:000146 Y:000146                   DC      CLK3+DLY2+FSYNC+00+F2
2831      Y:000147 Y:000147                   DC      CLK3+DLY0+FSYNC+F1+F2
2832                                END_CLOCK_RESET_ROW_3
2833   
2834                                CLOCK_RESET_ROW_4
2835      Y:000148 Y:000148                   DC      END_CLOCK_RESET_ROW_4-CLOCK_RESET_ROW_4-1
2836      Y:000149 Y:000149                   DC      CLK2+DLY2+SSYNC+00+S2+000+RDES+VRSTOFF+VRSTR+VROWON
2837      Y:00014A Y:00014A                   DC      CLK3+DLY0+00000+F1+F2
2838      Y:00014B Y:00014B                   DC      CLK2+DLY2+SSYNC+00+S2+000+RDES+VRSTOFF+VRSTR+VROWON
2839      Y:00014C Y:00014C                   DC      CLK3+DLY4+FSYNC+F1+F2
2840      Y:00014D Y:00014D                   DC      CLK2+DLY1+SSYNC+00+S2+000+RDES+VRSTOFF+VRSTR+VROWON
2841      Y:00014E Y:00014E                   DC      CLK2+DLY1+SSYNC+00+S2+000+RDES+VRSTOFF+VRSTR+VROWON
2842      Y:00014F Y:00014F                   DC      CLK3+DLY2+FSYNC+00+F2
2843      Y:000150 Y:000150                   DC      CLK3+DLY0+FSYNC+F1+F2
2844                                END_CLOCK_RESET_ROW_4
2845   
2846                                CLOCK_CDS_RESET_ROW_1
2847      Y:000151 Y:000151                   DC      END_CLOCK_CDS_RESET_ROW_1-CLOCK_CDS_RESET_ROW_1-1
2848      Y:000152 Y:000152                   DC      CLK2+DLY2+SSYNC+S1+00+SOE+RDES+VRSTOFF+VRSTR+000000
2849      Y:000153 Y:000153                   DC      CLK3+DLY0+00000+F1+F2
2850      Y:000154 Y:000154                   DC      CLK2+DLY2+SSYNC+S1+00+SOE+RDES+VRSTOFF+00000+000000
2851      Y:000155 Y:000155                   DC      CLK3+DLY4+FSYNC+F1+F2
2852      Y:000156 Y:000156                   DC      CLK2+DLY1+SSYNC+S1+00+SOE+RDES+VRSTOFF+VRSTR+000000
2853      Y:000157 Y:000157                   DC      CLK2+DLY1+SSYNC+S1+00+SOE+RDES+VRSTOFF+VRSTR+VROWON
2854      Y:000158 Y:000158                   DC      CLK3+DLY2+FSYNC+00+F2
2855      Y:000159 Y:000159                   DC      CLK3+DLY0+FSYNC+F1+F2
2856                                END_CLOCK_CDS_RESET_ROW_1
2857   
2858                                CLOCK_CDS_RESET_ROW_2
2859      Y:00015A Y:00015A                   DC      END_CLOCK_CDS_RESET_ROW_2-CLOCK_CDS_RESET_ROW_2-1
2860      Y:00015B Y:00015B                   DC      CLK2+DLY2+SSYNC+S1+00+000+RDES+VRSTOFF+VRSTR+VROWON
2861      Y:00015C Y:00015C                   DC      CLK3+DLY0+00000+F1+F2
2862      Y:00015D Y:00015D                   DC      CLK2+DLY2+SSYNC+S1+00+000+RDES+VRSTOFF+VRSTR+VROWON
2863      Y:00015E Y:00015E                   DC      CLK3+DLY4+FSYNC+F1+F2
2864      Y:00015F Y:00015F                   DC      CLK2+DLY1+SSYNC+S1+00+000+RDES+VRSTOFF+VRSTR+VROWON
2865      Y:000160 Y:000160                   DC      CLK2+DLY1+SSYNC+S1+00+000+RDES+VRSTOFF+VRSTR+VROWON
2866      Y:000161 Y:000161                   DC      CLK3+DLY2+FSYNC+00+F2
2867      Y:000162 Y:000162                   DC      CLK3+DLY0+FSYNC+F1+F2
2868                                END_CLOCK_CDS_RESET_ROW_2
2869   
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  CLOCK_ROW_RST.waveforms  Page 50



2870                                CLOCK_CDS_RESET_ROW_3
2871      Y:000163 Y:000163                   DC      END_CLOCK_CDS_RESET_ROW_3-CLOCK_CDS_RESET_ROW_3-1
2872      Y:000164 Y:000164                   DC      CLK2+DLY2+SSYNC+00+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2873      Y:000165 Y:000165                   DC      CLK3+DLY0+00000+F1+F2
2874      Y:000166 Y:000166                   DC      CLK2+DLY2+SSYNC+00+S2+SOE+RDES+VRSTOFF+00000+000000
2875      Y:000167 Y:000167                   DC      CLK3+DLY4+FSYNC+F1+F2
2876      Y:000168 Y:000168                   DC      CLK2+DLY1+SSYNC+00+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2877      Y:000169 Y:000169                   DC      CLK2+DLY1+SSYNC+00+S2+SOE+RDES+VRSTOFF+VRSTR+VROWON
2878      Y:00016A Y:00016A                   DC      CLK3+DLY2+FSYNC+00+F2
2879      Y:00016B Y:00016B                   DC      CLK3+DLY0+FSYNC+F1+F2
2880                                END_CLOCK_CDS_RESET_ROW_3
2881   
2882                                CLOCK_CDS_RESET_ROW_4
2883      Y:00016C Y:00016C                   DC      END_CLOCK_CDS_RESET_ROW_4-CLOCK_CDS_RESET_ROW_4-1
2884      Y:00016D Y:00016D                   DC      CLK2+DLY2+SSYNC+00+S2+000+RDES+VRSTOFF+VRSTR+VROWON
2885      Y:00016E Y:00016E                   DC      CLK3+DLY0+00000+F1+F2
2886      Y:00016F Y:00016F                   DC      CLK2+DLY2+SSYNC+00+S2+000+RDES+VRSTOFF+VRSTR+VROWON
2887      Y:000170 Y:000170                   DC      CLK3+DLY4+FSYNC+F1+F2
2888      Y:000171 Y:000171                   DC      CLK2+DLY1+SSYNC+00+S2+000+RDES+VRSTOFF+VRSTR+VROWON
2889      Y:000172 Y:000172                   DC      CLK2+DLY1+SSYNC+00+S2+000+RDES+VRSTOFF+VRSTR+VROWON
2890      Y:000173 Y:000173                   DC      CLK3+DLY2+FSYNC+00+F2
2891      Y:000174 Y:000174                   DC      CLK3+DLY0+FSYNC+F1+F2
2892                                END_CLOCK_CDS_RESET_ROW_4
2893   
2894                                RESET_ROW_12
2895      Y:000175 Y:000175                   DC      END_RESET_ROW_12-RESET_ROW_12-1
2896      Y:000176 Y:000176                   DC      CLK2+DLY2+SSYNC+S1+00+SOE+RDES+VRSTOFF+VRSTR+000000
2897      Y:000177 Y:000177                   DC      CLK3+DLY0+00000+F1+F2
2898      Y:000178 Y:000178                   DC      CLK2+DLY2+SSYNC+S1+00+SOE+RDES+VRSTOFF+00000+000000
2899      Y:000179 Y:000179                   DC      CLK3+DLY4+FSYNC+F1+F2
2900      Y:00017A Y:00017A                   DC      CLK2+DLY1+SSYNC+S1+00+SOE+RDES+VRSTOFF+VRSTR+000000
2901      Y:00017B Y:00017B                   DC      CLK2+DLY1+SSYNC+S1+00+SOE+RDES+VRSTOFF+VRSTR+VROWON
2902                                END_RESET_ROW_12
2903   
2904                                RESET_ROW_34
2905      Y:00017C Y:00017C                   DC      END_RESET_ROW_34-RESET_ROW_34-1
2906      Y:00017D Y:00017D                   DC      CLK2+DLY2+SSYNC+00+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2907      Y:00017E Y:00017E                   DC      CLK3+DLY0+00000+F1+F2
2908      Y:00017F Y:00017F                   DC      CLK2+DLY2+SSYNC+00+S2+SOE+RDES+VRSTOFF+00000+000000
2909      Y:000180 Y:000180                   DC      CLK3+DLY4+FSYNC+F1+F2
2910      Y:000181 Y:000181                   DC      CLK2+DLY1+SSYNC+00+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2911      Y:000182 Y:000182                   DC      CLK2+DLY1+SSYNC+00+S2+SOE+RDES+VRSTOFF+VRSTR+VROWON
2912                                END_RESET_ROW_34
2913   
2914                                          INCLUDE "CLOCK_GLOBAL_RST.waveforms"      ;
2915   
2916   
2917   
2918                                FRAME_RESET
2919      Y:000183 Y:000183                   DC      END_FRAME_RESET-FRAME_RESET-1
2920      Y:000184 Y:000184                   DC      CLK2+DLY1+00000+S1+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2921      Y:000185 Y:000185                   DC      CLK2+DLYG+00000+S1+S2+SOE+RDES+0000000+VRSTR+000000
2922      Y:000186 Y:000186                   DC      CLK2+DLYG+SSYNC+S1+S2+SOE+RDES+0000000+VRSTR+000000
2923      Y:000187 Y:000187                   DC      CLK2+DLY1+SSYNC+S1+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2924      Y:000188 Y:000188                   DC      CLK2+DLY1+SSYNC+S1+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2925      Y:000189 Y:000189                   DC      CLK2+DLY1+00000+S1+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2926      Y:00018A Y:00018A                   DC      CLK2+DLYG+00000+S1+S2+SOE+RDES+0000000+VRSTR+000000
2927      Y:00018B Y:00018B                   DC      CLK2+DLYG+SSYNC+S1+S2+SOE+RDES+0000000+VRSTR+000000
2928      Y:00018C Y:00018C                   DC      CLK2+DLY1+SSYNC+S1+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2929      Y:00018D Y:00018D                   DC      CLK2+DLY1+SSYNC+S1+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2930      Y:00018E Y:00018E                   DC      CLK2+DLY1+00000+S1+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2931      Y:00018F Y:00018F                   DC      CLK2+DLYG+00000+S1+S2+SOE+RDES+0000000+VRSTR+000000
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  CLOCK_GLOBAL_RST.waveforms  Page 51



2932      Y:000190 Y:000190                   DC      CLK2+DLYG+SSYNC+S1+S2+SOE+RDES+0000000+VRSTR+000000
2933      Y:000191 Y:000191                   DC      CLK2+DLY1+SSYNC+S1+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2934      Y:000192 Y:000192                   DC      CLK2+DLY1+SSYNC+S1+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2935      Y:000193 Y:000193                   DC      CLK2+DLY1+00000+S1+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2936      Y:000194 Y:000194                   DC      CLK2+DLYG+00000+S1+S2+SOE+RDES+0000000+VRSTR+000000
2937      Y:000195 Y:000195                   DC      CLK2+DLYG+SSYNC+S1+S2+SOE+RDES+0000000+VRSTR+000000
2938      Y:000196 Y:000196                   DC      CLK2+DLY1+SSYNC+S1+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2939      Y:000197 Y:000197                   DC      CLK2+DLY1+SSYNC+S1+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2940                                END_FRAME_RESET
2941   
2942                                          INCLUDE "CLOCK_READOUT.waveforms"         ;
2943                                ; Video processor bit definitions
2944   
2945                                ;  Bit #3 = Move A/D data to FIFO   (high going edge)
2946                                ;  Bit #2 = A/D Convert       (low going edge to start conversion)
2947                                ;  Bit #1 = Reset Integrator     (=0 to reset)
2948                                ;  Bit #0 = Integrate      (=0 to integrate)
2949   
2950                                ; STARTS HERE THE READOUT OF 6DS
2951      080000                    DTW       EQU     $080000                           ;  Tw Fast Sync Time (320ns + 40ns exec = 36
0ns)
2952      0F0000                    PAD_TIM   EQU     $0F0000                           ;  Pixel PAD Time       (640ns)
2953      0F0000                    ADC_TIM   EQU     $0F0000                           ;  Pixel PAD Time       (640ns)
2954      180000                    INT_TIM   EQU     $180000                           ;  Pixel Sample Time    (1000ns)
2955      8C0000                    SXM_TIM   EQU     $8C0000                           ;  Pixel Transmit Delay    (5640ns)NOT USED
2956      040000                    ADC_CNV   EQU     $040000                           ;  ADC Sample Time         (100ns)
2957      000000                    STL_TIM   EQU     $000000                           ;  A Generic Settling time (0ns)
2958      180000                    RST_TIM   EQU     $180000                           ;  Reset Time reduced      (1000ns)
2959      000000                    STP_TIM   EQU     $000000                           ;  Stop Reseting
2960      080000                    FIP_TIM   EQU     $080000                           ;  $08 seems ok but have to test with signal
 as it's settling time of integrator stage
2961      000000                    RST_DLY   EQU     $000000                           ;  Delay before resetting the integrator
2962      000000                    PIX_RTE   EQU     $000000                           ;  Delay to adjust the pixel rate only for X
DS not needed for XINT_XDS
2963      0C0000                    ADC_HLD   EQU     $0C0000                           ;  Wait for ADC to setlle before moving to F
IFO (Hold)   (480ns)
2964      040000                    RST_STL   EQU     $040000                           ;  Wait after reset of Integrator before Int
egration (100ns)
2965      080000                    INT_STL   EQU     $080000                           ;  Wait for Integrator output to settle befo
re A2D (360ns)
2966   
2967   
2968   
2969                                ; Copy of the clocking bit definition for easy reference
2970                                ;  DC CLK2+DELAY+SSYNC+S1+S2+SOE+RDES+VRSTOFF+VRSTR+VROWON
2971                                ;  DC CLK3+DELAY+FSYNC+F1+F2
2972   
2973   
2974   
2975                                FRAME_INIT
2976      Y:000198 Y:000198                   DC      END_FRAME_INIT-FRAME_INIT-1
2977      Y:000199 Y:000199                   DC      CLK2+DLY1+SSYNC+S1+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2978      Y:00019A Y:00019A                   DC      CLK2+DLY4+00000+S1+S2+SOE+0000+VRSTOFF+VRSTR+000000
2979      Y:00019B Y:00019B                   DC      CLK2+DLY4+00000+S1+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2980      Y:00019C Y:00019C                   DC      CLK2+DLY1+SSYNC+S1+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2981      Y:00019D Y:00019D                   DC      CLK2+DLY2+SSYNC+00+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2982      Y:00019E Y:00019E                   DC      CLK2+DLY1+SSYNC+S1+S2+SOE+RDES+VRSTOFF+VRSTR+000000
2983                                END_FRAME_INIT
2984   
2985   
2986                                CLOCK_ROW_1
2987      Y:00019F Y:00019F                   DC      END_CLOCK_ROW_1-CLOCK_ROW_1-1
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  CLOCK_READOUT.waveforms  Page 52



2988      Y:0001A0 Y:0001A0                   DC      CLK2+DLY1+SSYNC+S1+00+SOE+RDES+VRSTOFF+VRSTR+000000
2989      Y:0001A1 Y:0001A1                   DC      CLK3+DLY2+00000+F1+F2
2990      Y:0001A2 Y:0001A2                   DC      CLK3+DLY1+FSYNC+F1+F2
2991      Y:0001A3 Y:0001A3                   DC      CLK3+DLY2+FSYNC+00+F2
2992      Y:0001A4 Y:0001A4                   DC      CLK3+DLY0+FSYNC+F1+F2
2993                                END_CLOCK_ROW_1
2994   
2995                                CLOCK_ROW_2
2996      Y:0001A5 Y:0001A5                   DC      END_CLOCK_ROW_2-CLOCK_ROW_2-1
2997      Y:0001A6 Y:0001A6                   DC      CLK2+DLY2+SSYNC+S1+00+000+RDES+VRSTOFF+VRSTR+000000
2998      Y:0001A7 Y:0001A7                   DC      CLK3+DLY2+00000+F1+F2
2999      Y:0001A8 Y:0001A8                   DC      CLK3+DLY1+FSYNC+F1+F2
3000      Y:0001A9 Y:0001A9                   DC      CLK3+DLY2+FSYNC+00+F2
3001      Y:0001AA Y:0001AA                   DC      CLK3+DLY0+FSYNC+F1+F2
3002                                END_CLOCK_ROW_2
3003   
3004                                CLOCK_ROW_3
3005      Y:0001AB Y:0001AB                   DC      END_CLOCK_ROW_3-CLOCK_ROW_3-1
3006      Y:0001AC Y:0001AC                   DC      CLK2+DLY1+SSYNC+00+S2+SOE+RDES+VRSTOFF+VRSTR+000000
3007      Y:0001AD Y:0001AD                   DC      CLK3+DLY2+00000+F1+F2
3008      Y:0001AE Y:0001AE                   DC      CLK3+DLY1+FSYNC+F1+F2
3009      Y:0001AF Y:0001AF                   DC      CLK3+DLY2+FSYNC+00+F2
3010      Y:0001B0 Y:0001B0                   DC      CLK3+DLY0+FSYNC+F1+F2
3011                                END_CLOCK_ROW_3
3012   
3013                                CLOCK_ROW_4
3014      Y:0001B1 Y:0001B1                   DC      END_CLOCK_ROW_4-CLOCK_ROW_4-1
3015      Y:0001B2 Y:0001B2                   DC      CLK2+DLY2+SSYNC+00+S2+000+RDES+VRSTOFF+VRSTR+000000
3016      Y:0001B3 Y:0001B3                   DC      CLK3+DLY2+00000+F1+F2
3017      Y:0001B4 Y:0001B4                   DC      CLK3+DLY1+FSYNC+F1+F2
3018      Y:0001B5 Y:0001B5                   DC      CLK3+DLY2+FSYNC+00+F2
3019      Y:0001B6 Y:0001B6                   DC      CLK3+DLY0+FSYNC+F1+F2
3020                                END_CLOCK_ROW_4
3021   
3022   
3023   
3024   
3025                                CLOCK_COLUMN
3026      Y:0001B7 Y:0001B7                   DC      END_CLOCK_COLUMN-CLOCK_COLUMN-1
3027      Y:0001B8 Y:0001B8                   DC      CLK3+DLYA+FSYNC+F1+00
3028      Y:0001B9 Y:0001B9                   DC      CLK3+DLYB+FSYNC+F1+F2
3029      Y:0001BA Y:0001BA                   DC      CLK3+DLYA+FSYNC+00+F2
3030      Y:0001BB Y:0001BB                   DC      CLK3+DLYB+FSYNC+F1+F2
3031                                END_CLOCK_COLUMN
3032   
3033   
3034   
3035   
3036   
3037   
3038                                RD_COL_PIPELINE_TEST
3039      Y:0001BC Y:0001BC                   DC      END_RD_COL_PIPELINE_TEST-RD_COL_PIPELINE_TEST-1
3040      Y:0001BD Y:0001BD                   DC      CLK3+000+FSYNC+F1+00              ; Select Pixel 1                40ns
3041      Y:0001BE Y:0001BE                   DC      VIDEO+PAD_TIM+%0111               ; Pad Delay -                   640ns
3042      Y:0001BF Y:0001BF                   DC      VIDEO+ADC_TIM+%0111               ; Hold No Pixel         1000ns
3043      Y:0001C0 Y:0001C0                   DC      VIDEO+STL_TIM+%0101               ; Move No Pixel                 40ns
3044      Y:0001C1 Y:0001C1                   DC      VIDEO+$000000+%0101               ; Place for SXMIT               40ns
3045      Y:0001C2 Y:0001C2                   DC      VIDEO+SXM_TIM+%0101               ; Settling time             3880ns
3046      Y:0001C3 Y:0001C3                   DC      VIDEO+STP_TIM+%0111               ; Stop Reseting         40ns
3047      Y:0001C4 Y:0001C4                   DC      VIDEO+INT_TIM+%0110               ; Integrate Pixel 1         1000ns
3048      Y:0001C5 Y:0001C5                   DC      VIDEO+$000000+%0111               ; Stop Integration      40ns
3049      Y:0001C6 Y:0001C6                   DC      VIDEO+ADC_CNV+%0011               ; Start A/D cnv Pix 1   40ns
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  CLOCK_READOUT.waveforms  Page 53



3050      Y:0001C7 Y:0001C7                   DC      CLK3+DTW+FSYNC+F1+F2              ; Deselect Pixel 1              360ns
3051      Y:0001C8 Y:0001C8                   DC      CLK3+000+FSYNC+00+F2              ; Select Pixel 2                40ns
3052      Y:0001C9 Y:0001C9                   DC      VIDEO+PAD_TIM+%0111               ; Pad Delay -           640ns
3053      Y:0001CA Y:0001CA                   DC      VIDEO+ADC_TIM+%0111               ; Hold A/D convert      1000ns
3054      Y:0001CB Y:0001CB                   DC      VIDEO+STL_TIM+%1101               ; Move A/D data FIFO    40ns
3055      Y:0001CC Y:0001CC                   DC      SXMIT                             ; SXMIT the Previous    40ns
3056      Y:0001CD Y:0001CD                   DC      VIDEO+SXM_TIM+%0101               ; Settling time             3880ns
3057      Y:0001CE Y:0001CE                   DC      VIDEO+STP_TIM+%0111               ; Stop Reseting                 40ns
3058      Y:0001CF Y:0001CF                   DC      VIDEO+INT_TIM+%0110               ; Integrate Pixel 3         1000ns
3059      Y:0001D0 Y:0001D0                   DC      VIDEO+$000000+%0111               ; Stop Integration      40ns
3060      Y:0001D1 Y:0001D1                   DC      VIDEO+ADC_CNV+%0011               ; Start A/D convert     40ns
3061      Y:0001D2 Y:0001D2                   DC      CLK3+DTW+FSYNC+F1+F2              ; Deselect Pixel 3              360ns
3062                                END_RD_COL_PIPELINE_TEST
3063   
3064                                ; This code reads out most of the array, with full image transmission
3065                                RD_COLS_TEST
3066      Y:0001D3 Y:0001D3                   DC      END_RD_COLS_TEST-RD_COLS_TEST-1   ;
3067      Y:0001D4 Y:0001D4                   DC      CLK3+000+FSYNC+F1+00              ; Select Pixel 2 (40ns)
3068      Y:0001D5 Y:0001D5                   DC      VIDEO+PAD_TIM+%0111               ; Pad Delay - 40ns
3069      Y:0001D6 Y:0001D6                   DC      VIDEO+ADC_TIM+%0111               ; Hold A/D convert sig Pixel 1 (1us)
3070      Y:0001D7 Y:0001D7                   DC      VIDEO+STL_TIM+%1101               ; Move A/D data to FIFO Pixel 1 (40ns)
3071      Y:0001D8 Y:0001D8                   DC      SXMIT                             ; SXMIT the Previous Pixel 1 - X32 (40ns)
3072      Y:0001D9 Y:0001D9                   DC      VIDEO+SXM_TIM+%0101               ; Settling time (3880ns)
3073      Y:0001DA Y:0001DA                   DC      VIDEO+STP_TIM+%0111               ; Stop Reseting
3074      Y:0001DB Y:0001DB                   DC      VIDEO+INT_TIM+%0110               ; Integrate Pixel 2 (760ns)
3075      Y:0001DC Y:0001DC                   DC      VIDEO+$000000+%0111               ; Stop Integration
3076      Y:0001DD Y:0001DD                   DC      VIDEO+ADC_CNV+%0011               ; Start A/D convert Pixel 2 (400ns)
3077      Y:0001DE Y:0001DE                   DC      CLK3+DTW+FSYNC+F1+F2              ; Deselect Pixel 1 (240ns)
3078      Y:0001DF Y:0001DF                   DC      CLK3+000+FSYNC+00+F2              ; Select Pixel 3 (40ns)
3079      Y:0001E0 Y:0001E0                   DC      VIDEO+PAD_TIM+%0111               ; Pad Delay - 40ns
3080      Y:0001E1 Y:0001E1                   DC      VIDEO+ADC_TIM+%0111               ; Hold A/D convert sig Pixel 2 (1us)
3081      Y:0001E2 Y:0001E2                   DC      VIDEO+STL_TIM+%1101               ; Move A/D data to FIFO Pixel 2 (40ns)
3082      Y:0001E3 Y:0001E3                   DC      SXMIT                             ; SXMIT the Previous Pixel 2 - X32 (40ns)
3083      Y:0001E4 Y:0001E4                   DC      VIDEO+SXM_TIM+%0101               ; Settling time (480ns)
3084      Y:0001E5 Y:0001E5                   DC      VIDEO+STP_TIM+%0111               ; Stop Reseting
3085      Y:0001E6 Y:0001E6                   DC      VIDEO+INT_TIM+%0110               ; Integrate Pixel 3 (760ns)
3086      Y:0001E7 Y:0001E7                   DC      VIDEO+$000000+%0111               ; Stop Integration
3087      Y:0001E8 Y:0001E8                   DC      VIDEO+ADC_CNV+%0011               ; Start A/D convert Pixel 3 (400ns)
3088      Y:0001E9 Y:0001E9                   DC      CLK3+DTW+FSYNC+F1+F2              ; Deselect Pixel 3 (240ns)
3089                                END_RD_COLS_TEST
3090   
3091                                ; This transmits the last pixels in each row, emptying the pipeline
3092                                LAST_8INROW_TEST
3093      Y:0001EA Y:0001EA                   DC      END_LAST_8INROW_TEST-LAST_8INROW_TEST-1
3094      Y:0001EB Y:0001EB                   DC      CLK3+000+FSYNC+F1+00              ; Select Pixel 2 (40ns)
3095      Y:0001EC Y:0001EC                   DC      VIDEO+PAD_TIM+%0111               ; Pad Delay - 40ns
3096      Y:0001ED Y:0001ED                   DC      VIDEO+ADC_TIM+%0111               ; Hold A/D convert sig Pixel 1 (1us)
3097      Y:0001EE Y:0001EE                   DC      VIDEO+STL_TIM+%1101               ; Move A/D data to FIFO Pixel 1 (40ns)
3098      Y:0001EF Y:0001EF                   DC      SXMIT                             ; SXMIT the Previous Pixel 1 - X32 (40ns)
3099      Y:0001F0 Y:0001F0                   DC      VIDEO+SXM_TIM+%0101               ; Settling time (480ns)
3100      Y:0001F1 Y:0001F1                   DC      VIDEO+STP_TIM+%0111               ; Stop Reseting
3101      Y:0001F2 Y:0001F2                   DC      VIDEO+INT_TIM+%0110               ; Integrate Pixel 2 (760ns)
3102      Y:0001F3 Y:0001F3                   DC      VIDEO+$000000+%0111               ; Stop Integration
3103      Y:0001F4 Y:0001F4                   DC      VIDEO+ADC_CNV+%0011               ; Start A/D convert Pixel 2 (40+40ns)
3104      Y:0001F5 Y:0001F5                   DC      CLK3+DTW+FSYNC+F1+F2              ; Deselect Pixel 1 (240ns)
3105                                END_LAST_8INROW_TEST
3106   
3107   
3108   
3109   
3110   
3111   
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  CLOCK_READOUT.waveforms  Page 54



3112   
3113                                ; Define CLOCK as a macro to produce in-line code to reduce execution time
3114                                ; Here we do INT and A2D 6 times successively
3115                                 RD_COL_MACRO1
3116                                          MACRO
3117 m                                        DC      VIDEO+RST_DLY+%0111               ; Wait 4 Reset Integrator    40ns
3118 m                                        DC      VIDEO+RST_TIM+%0101               ; Reset Integrator           1000ns
3119 m                                        DC      VIDEO+RST_STL+%0111               ; Stop Reset & wait          100ns
3120 m                                        DC      VIDEO+INT_TIM+%0110               ; Integrate Pixel 1             1000ns
3121 m                                        DC      VIDEO+INT_STL+%0111               ; Stop Integration & wait    360ns <----Leac
h March 5, 2020DC      VIDEO+ADC_CNV+%0011             ; Start A/D cnv Pix 1 Sample1      40ns
3122 m                                        DC      VIDEO+ADC_CNV+%0011               ; A/D Conversion             100ns
3123 m                                        DC      VIDEO+ADC_HLD+%0111               ; Hold A/D convert              480ns
3124 m                                        DC      VIDEO+STL_TIM+%1111               ; Move A/D data FIFO         40ns
3125 m                              ;  DC      SXMIT                           ; SXMIT                      40ns
3126 m                                        ENDM
3127   
3128                                 RD_COL_MACRO2
3129                                          MACRO
3130 m                                        DC      VIDEO+RST_DLY+%0111               ; Wait 4 Reset Integrator    40ns
3131 m                                        DC      VIDEO+RST_TIM+%0101               ; Reset Integrator           1000ns
3132 m                                        DC      VIDEO+RST_STL+%0111               ; Stop Reset & wait          100ns
3133 m                                        DC      VIDEO+INT_TIM+%0110               ; Integrate Pixel 1             1000ns
3134 m                                        DC      VIDEO+INT_STL+%0111               ; Stop Integration & wait    360ns <----Leac
h March 5, 2020DC      VIDEO+ADC_CNV+%0011             ; Start A/D cnv Pix 1 Sample1      40ns
3135 m                                        DC      VIDEO+ADC_CNV+%0011               ; A/D Conversion             100ns
3136 m                                        DC      VIDEO+ADC_HLD+%0111               ; Hold A/D convert              480ns
3137 m                                        DC      VIDEO+STL_TIM+%1111               ; Move A/D data FIFO         40ns
3138 m                                        DC      SXMIT                             ; SXMIT                   40ns
3139 m                                        ENDM
3140   
3141                                ; This code initiates the pipeline for each row - no image transmission yet
3142                                ; Modified by L. Boucher for 6 Digital Samples
3143   
3144   
3145                                RD_COL_PIPELINE1
3146      Y:0001F6 Y:0001F6                   DC      END_RD_COL_PIPELINE1-RD_COL_PIPELINE1-1
3147      Y:0001F7 Y:0001F7                   DC      CLK3+$000000+FSYNC+F1+F2          ; trick to loop with rd_cols
3148      Y:0001F8 Y:0001F8                   DC      CLK3+$080000+FSYNC+F1+00          ;DTW 08 Select Pixel 1        40ns
3149                                END_RD_COL_PIPELINE1
3150   
3151   
3152                                RD_COLS1
3153      Y:0001F9 Y:0001F9                   DC      END_RD_COLS1-RD_COLS1-1           ;
3154      Y:0001FA Y:0001FA                   DC      CLK3+$000000+FSYNC+F1+F2          ; Deselect Pixel 2         360ns
3155      Y:0001FB Y:0001FB                   DC      CLK3+$900000+FSYNC+F1+00          ;DTW 08 Select next Pixel           40ns
3156                                END_RD_COLS1
3157   
3158   
3159                                RD_COLS2
3160      Y:0001FC Y:0001FC                   DC      END_RD_COLS2-RD_COLS2-1           ;
3161      Y:0001FD Y:0001FD                   DC      CLK3+$000000+FSYNC+F1+F2          ; Deselect Pixel 3         (240ns)
3162      Y:0001FE Y:0001FE                   DC      CLK3+$900000+FSYNC+00+F2          ;DTW 08 Select Pixel 4        (40ns)
3163                                END_RD_COLS2
3164   
3165                                ;RD_COL_PIPELINE1
3166                                ;   DC END_RD_COL_PIPELINE1-RD_COL_PIPELINE1-1
3167                                ;   DC      CLK3+000+FSYNC+F1+F2     ; trick to loop with rd_cols
3168                                ;   DC      CLK3+000+FSYNC+F1+00     ; Select Pixel 1        40ns
3169                                ;END_RD_COL_PIPELINE1
3170                                ;
3171                                ;
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  CLOCK_READOUT.waveforms  Page 55



3172                                ;RD_COLS1
3173                                ;   DC END_RD_COLS1-RD_COLS1-1 ;
3174                                ;   DC      CLK3+DTW+FSYNC+F1+F2     ; Deselect Pixel 2         360ns
3175                                ;   DC      CLK3+000+FSYNC+F1+00     ; Select next Pixel           40ns
3176                                ;END_RD_COLS1
3177                                ;
3178                                ;
3179                                ;RD_COLS2
3180                                ;   DC END_RD_COLS2-RD_COLS2-1 ;
3181                                ;   DC      CLK3+DTW+FSYNC+F1+F2     ; Deselect Pixel 3         (240ns)
3182                                ;   DC      CLK3+000+FSYNC+00+F2     ; Select Pixel 4        (40ns)
3183                                ;END_RD_COLS2
3184                                ;
3185                                ;
3186   
3187   
3188                                ; This transmits the last pixels in each row, emptying the pipeline
3189                                ; Modified by L. Boucher for 6 Digital Samples
3190                                ;LAST_8INROW
3191                                ;   DC END_LAST_8INROW-LAST_8INROW-1
3192                                ;   DC      CLK3+DTW+FSYNC+F1+F2     ; Deselect Pixel        360ns
3193                                ;   DC      CLK3+000+FSYNC+F1+00     ; Select next Pixel           40ns
3194                                ;
3195                                ;   RD_COLS1 ; Macro
3196                                ;   RD_COLS1
3197                                ;   RD_COLS1
3201                                ;
3202                                ;END_LAST_8INROW
3203                                ;
3204   
3205   
3206                                ;RD_COLS_A
3207                                ;   DC END_RD_COLS_A-RD_COLS_A-1 ;
3208                                ;   DC      CLK3+DTW+FSYNC+F1+F2     ; Deselect Pixel 2         360ns
3209                                ;   DC      CLK3+000+FSYNC+F1+00     ; Select next Pixel           40ns
3210                                ;END_RD_COLS_A
3211                                ;
3212                                ;
3213                                ;RD_COLS_B
3214                                ;   DC END_RD_COLS_B-RD_COLS_B-1 ;
3215                                ;   DC      CLK3+DTW+FSYNC+F1+F2     ; Deselect Pixel 3         (240ns)
3216                                ;   DC      CLK3+000+FSYNC+00+F2     ; Select Pixel 4        (40ns)
3217                                ;END_RD_COLS_B
3218   
3219   
3220                                SAMPLE_COL
3221      Y:0001FF Y:0001FF                   DC      END_SAMPLE_COL-SAMPLE_COL-1       ;
3222   
3223   
3224                                ;        DC      VIDEO+$000000+%0111             ; Wait 4 Reset Integrator    40ns
3225      Y:000200 Y:000200                   DC      VIDEO+$020000+%0101               ;SXM_TIM 8C       ; Settling time (3880ns)
3226      Y:000201 Y:000201                   DC      VIDEO+$000000+%0111               ;STP_TIM 00      ; Stop Reseting
3227      Y:000202 Y:000202                   DC      VIDEO+$180000+%0110               ;INT_TIM 18     ; Integrate Pixel 2 (760ns)
3228      Y:000203 Y:000203                   DC      VIDEO+$000000+%0111               ;00       ; Stop Integration
3229      Y:000204 Y:000204                   DC      VIDEO+$040000+%0011               ;ADC_CNV 04       ; Start A/D convert Pixel 
2 (400ns)
3230      Y:000205 Y:000205                   DC      VIDEO+$0F0000+%0111               ;PAD_TIM 0F       ; Pad Delay - 40ns
3231      Y:000206 Y:000206                   DC      VIDEO+$0F0000+%0111               ;ADC_TIM 0F       ; Hold A/D convert sig Pix
el 2 (1us)
3232      Y:000207 Y:000207                   DC      VIDEO+$000000+%1101               ;STL_TIM 00       ; Move A/D data to FIFO Pi
xel 2 (40ns)
3233      Y:000208 Y:000208                   DC      SXMIT                             ; SXMIT the Previous Pixel 2 - X32 (40ns)
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  CLOCK_READOUT.waveforms  Page 56



3234   
3235   
3236                                ;  DC      VIDEO+RST_DLY+%0111             ; Wait 4 Reset Integrator    40ns
3237                                ;  DC      VIDEO+RST_TIM+%0101             ; Reset Integrator           1000ns
3238                                ;  DC      VIDEO+RST_STL+%0111             ; Stop Reset & wait          100ns
3239                                ;  DC      VIDEO+INT_TIM+%0110             ; Integrate Pixel 1             1000ns
3240                                ;  DC      VIDEO+INT_STL+%0111             ; Stop Integration & wait    360ns <----Leach March 5
, 2020DC      VIDEO+ADC_CNV+%0011             ; Start A/D cnv Pix 1 Sample1      40ns
3241                                ;  DC      VIDEO+ADC_CNV+%0011             ; A/D Conversion             100ns
3242                                ;  DC      VIDEO+ADC_HLD+%0111             ; Hold A/D convert              480ns
3243                                ;  DC      VIDEO+STL_TIM+%1111             ; Move A/D data FIFO         40ns
3244                                ;  DC      SXMIT                           ; SXMIT                   40ns
3245                                END_SAMPLE_COL
3246   
3247   
3248   
3249   
3250   
3251   
3252                                ; ENDS HERE THE REAOUDT OF THE 6DS
3253   
3254   
3255   
3256   
3257   
3258   
3259                                ; This code intiates the pipeline of pixels for each row
3260                                RD_NTX_PIPELINE
3261      Y:000209 Y:000209                   DC      END_RD_NTX_PIPELINE-RD_NTX_PIPELINE-1
3262      Y:00020A Y:00020A                   DC      CLK3+000+FSYNC+F1+00              ; Select Pixel 1  40ns
3263      Y:00020B Y:00020B                   DC      VIDEO+PAD_TIM+%0111               ; Pad Delay -    640ns
3264      Y:00020C Y:00020C                   DC      VIDEO+ADC_TIM+%0111               ; Hold No Pixel         1000ns
3265      Y:00020D Y:00020D                   DC      VIDEO+STL_TIM+%0101               ; Move No Pixel      400ns
3266      Y:00020E Y:00020E                   DC      VIDEO+$000000+%0101               ; Place for SXMIT    40ns
3267      Y:00020F Y:00020F                   DC      VIDEO+SXM_TIM+%0101               ; Settling time        3880ns
3268      Y:000210 Y:000210                   DC      VIDEO+STP_TIM+%0111               ; Stop Reseting          40ns
3269      Y:000211 Y:000211                   DC      VIDEO+INT_TIM+%0110               ; Integrate Pixel 1    1000ns
3270      Y:000212 Y:000212                   DC      VIDEO+$000000+%0111               ; Stop Integration       40ns
3271      Y:000213 Y:000213                   DC      VIDEO+ADC_CNV+%0011               ; Start A/D cnv Pix 1    40ns
3272      Y:000214 Y:000214                   DC      CLK3+DTW+FSYNC+F1+F2              ; Deselect Pixel 1   360ns
3273      Y:000215 Y:000215                   DC      CLK3+000+FSYNC+00+F2              ; Select Pixel 2   40ns
3274      Y:000216 Y:000216                   DC      VIDEO+PAD_TIM+%0111               ; Pad Delay -         640ns
3275      Y:000217 Y:000217                   DC      VIDEO+ADC_TIM+%0111               ; Hold A/D convert     1000ns
3276      Y:000218 Y:000218                   DC      VIDEO+STL_TIM+%1101               ; Move A/D data FIFO     40ns
3277      Y:000219 Y:000219                   DC      VIDEO+0000000+%0101               ; Settling time           40ns
3278      Y:00021A Y:00021A                   DC      VIDEO+SXM_TIM+%0101               ; Settling time        3880ns
3279      Y:00021B Y:00021B                   DC      VIDEO+STP_TIM+%0111               ; Stop Reseting      40ns
3280      Y:00021C Y:00021C                   DC      VIDEO+INT_TIM+%0110               ; Integrate Pixel 3    1000ns
3281      Y:00021D Y:00021D                   DC      VIDEO+$000000+%0111               ; Stop Integration       40ns
3282      Y:00021E Y:00021E                   DC      VIDEO+ADC_CNV+%0011               ; Start A/D convert      40ns
3283      Y:00021F Y:00021F                   DC      CLK3+DTW+FSYNC+F1+F2              ; Deselect Pixel 3   360ns
3284                                END_RD_NTX_PIPELINE
3285   
3286                                RD_NTX
3287      Y:000220 Y:000220                   DC      END_RD_NTX-RD_NTX-1
3288      Y:000221 Y:000221                   DC      CLK3+000+FSYNC+F1+00              ; Select Pixel 2 (40ns)
3289      Y:000222 Y:000222                   DC      VIDEO+PAD_TIM+%0111               ; Pad Delay - 40ns
3290      Y:000223 Y:000223                   DC      VIDEO+ADC_TIM+%0111               ; Hold A/D convert sig Pixel 1 (1us)
3291      Y:000224 Y:000224                   DC      VIDEO+STL_TIM+%1101               ; Move A/D data to FIFO Pixel 1 (40ns)
3292      Y:000225 Y:000225                   DC      VIDEO+0000000+%0101               ; Settling time           40ns
3293      Y:000226 Y:000226                   DC      VIDEO+SXM_TIM+%0101               ; Settling time (480ns)
3294      Y:000227 Y:000227                   DC      VIDEO+STP_TIM+%0111               ; Stop Reseting
Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  CLOCK_READOUT.waveforms  Page 57



3295      Y:000228 Y:000228                   DC      VIDEO+INT_TIM+%0110               ; Integrate Pixel 2 (760ns)
3296      Y:000229 Y:000229                   DC      VIDEO+$000000+%0111               ; Stop Integration
3297      Y:00022A Y:00022A                   DC      VIDEO+ADC_CNV+%0011               ; Start A/D convert Pixel 2 (400ns)
3298      Y:00022B Y:00022B                   DC      CLK3+DTW+FSYNC+F1+F2              ; Deselect Pixel 1 (240ns)
3299      Y:00022C Y:00022C                   DC      CLK3+000+FSYNC+00+F2              ; Select Pixel 3 (40ns)
3300      Y:00022D Y:00022D                   DC      VIDEO+PAD_TIM+%0111               ; Pad Delay - 40ns
3301      Y:00022E Y:00022E                   DC      VIDEO+ADC_TIM+%0111               ; Hold A/D convert sig Pixel 2 (1us)
3302      Y:00022F Y:00022F                   DC      VIDEO+STL_TIM+%1101               ; Move A/D data to FIFO Pixel 2 (40ns)
3303      Y:000230 Y:000230                   DC      VIDEO+0000000+%0101               ; Settling time           40ns
3304      Y:000231 Y:000231                   DC      VIDEO+SXM_TIM+%0101               ; Settling time (480ns)
3305      Y:000232 Y:000232                   DC      VIDEO+STP_TIM+%0111               ; Stop Reseting
3306      Y:000233 Y:000233                   DC      VIDEO+INT_TIM+%0110               ; Integrate Pixel 3 (760ns)
3307      Y:000234 Y:000234                   DC      VIDEO+$000000+%0111               ; Stop Integration
3308      Y:000235 Y:000235                   DC      VIDEO+ADC_CNV+%0011               ; Start A/D convert Pixel 3 (400ns)
3309      Y:000236 Y:000236                   DC      CLK3+DTW+FSYNC+F1+F2              ; Deselect Pixel 3 (240ns)
3310                                END_RD_NTX
3311   
3312                                LAST_NTX_8INROW
3313      Y:000237 Y:000237                   DC      END_LAST_NTX_8INROW-LAST_NTX_8INROW
3314      Y:000238 Y:000238                   DC      CLK3+000+FSYNC+F1+00              ; Select Pixel 2 (40ns)
3315      Y:000239 Y:000239                   DC      VIDEO+PAD_TIM+%0111               ; Pad Delay - 40ns
3316      Y:00023A Y:00023A                   DC      VIDEO+ADC_TIM+%0111               ; Hold A/D convert sig Pixel 1 (1us)
3317      Y:00023B Y:00023B                   DC      VIDEO+STL_TIM+%1101               ; Move A/D data to FIFO Pixel 1 (40ns)
3318      Y:00023C Y:00023C                   DC      VIDEO+0000000+%0101               ; Settling time           40ns
3319      Y:00023D Y:00023D                   DC      VIDEO+SXM_TIM+%0101               ; Settling time (480ns)
3320      Y:00023E Y:00023E                   DC      VIDEO+STP_TIM+%0111               ; Stop Reseting
3321      Y:00023F Y:00023F                   DC      VIDEO+INT_TIM+%0110               ; Integrate Pixel 2 (760ns)
3322      Y:000240 Y:000240                   DC      VIDEO+$000000+%0111               ; Stop Integration
3323      Y:000241 Y:000241                   DC      VIDEO+ADC_CNV+%0011               ; Start A/D convert Pixel 2 (40+40ns)
3324      Y:000242 Y:000242                   DC      CLK3+DTW+FSYNC+F1+F2              ; Deselect Pixel 1 (240ns)
3325                                END_LAST_NTX_8INROW
3326   
3327   
3328   
3329   
3330   
3331   
3332   
3333   
3334   
3335   
3336   
3337   
3338   
3339   
3340   
3341   
3342   
3343   
3344   
3345   
3346   
3347                                 END_APPLICATON_Y_MEMORY
3348      000243                              EQU     @LCV(L)
3349   
3350                                ; End of program
3351                                          END

0    Errors
0    Warnings


Motorola DSP56300 Assembler  Version 6.3.4   22-05-06  22:00:05  tim.asm  Page 58



