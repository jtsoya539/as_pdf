create or replace package as_pdf3_v5 is
/* ****************************************************************************
**
** Author: Anton Scheffer
** Date: 11-04-2012
** Website:  http://technology.amis.nl
** See also: http://technology.amis.nl/?p=17718
**
** Changelog:
**   Date: 16-04-2012
**     changed code for parse_png
**   Date: 15-04-2012
**     only dbms_lob.freetemporary for temporary blobs
**   Date: 11-04-2012
**     Initial release of as_pdf3
**
******************************************************************************
** Author: Valerio Rossetti
** Date: 27-07-2012
** Website:  http://valeriorossetti.blogspot.it/
** This post: http://valeriorossetti.blogspot.it/2014/07/aspdf3v5-new-features-versione-italiana.html
**
** Changelog:
** Date: 27-07-2012                    Version:  0.3.5.00
**   type tp_column                    :Formatting each heder and table columns
**   query2table and refcursor2table Added parameters
**     p_formats (table of tp_columns) :Define column's and header formats
**     (width, font, style, size, aligment, numberformat, colors, ...)
**     p_colors                        :9 default colors, including odd/even lines
**     p_hRowHeight                    :minimum header row height
**     p_dRowHeight                    :minimum table  row height
**     p_pm                            :measurement unit
**     p_startX                        :start X position for table (indent it)
**     p_BreakField                    :check break from filed 1 to p_BreakField (0 none)
**   Add function BorderType           :translate border string TBLR into nuber 0-15
**   Add function to word wrap lines that exceeds column width
**   Add Procedure LogoCoop that print Logo on Upper Left corner
**
** Date: 10-06-2014                    Version:  0.3.5.01
**   +Multirow Record Added:
**    offsetX                          OffsetX from left border of table,
**                                     reset it when change row
**    cellRow                          Row where cell are printed, use strinct sequence
**    hCHeight / tCHeight              Cella Height              (header e table)
**  +Selective Border Added:
**    function BorderType('TBLR')      convert literal into 4 bit bynary
**    hBorder  / tBorder               4 bit bynanry border settimg 0 no border
**
** Data: 10-07-2014                    Version:  0.3.5.02
**   some bug fixes in text alignment
**   +offsetY                          OffsetY from Top side of record block
**   +LabelMode                        Print Records as row/col stickers
**
** Date: 18-09-2014                    Version:  0.3.5.03
**   bugfix and impovement suggested by Giuseppe Polo
**   +query2table                      added Interline parameter
**    setCellFont                      bugfix for Header
** Date: 26-09-2014                    Version:  0.3.5.04
**   bugfix for recursive call of function Write
** Date: 29-09-2014                    Version:  0.3.5.05
**   +query2table                      added pFrame parameter ex:  'L=2pt; C=FF0000'
**                                     where L=Linesize and C=rgb hex colour
**   +query2table                      p_colors also accept CSV string of colors rdb colours
**   +set_Language                     Set language for error messages. (English, Italian)
**   +put_image                        add parameters p_cellWidth, p_cellheight
**   +Columns can contain blob IMAGE
**   +FullJustify Alignment            for write & query2table
**
** Date: 25-11-2014                    Version:  0.3.5.06
**   bugfix for query with more than 200 records
**   +query2table and cursor2table     Add optional parameter p_bulk_size:=200 (Buffer size)
**                                     if = 0 buffer is autodetected, but query runs 2 times!
** Date: 24-06-2015                    Version:  0.3.5.07
**   BugFix query2table                Reset rowHeith when RowHeight Min or Exacat as specified
** Date: 30-06-2015                    Version:  0.3.5.08
**   BugFix PrepareRecord              Fix problem with rowHeight
** Date: 26-08-2015                    Version:  0.3.5.09
**   BugFix colorTable                 Fix problem with undefined collection
**   WARNING! if you change package name, propertly set g_package variabile
** Date: 14-12-2015                    Version:  0.3.5.10
**   Bugix in PrepareRecord
** Date: 11-05-2016                    Version:  0.3.5.11
**   Bugfix error when calling with null colours
**   colorTable changed and moved before query2Table
**   query2table & query2label changed
**   when calling query2table you must use empty string '' instead of null for p_colors parameter
** date; 06-09-2016                    Versioen; 0.3.5.12
**   Bugfix error in recursive call of write procedure, um must be in pt
**
******************************************************************************
Copyright (C) 2012 by Anton Scheffer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

******************************************************************************
*/


  c_get_page_width     constant pls_integer := 0;
  c_get_page_height    constant pls_integer := 1;
  c_get_margin_top     constant pls_integer := 2;
  c_get_margin_right   constant pls_integer := 3;
  c_get_margin_bottom  constant pls_integer := 4;
  c_get_margin_left    constant pls_integer := 5;
  c_get_x              constant pls_integer := 6;
  c_get_y              constant pls_integer := 7;
  c_get_fontsize       constant pls_integer := 8;
  c_get_current_font   constant pls_integer := 9;
  c_get_current_fcolor constant pls_integer :=10;
  c_get_current_bcolor constant pls_integer :=11;
  -- Set default colours ternary (ink,paper and border)
  -- Header   = Black/Cyan/Black
  -- evenRows = Black/White/Black
  -- oddRows  = Black/Light Gray/Black
  c_dft_colours        constant varchar2(64):='000000,e0ffff,000000,000000,ffffff,000000,000000,d0d0d0,000000';

-- Decimal separator used in the text
  g_vDP VARCHAR2(1):= CASE WHEN instr(to_char(15/10),'.') = 0 THEN ',' ELSE '.' END;

  g_Language varchar2(1):='E';

--
  function file2blob( p_dir varchar2, p_file_name varchar2 )
  return blob;
--
  function conv2uu( p_value number, p_unit varchar2 )
  return number;
--
  procedure set_Language(p_vNewValue in varchar2:='E');
--
  procedure set_page_size
    ( p_width  number
    , p_height number
    , p_unit   varchar2 := 'cm'
    );
--
  procedure set_page_format( p_format varchar2 := 'A4' );
--
  procedure set_page_orientation( p_orientation varchar2 := 'PORTRAIT' );
--
  procedure set_margins
    ( p_top    number := null
    , p_left   number := null
    , p_bottom number := null
    , p_right  number := null
    , p_unit   varchar2 := 'cm'
    );
--
  procedure set_info
    ( p_title    varchar2 := null
    , p_author   varchar2 := null
    , p_subject  varchar2 := null
    , p_keywords varchar2 := null
    );
--
  procedure init;
--
  function get_pdf
  return blob;
--
  procedure save_pdf
    ( p_dir      varchar2 := 'PDF'
    , p_filename varchar2 := 'my.pdf'
    , p_freeblob boolean := true
    );
--
  procedure txt2page( p_txt varchar2 );
--
  procedure put_txt(p_x number, p_y number, p_txt varchar2,
                    p_degrees_rotation NUMBER := NULL,
                    p_um VARCHAR2 := 'pt'  -- Add by ValR
                    );
  procedure put_txt(p_um VARCHAR2 := 'pt',
                    p_x number, p_y number, p_txt varchar2,
                    p_degrees_rotation NUMBER := NULL
                    );
  procedure g_put_txt( p_x VARCHAR2, p_y VARCHAR2, p_txt varchar2,
                     p_degrees_rotation number := NULL);
--
  function str_len( p_txt varchar2 )
  return number;
--
-- ValR Chiamata alternativa, con unit? di misura all'inizio
  procedure write
    ( p_txt in VARCHAR2
    , p_um VARCHAR :='pt'
    , p_x in number := null
    , p_y in number := null
    , p_line_height in number := null
    , p_start in number := null -- left side of the available text box
    , p_width in number := null -- width of the available text box
    , p_alignment in varchar2 := NULL
    );
--
  procedure set_font
    ( p_index pls_integer
    , p_fontsize_pt number
    , p_output_to_doc boolean := true
    );
--
  function set_font
    ( p_fontname varchar2
    , p_fontsize_pt number
    , p_output_to_doc boolean := true
    )
  return pls_integer;
--
  procedure set_font
    ( p_fontname varchar2
    , p_fontsize_pt number
    , p_output_to_doc boolean := true
    );
--
  function set_font
    ( p_family varchar2
    , p_style varchar2 := 'N'
    , p_fontsize_pt number := null
    , p_output_to_doc boolean := true
    )
  return pls_integer;
--
  procedure set_font
    ( p_family varchar2
    , p_style varchar2 := 'N'
    , p_fontsize_pt number := null
    , p_output_to_doc boolean := true
    );
--
  procedure set_font_style(p_style varchar2 := 'N');
--
  procedure new_page;
--
  function load_ttf_font
    ( p_font blob
    , p_encoding varchar2 := 'WINDOWS-1252'
    , p_embed boolean := false
    , p_compress boolean := true
    , p_offset number := 1
    )
  return pls_integer;
--
  procedure load_ttf_font
    ( p_font blob
    , p_encoding varchar2 := 'WINDOWS-1252'
    , p_embed boolean := false
    , p_compress boolean := true
    , p_offset number := 1
    );
--
  function load_ttf_font
    ( p_dir varchar2 := 'MY_FONTS'
    , p_filename varchar2 := 'BAUHS93.TTF'
    , p_encoding varchar2 := 'WINDOWS-1252'
    , p_embed boolean := false
    , p_compress boolean := true
    )
  return pls_integer;
--
  procedure load_ttf_font
    ( p_dir varchar2 := 'MY_FONTS'
    , p_filename varchar2 := 'BAUHS93.TTF'
    , p_encoding varchar2 := 'WINDOWS-1252'
    , p_embed boolean := false
    , p_compress boolean := true
    );
--
  procedure load_ttc_fonts
    ( p_ttc blob
    , p_encoding varchar2 := 'WINDOWS-1252'
    , p_embed boolean := false
    , p_compress boolean := true
    );
--
  procedure load_ttc_fonts
    ( p_dir varchar2 := 'MY_FONTS'
    , p_filename varchar2 := 'CAMBRIA.TTC'
    , p_encoding varchar2 := 'WINDOWS-1252'
    , p_embed boolean := false
    , p_compress boolean := true
    );
--
  procedure set_color( p_rgb varchar2 := '000000' );
--
  procedure set_color
    ( p_red number := 0
    , p_green number := 0
    , p_blue number := 0
    );
--
  procedure set_bk_color( p_rgb varchar2 := 'ffffff' );
--
  procedure set_bk_color
    ( p_red number := 0
    , p_green number := 0
    , p_blue number := 0
    );
--
  procedure horizontal_line
    ( p_x in number
    , p_y in number
    , p_width in number
    , p_line_width in number := 0.5
    , p_line_color in varchar2 := '000000'
    );
  procedure horizontal_line
    ( p_x VARCHAR2
    , p_y VARCHAR2
    , p_width VARCHAR2
    , p_line_width VARCHAR2 := '0.5pt'
    , p_line_color varchar2 := '000000'
    );
--
  procedure vertical_line
    ( p_x in number
    , p_y in number
    , p_height in number
    , p_line_width in number := 0.5
    , p_line_color in varchar2 := '000000'
    );
  procedure vertical_line
    ( p_x VARCHAR2
    , p_y VARCHAR2
    , p_height VARCHAR2
    , p_line_width VARCHAR2 := '0.5pt'
    , p_line_color varchar2 := '000000'
    );

--
  procedure rect
    ( p_x in number
    , p_y in number
    , p_width in number
    , p_height in number
    , p_line_color in varchar2 := null
    , p_fill_color in varchar2 := null
    , p_line_width in number := 0.5
    );

  procedure rect
    ( p_x VARCHAR2
    , p_y VARCHAR2
    , p_width VARCHAR2
    , p_height VARCHAR2
    , p_line_color varchar2 := null
    , p_fill_color varchar2 := null
    , p_line_width VARCHAR2 := '0.5pt'
    );
--
  function get_ParamPT(p_vString   IN VARCHAR2,
                       p_vXY IN VARCHAR2 DEFAULT 'Y') RETURN NUMBER;

  function get( p_what in pls_integer )
  return number;
--
procedure put_image
    ( p_img blob
    , p_x number
    , p_y number
    , p_width number := null
    , p_height number := null
    , p_align varchar2 := 'center'
    , p_valign varchar2 := 'top'
    , p_um VARCHAR:='pt'
  --ITA:  Nuovi parametri per Larghezza e Altezza Cella
  --ENG:  New parameter for cell Width & Height
    , p_cellWidth number:=null
    , p_cellHeight number:=null
  );
--
  procedure put_image
    ( p_dir varchar2
    , p_file_name varchar2
    , p_x number
    , p_y number
    , p_width number := null
    , p_height number := null
    , p_align varchar2 := 'center'
    , p_valign varchar2 := 'top'
    , p_um VARCHAR:='pt'
    );
--
  procedure put_image
    ( p_url varchar2
    , p_x number
    , p_y number
    , p_width number := null
    , p_height number := null
    , p_align varchar2 := 'center'
    , p_valign varchar2 := 'top'
    , p_um VARCHAR:='pt'
    );

  Function BorderType(p_vBorder in varchar2) return number;
--
  procedure set_page_proc( p_src clob );
  procedure set_page_proc( p_src VARCHAR2 );
--
  type tp_col_widths is table of number;
  type tp_headers    is table of varchar2(32767);
  type tp_formats    is table of varchar2(32767);
  type tp_colors     is table of varchar2(6); -- Array of 6 varchar (2 color triads)
  type tp_colors9    is table of varchar2(9); -- Array of 9 varchar (3 color triads)
  type tp_column IS RECORD (    --Columns format
     colLabel    VARCHAR2(100), --Column Label - Intestazione Colonna
     colWidth    NUMBER,        --Column Width - Larghezza colonna (mm)
     offsetX     number,        --X position of Column - Force X from LEFT side
     offsetY     number,        --Y position of Column - Force Y position from TOP
                                --  how many [um] move down from top border of data row
                                -- (this value is subtracted from y)
     cellRow     INTEGER,       --Column's row for "multirow record"
     -- Header formatting
     hFontName   VARCHAR2(100), --Font Family as Helvetica - Times-Roman
     hFontStyle  VARCHAR2(2),   --Font Style as Bold / Italic ecc
     hFontSize   NUMBER,        --Font Size in pt
     hFontColor  VARCHAR2(6),   --ink color
     hBackColor  VARCHAR2(6),   --paper color
     hLineColor  VARCHAR2(6),   --border color
     hLineSize   NUMBER,        --Border Thickness; 0 no border
     hBorder     number(2),     --Side of border to drow 0-15 (binary mode TBLR see BorderType function)
     hAlignment  VARCHAR2(1),   --Horizontal Alignment Left, Center, Right, Justified
     hAlignVert  VARCHAR2(1),   --Vertical   Alignment Top , Middle, Bottom
     hTMargin    NUMBER,        --Top    Margin
     hBMargin    NUMBER,        --Bottom Margin
     hLMargin    NUMBER,        --Left   Margin
     hRMargin    NUMBER,        --Right  Margin
     hCHeight    number,        --Cell Height (mm); Default is rowHeight
     -- Table formatting
     tFontName   VARCHAR2(100), --Font Family as Helvetica - Times-Roman
     tFontStyle  VARCHAR2(2),   --Font Style as Bold / Italic ecc
     tFontSize   NUMBER,        --Font Size in pt
     tFontColor  VARCHAR2(6),   --ink color
     tBackColor  VARCHAR2(6),   --paper color
     tLineColor  VARCHAR2(6),   --border color
     tLineSize   NUMBER,        --Border Thickness; 0 no border
     tBorder     number(2),     --Side of border to drow 0-15 (binary mode TBLR see BorderType function)
     tAlignment  VARCHAR2(1),   --Horizontal Alignment Left, Center, Right, Justified
     tAlignVert  VARCHAR2(1),   --Vertical   Alignment Top , Middle, Bottom
     tTMargin    NUMBER,        --Top    Margin
     tBMargin    NUMBER,        --Bottom Margin
     tLMargin    NUMBER,        --Left   Margin
     tRMargin    NUMBER,        --Right  Margin
     tCHeight    number,        --Cell Height (mm); Default is rowHeight
     tNumFormat  VARCHAR2(100),  --Number or Date Format : Default TM9 o dd.mm.yyyy

     vSpacing    VARCHAR2(10),  --Spacing bewteen lines in pt, font%, mm
     vInterline  VARCHAR2(10),  --Interline in pt, font%, mm. Override vSpacing if defined
     hSpacing    VARCHAR2(10),  --Header Spacing bewteen lines in pt, font%, mm
     hInterline  VARCHAR2(10),  --Header Interline in pt, font%, mm. Override vSpacing if defined

     -- Calculate values
     cSpacing      NUMBER,      --Spacing in pt
     cInterline    NUMBER,      --Interline in pt
     cTextArea     NUMBER       --Max text width in column

     ,ctSpacing    NUMBER       --Spacing in pt
     ,ctInterline  NUMBER       --Interline in pt
     ,ctTextArea   NUMBER       --Max text width in column
     ,chSpacing    NUMBER       --Spacing in pt
     ,chInterline  NUMBER       --Interline in pt
     ,chTextArea   NUMBER       --Max text width in column

     );
  TYPE tp_columns IS TABLE OF tp_column;

  TYPE tp_labeldef is record (
      MaxColumns   PLS_INTEGER  -- Number of Label Columns in a sheet
     ,MaxRows      PLS_INTEGER  -- Number of Label Rows    in a sheet
     ,Width        NUMBER       -- Label Width  in pt
     ,Height       NUMBER       -- Label Height in pt
     ,hDistance    NUMBER       -- Horizontal distance between two labels in pt
     ,vDistance    NUMBER       -- Vertical   distance between two labels in pt
  );
  g_labeldef tp_labeldef;

  type tp_CellRowText      is table of varchar2(400) INDEX BY BINARY_INTEGER;
  type tp_CellRowTextX     is table of NUMBER        INDEX BY BINARY_INTEGER;
  type tp_CellRowTextY     is table of NUMBER        INDEX BY BINARY_INTEGER;
  type tp_CellRowTextWidth is table of NUMBER        INDEX BY BINARY_INTEGER;
  type tp_CellRowHeight    is table of NUMBER        INDEX BY BINARY_INTEGER;

  TYPE tp_Cell IS RECORD (             -- Content of the cell
     cX            NUMBER,             -- Left side
     cY            NUMBER,             -- Bottom side
     cYbase        NUMBER,             -- Baseline of cell row
     cTextHeight   NUMBER,             -- Text Height of all text rows
     cRowsCount    NUMBER,             -- Number of text rows
     cTy           NUMBER,             -- Text distance of firts row from top side
     cWidth        NUMBER,             -- Cell Width  (pt)
     cHeight       NUMBER,             -- Cell Height (pt)
     cRowText      tp_CellRowText,     -- array of text
     cRowTextX     tp_CellRowTextX,    -- array of distance from left side
     cRowTextY     tp_CellRowTextY,    -- array of distance from cTy
     cRowTextWidth tp_CellRowTextWidth,-- array of text width
     cImage        BLOB                -- blob of image
     );
  TYPE tp_Cells IS TABLE OF tp_Cell INDEX BY BINARY_INTEGER; -- Array of cells in a data row
--
  procedure query2table
    ( p_query      varchar2
    , p_formats    tp_columns :=null
    , p_colors     tp_colors  :=null --Default Colors
    , p_hRowHeight NUMBER     :=null --Autodetect
    , p_tRowHeight NUMBER     :=null --Autodetect
    , p_um         VARCHAR2   :='pt' --
    , p_startX     number     := 0   -- Distance from left border
    , p_BreakField number     := 0   -- No Break
    , p_Interline  number     :=1.2
    , p_startY     number     := 0   -- Distance from top border
    , p_Frame      varchar2   :=null -- Border Around format
    , p_bulk_size  pls_integer:= 200
    );
  PROCEDURE query2table
    ( p_query      VARCHAR2
    , p_formats    tp_columns :=null
    , p_colors     varchar2   :=NULL -- colour list CSV
    , p_hRowHeight NUMBER     :=NULL
    , p_tRowHeight NUMBER     :=NULL
    , p_um         VARCHAR2   :='pt'
    , p_startX     number     := 0
    , p_BreakField number     := 0
    , p_Interline  number     :=1.2
    , p_startY     number     := 0   -- Distance from top border
    , p_Frame      varchar2   :=null -- Border Around format
    , p_bulk_size  pls_integer:= 200
    );

  PROCEDURE query2Labels
    ( p_query      VARCHAR2
    , p_formats    tp_columns :=null
    , p_colors     tp_colors  :=NULL
    , p_hRowHeight NUMBER     :=NULL
    , p_tRowHeight NUMBER     :=NULL
    , p_um         VARCHAR2   :='pt'
    , p_startX     number     := 0
    , p_labelDef   tp_labeldef
    , p_Interline  number     :=1.2
    , p_startY     number     := 0   -- Distance from top border
    , p_Frame      varchar2   :=null -- Border Around format
    );
  PROCEDURE query2Labels
    ( p_query      VARCHAR2
    , p_formats    tp_columns :=null
    , p_colors     varchar2   :=NULL -- colour list CSV
    , p_hRowHeight NUMBER     :=NULL
    , p_tRowHeight NUMBER     :=NULL
    , p_um         VARCHAR2   :='pt'
    , p_startX     number     := 0
    , p_labelDef   tp_labeldef
    , p_Interline  number     :=1.2
    , p_startY     number     := 0   -- Distance from top border
    , p_Frame      varchar2   :=null -- Border Around format
    );
--
$IF not DBMS_DB_VERSION.ver_le_10 $THEN
  procedure refcursor2table
    ( p_rc          sys_refcursor
    , p_formats     tp_columns  :=null
    , p_colors      tp_colors   :=null
    , p_hRowHeight  NUMBER      :=null
    , p_tRowHeight  NUMBER      :=null
    , p_um          VARCHAR2    :='pt'
    , p_startX      NUMBER      := 0
    , p_BreakField  number      := 0
    , p_Interline   number      :=1.2
    , p_startY      NUMBER      := 0
    , p_Frame       varchar2    :=null -- Border Around format
    , p_bulk_size   pls_integer := 200
    );
$END
$IF not DBMS_DB_VERSION.ver_le_10 $THEN
  procedure refcursor2label
    ( p_rc          sys_refcursor
    , p_formats     tp_columns  :=null
    , p_colors      tp_colors   :=null
    , p_hRowHeight  NUMBER      :=null
    , p_tRowHeight  NUMBER      :=null
    , p_um          VARCHAR2    :='pt'
    , p_startX      NUMBER      := 0
    , p_labelDef    tp_labeldef
    , p_Interline   number      :=1.2
    , p_startY      NUMBER      := 0
    , p_Frame       varchar2    :=null -- Border Around format
    , p_bulk_size   pls_integer := 200
    );
$END

/* these examples are provided by Anton Sheffer

-- SAMPLE 1 -- MINIMAL
begin
  as_pdf3_v5.init;
  as_pdf3_v5.write( 'Minimal usage' );
  as_pdf3_v5.save_pdf;
end;

-- SAMPLE 2 -- Text Positioning
begin
  as_pdf3_v5.init;
  as_pdf3_v5.write( 'Some text with a newline-character included at this place.' );
  as_pdf3_v5.write( 'Normally text written with as_pdf3_v5.write() is appended after the previous text. But the text wraps automaticly to a new line.' );
  as_pdf3_v5.write( 'If you insert LF (\n) the text go to new line.' );
  as_pdf3_v5.write( 'But you can place your text at any place', -1, 700 );
  as_pdf3_v5.write( 'you want', 100, 650 );
  as_pdf3_v5.write( 'You can even align it, left, right, or centered', p_y => 600, p_alignment => 'right' );
  as_pdf3_v5.save_pdf;
end;
-- SAMPLE 3 -- Using Fonts
declare
  k_vSampeText CONSTANT varchar2(100):='The quick brown fox jumps over the lazy dog. 1234567890';
begin
  as_pdf3_v5.init;
  as_pdf3_v5.write( 'The 14 standard PDF-fonts and the WINDOWS-1252 encoding.' );
  as_pdf3_v5.set_font( 'helvetica' );
  as_pdf3_v5.write( 'helvetica, normal: ' ||  k_vSampeText, -1, 700 );
  as_pdf3_v5.set_font( 'helvetica', 'I' );
  as_pdf3_v5.write( 'helvetica, italic: ' ||  k_vSampeText, -1, -1 );
  as_pdf3_v5.set_font( 'helvetica', 'b' );
  as_pdf3_v5.write( 'helvetica, bold: ' ||  k_vSampeText, -1, -1 );
  as_pdf3_v5.set_font( 'helvetica', 'BI' );
  as_pdf3_v5.write( 'helvetica, bold italic: ' ||  k_vSampeText, -1, -1 );
  as_pdf3_v5.set_font( 'times' );
  as_pdf3_v5.write( 'times, normal: ' ||  k_vSampeText, -1, 625 );
  as_pdf3_v5.set_font( 'times', 'I' );
  as_pdf3_v5.write( 'times, italic: ' ||  k_vSampeText, -1, -1 );
  as_pdf3_v5.set_font( 'times', 'b' );
  as_pdf3_v5.write( 'times, bold: ' ||  k_vSampeText, -1, -1 );
  as_pdf3_v5.set_font( 'times', 'BI' );
  as_pdf3_v5.write( 'times, bold italic: ' ||  k_vSampeText, -1, -1 );
  as_pdf3_v5.set_font( 'courier' );
  as_pdf3_v5.write( 'courier, normal: ' ||  k_vSampeText, -1, 550 );
  as_pdf3_v5.set_font( 'courier', 'I' );
  as_pdf3_v5.write( 'courier, italic: ' ||  k_vSampeText, -1, -1 );
  as_pdf3_v5.set_font( 'courier', 'b' );
  as_pdf3_v5.write( 'courier, bold: ' ||  k_vSampeText, -1, -1 );
  as_pdf3_v5.set_font( 'courier', 'BI' );
  as_pdf3_v5.write( 'courier, bold italic: ' ||  k_vSampeText, -1, -1 );
--
  as_pdf3_v5.set_font( 'courier' );
  as_pdf3_v5.write( 'symbol:', -1, 475 );
  as_pdf3_v5.set_font( 'symbol' );
  as_pdf3_v5.write(  k_vSampeText, -1, -1 );
  as_pdf3_v5.set_font( 'courier' );
  as_pdf3_v5.write( 'zapfdingbats:', -1, -1 );
  as_pdf3_v5.set_font( 'zapfdingbats' );
  as_pdf3_v5.write(  k_vSampeText, -1, -1 );
--
  as_pdf3_v5.set_font( 'times', 'N', 20 );
  as_pdf3_v5.write( 'times, normal with fontsize 20pt', -1, 400 );
  as_pdf3_v5.set_font( 'times', 'N', 6 );
  as_pdf3_v5.write( 'times, normal with fontsize 5pt', -1, -1 );
  as_pdf3_v5.save_pdf;
end;
-- SAMPLE 4 -- Using TrueType Fonts
declare
  x pls_integer;
begin
  as_pdf3_v5.init;
  as_pdf3_v5.write( 'But others fonts and encodings are possible using TrueType fontfiles.' );
  x := as_pdf3_v5.load_ttf_font( 'MY_FONTS', 'refsan.ttf', 'CID', p_compress => false );
  as_pdf3_v5.set_font( x, 12  );
  as_pdf3_v5.write( 'The Windows MSReference SansSerif font contains a lot of encodings, for instance', -1, 700 );
  as_pdf3_v5.set_font( x, 15  );
  as_pdf3_v5.write( 'Albanian: Kush mund t? lexoni k?t? di?ka si kjo', -1, -1 );
  as_pdf3_v5.write( 'Croatic: Tko mo?e citati to ne?to poput ovoga', -1, -1 );
  as_pdf3_v5.write( 'Russian: ??? ????? ????????? ??? ???-?? ????? ?????', -1, -1);
  as_pdf3_v5.write( 'Greek: ????? ?p??e? ?a d?a??se? a?t? t? ??t? sa? a?t?', -1, -1 );
--
  as_pdf3_v5.set_font( 'helvetica', 12  );
  as_pdf3_v5.write( 'Or by using a  TrueType collection file (ttc).', -1, 600 );
  as_pdf3_v5.load_ttc_fonts( 'MY_FONTS',  'cambria.ttc', p_embed => true, p_compress => false );
  as_pdf3_v5.set_font( 'cambria', 15 );   -- font family
  as_pdf3_v5.write( 'Anton, testing 1,2,3 with Cambria', -1, -1 );
  as_pdf3_v5.set_font( 'CambriaMT', 15 );  -- fontname
  as_pdf3_v5.write( 'Anton, testing 1,2,3 with CambriaMath', -1, -1 );
  as_pdf3_v5.save_pdf;
end;
-- SAMPLE 5 -- Lines
begin
  as_pdf3_v5.init;
  for i in 1 .. 10
  loop
    as_pdf3_v5.horizontal_line( 30, 700 - i * 15, 100, i );
  end loop;
  for i in 1 .. 10
  loop
    as_pdf3_v5.vertical_line( 150 + i * 15, 700, 100, i );
  end loop;
  for i in 0 .. 255
  loop
    as_pdf3_v5.horizontal_line( 330, 700 - i, 100, 2, p_line_color =>  to_char( i, 'fm0x' ) || to_char( i, 'fm0x' ) || to_char( i, 'fm0x' ) );
  end loop;
  as_pdf3_v5.save_pdf;
end;
-- SAMPLE 6 -- LOGO from Varchar2
declare
  t_logo varchar2(32767) :=
'/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkS' ||
'Ew8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJ' ||
'CQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIy' ||
'MjIyMjIyMjIyMjIyMjL/wAARCABqAJYDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEA' ||
'AAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIh' ||
'MUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6' ||
'Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZ' ||
'mqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx' ||
'8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREA' ||
'AgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAV' ||
'YnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hp' ||
'anN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPE' ||
'xcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD3' ||
'+iiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAoorifiX4pk' ||
'8PaCILR9t9eExxsOqL/E315AHuaUmkrs1oUZVqipw3ZU8X/FCz0KeSw02Jb2+Thy' ||
'WxHGfQkdT7D8686ufih4suGJW/jgXssUC8fnk1ydvbz3lzHb28bzTyttRF5LMa7H' ||
'Uvh+3hvRI9T1+7kUPIsf2ezUMykgnlmIHbtXI5znqtj66ng8DhFGFRJyffVv5Fnw' ||
'r8QfEEvinTodR1N5rSaYRyIyIAd3A5A9SK7X4qeINV0Gz019LvGtmlkcOVVTkADH' ||
'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';
begin
  as_pdf3_v5.init;
  as_pdf3_v5.put_image( to_blob( utl_encode.base64_decode( utl_raw.cast_to_raw( t_logo ) ) )
                   , 0
                   , as_pdf3_v5.get( as_pdf3_v5.C_GET_PAGE_HEIGHT ) - 260
                   , as_pdf3_v5.get( as_pdf3_v5.C_GET_PAGE_WIDTH )
                   );
  as_pdf3_v5.write( 'jpg, gif and png images are supported.' );
  as_pdf3_v5.write( 'And because PDF 1.3 (thats the format I use) doesn''t support alpha channels, neither does AS_PDF.', -1, -1 );
  as_pdf3_v5.save_pdf;
end;

-- SAMPLE 7 -- Watermark
declare
  t_rc sys_refcursor;
  t_query varchar2(1000);
begin
  as_pdf3_v5.init;
  as_pdf3_v5.load_ttf_font( 'MY_FONTS', 'COLONNA.TTF', 'CID' );
  as_pdf3_v5.set_page_proc( q'~
    begin
      as_pdf3_v5.set_font( 'helvetica', 8 );
      as_pdf3_v5.put_txt( 10, 15, 'Page #PAGE_NR# of "PAGE_COUNT#' );
      as_pdf3_v5.set_font( 'helvetica', 12 );
      as_pdf3_v5.put_txt( 350, 15, 'This is a footer text' );
      as_pdf3_v5.set_font( 'helvetica', 'B', 15 );
      as_pdf3_v5.put_txt( 200, 780, 'This is a header text' );
      as_pdf3_v5.put_image( 'MY_DIR', 'amis.jpg', 500, 15 );
   end;~' );
  as_pdf3_v5.set_page_proc( q'~
    begin
      as_pdf3_v5.set_font( 'Colonna MT', 'N', 50 );
      as_pdf3_v5.put_txt( 150, 200, 'Watermark Watermark Watermark', 60 );
   end;~' );
  t_query := 'select rownum, sysdate + level, ''example'' || level from dual connect by level <= 50';
  as_pdf3_v5.query2table( t_query );
  open t_rc for t_query;
  as_pdf3_v5.refcursor2table( t_rc );
  as_pdf3_v5.save_pdf;
end;
*/
end;
/