/* Stored Procedure for testing as_pdf

   you can call this test 
   vr_test1('STANDARD');  -- Normal mode
   vr_test1('BREAK');     -- Break table on first column
   vr_test1('LABEL');     -- Label mode
   vr_test1('FREE');      -- Free position of each fields
   
*/
declare
--create or replace procedure vr_test1(p_vMode in varchar2) is
-- Created on 25/06/2014 by VALR
        p_vMode        VARCHAR2(10) := :mode;
        i              INTEGER;
        v_vFileName    VARCHAR2(255);
        v_vOddColor    VARCHAR2(6) := 'd0d0d0';
        v_vHeadColor   VARCHAR2(6) := 'e0ffff';
        v_vOraDir      VARCHAR2(50) := 'PDF';
        v_vPageProc    VARCHAR2(32000);
        r_Fmt  as_pdf.tp_columns:=as_pdf.tp_columns();
        r_Label as_pdf.tp_labeldef ;
        v_vSQL varchar2(4000);
begin
  v_vFileName    := 'Test_as_pdf.pdf';
  -- Define Sheet Format
  as_pdf.init;
  as_pdf.set_page_format('A4');
  as_pdf.set_page_orientation('P');
  as_pdf.set_margins(30, 10, 15, 10, 'mm');
      
  -- Define Header and Footer
  v_vPageProc := q'[
  begin
    §.set_font('helvetica', 'B', 10 );
    §.put_txt('mm',  5, 5, 'Valerio Rossetti');
    §.put_txt('mm',  90, 5, 'Data: ');
    §.set_font('helvetica', 'N', 10);
    §.put_txt('mm', 115,5, ']'||to_char(sysdate,'dd/mm/yy')||q'[');   
    §.put_txt('mm', 175,5, 'Page #PAGE_NR# of #PAGE_COUNT#');
  end;
  ]';
      
  as_pdf.set_page_proc(v_vPageProc);
   
  --If you use barcode font, remove comment
  --as_pdf.load_ttf_font('PDF', 'ean13.ttf', 'CID', TRUE);
 
    -- Define column format
    case 
      when upper(p_vMode) in ('FREE','LABEL') then
        begin
          r_fmt.extend(8);
          i:=1; -- (riga di rottura
          r_fmt(i).colWidth:=25;
          r_fmt(i).colLabel:='cod mkt';
          r_fmt(i).hFontStyle:='B';
          r_fmt(i).hFontSize:=10;
          r_fmt(i).hAlignment:='C';
          r_fmt(i).hAlignVert:='T';
          r_fmt(i).tAlignment:='L';
          r_fmt(i).tAlignVert:='B';
          r_fmt(i).tFontSize:=8;
          r_fmt(i).tCHeight := 7;
          r_fmt(i).cellRow := i;
           
          i:=i+1;--2
          r_fmt(i).colWidth:=20;
          r_fmt(i).colLabel:='cod_art';
          r_fmt(i).hFontStyle:='B';
          r_fmt(i).hFontSize:=10;
          r_fmt(i).hAlignment:='R';
          r_fmt(i).hAlignVert:='T';
          r_fmt(i).tAlignVert:='T';
          r_fmt(i).cellRow := i;
           
          i:=i+1;--3
          r_fmt(i).colWidth:=12;
          r_fmt(i).colLabel:='udm V';
          r_fmt(i).hFontStyle:='B';
          r_fmt(i).hFontSize:=10;
          r_fmt(i).hAlignment:='C';
          r_fmt(i).hAlignVert:='T';
          r_fmt(i).tAlignment:='C';
          r_fmt(i).tAlignVert:='B';
          r_fmt(i).tBorder := as_pdf.BorderType('TB');
          r_fmt(i).cellRow := i;
           
          i:=i+1;--4
          r_fmt(i).colWidth:=15;
          r_fmt(i).colLabel:='udm Lt';
          r_fmt(i).hFontStyle:='B';
          r_fmt(i).hFontSize:=10;
          r_fmt(i).hAlignment:='C';
          r_fmt(i).hAlignVert:='T';
          r_fmt(i).tAlignment:='C';
          r_fmt(i).tAlignVert:='B';
          r_fmt(i).cellRow := i;
           
          i:=i+1;--5
          r_fmt(i).colWidth:=20;
          r_fmt(i).colLabel:='prz. vend.';
          r_fmt(i).hFontStyle:='B';
          r_fmt(i).hFontSize:=10;
          r_fmt(i).hAlignment:='C';
          r_fmt(i).hAlignVert:='T';
          r_fmt(i).tAlignment:='R';
          r_fmt(i).tAlignVert:='B';
          r_fmt(i).offsetX := 60;
          r_fmt(i).offsetY := 10;
          r_fmt(i).cellRow := i;
          
          i:=i+1;--6
          r_fmt(i).colWidth:=80;
          r_fmt(i).colLabel:='des art';
          r_fmt(i).hFontStyle:='B';
          r_fmt(i).hFontSize:=10;
          r_fmt(i).hAlignment:='L';
          r_fmt(i).hAlignVert:='T';
          r_fmt(i).tAlignment:='L';
          r_fmt(i).tAlignVert:='C';
          r_fmt(i).tFontSize:=8;
          r_fmt(i).offsetX := 0;
          r_fmt(i).offsetY := 15;
          r_fmt(i).tCHeight := 8;
          r_fmt(i).tBorder := as_pdf.BorderType('LRBT');
          r_fmt(i).cellRow := i;
          
          i:=i+1;--7
          r_fmt(i).colWidth:=20;
          r_fmt(i).colLabel:='logo';
          r_fmt(i).hFontStyle:='B';
          r_fmt(i).hFontSize:=10;
          r_fmt(i).hAlignment:='L';
          r_fmt(i).hAlignVert:='T';
          r_fmt(i).tAlignment:='L';
          r_fmt(i).tAlignVert:='C';
          r_fmt(i).tFontSize:=8;
          r_fmt(i).offsetX := 40;
          r_fmt(i).offsetY := 20;
          r_fmt(i).tCHeight := 20;
          r_fmt(i).cellRow:=3;
          r_fmt(i).tBorder := 15;
          r_fmt(i).tNumFormat:='w=-1,h=20mm,A=C,V=C';
          r_fmt(i).cellRow := i;
          
          i:=i+1;--8
          r_fmt(i).colWidth:=40;
          r_fmt(i).colLabel:='des logo';
          r_fmt(i).hFontStyle:='B';
          r_fmt(i).hFontSize:=10;
          r_fmt(i).hAlignment:='L';
          r_fmt(i).hAlignVert:='T';
          r_fmt(i).tAlignment:='L';
          r_fmt(i).tAlignVert:='C';
          r_fmt(i).tFontSize:=8;
          r_fmt(i).tCHeight := 8;
          r_fmt(i).cellRow:=3;
          r_fmt(i).offsetX := 60;
          r_fmt(i).offsetY := 20;
          r_fmt(i).tBorder := as_pdf.BorderType('LRBT');
          r_fmt(i).cellRow := i;
        end;

        v_vSQL := q'[
        SELECT cod_mkt,
               c_art,
               udm_vendita,
               udm_listino,
               prz_vendita,
               des_art,
               logo,
               descrizione
        from (      
              SELECT case when rownum <5 then '5201001' else '5201003' end cod_mkt,
                     rownum*1000+rownum*124 c_art,
                     'N'  udm_vendita,
                     'KG' udm_listino,
                     round(dbms_random.value(40,2),2) prz_vendita,
                     'ARTICOLO '||to_char(rownum*1000+rownum*124) des_art,
                     'G'||lpad(rownum,2,'0') tipo
                FROM DUAL d CONNECT BY ROWNUM <= 5
        ) left join (
              SELECT 'G'||lpad(rownum,2,'0') tipo,
                     'LOGO '||'G'||lpad(rownum,2,'0') descrizione,
                     'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAIAQMAAAD+wSzIAAAABlBMVEX///+/v7+jQ3Y5AAAADklEQVQI12P4AIX8EAgALgAD/aNpbtEAAAAASUVORK5CYII' logo
                FROM DUAL d CONNECT BY ROWNUM <= 5
        ) using (tipo)
        order by 1
           ]';
      else
        begin
          r_fmt.extend(9);
          i:=1; -- (riga di rottura
          r_fmt(i).colWidth:=25;
          r_fmt(i).colLabel:='cod mkt';
          r_fmt(i).hFontStyle:='B';
          r_fmt(i).hFontSize:=10;
          r_fmt(i).hAlignment:='C';
          r_fmt(i).hAlignVert:='T';
          r_fmt(i).tAlignment:='L';
          r_fmt(i).tAlignVert:='B';
          r_fmt(i).tFontSize:=8;
          r_fmt(i).tCHeight := 7;
          r_fmt(i).hCHeight := 7;
          r_fmt(i).cellRow := 1;
           
          i:=i+1;--2
          r_fmt(i).colWidth:=20;
          r_fmt(i).colLabel:='cod_art';
          r_fmt(i).hFontStyle:='B';
          r_fmt(i).hFontSize:=10;
          r_fmt(i).hAlignment:='R';
          r_fmt(i).hAlignVert:='T';
          r_fmt(i).tAlignVert:='T';
          --r_fmt(i).offsetX := 0;
          r_fmt(i).tCHeight := 7;
          r_fmt(i).hCHeight := 7;
           
          i:=i+1;--3
          r_fmt(i).colWidth:=22;
          r_fmt(i).colLabel:='pz imb';
          r_fmt(i).hFontStyle:='B';
          r_fmt(i).hFontSize:=10;
          r_fmt(i).hAlignment:='C';
          r_fmt(i).hAlignVert:='T';
          r_fmt(i).tAlignment:='R';
          r_fmt(i).tAlignVert:='M';
           
          i:=i+1;--4
          r_fmt(i).colWidth:=12;
          r_fmt(i).colLabel:='udm V';
          r_fmt(i).hFontStyle:='B';
          r_fmt(i).hFontSize:=10;
          r_fmt(i).hAlignment:='C';
          r_fmt(i).hAlignVert:='T';
          r_fmt(i).tAlignment:='C';
          r_fmt(i).tAlignVert:='B';
          r_fmt(i).tBorder := as_pdf.BorderType('TB');
           
          i:=i+1;--5
          r_fmt(i).colWidth:=15;
          r_fmt(i).colLabel:='udm Lt';
          r_fmt(i).hFontStyle:='B';
          r_fmt(i).hFontSize:=10;
          r_fmt(i).hAlignment:='C';
          r_fmt(i).hAlignVert:='T';
          r_fmt(i).tAlignment:='C';
          r_fmt(i).tAlignVert:='B';
           
          i:=i+1;--6
          r_fmt(i).colWidth:=20;
          r_fmt(i).colLabel:='prz. vend.';
          r_fmt(i).hFontStyle:='B';
          r_fmt(i).hFontSize:=10;
          r_fmt(i).hAlignment:='C';
          r_fmt(i).hAlignVert:='T';
          r_fmt(i).tAlignment:='R';
          r_fmt(i).tAlignVert:='B';
          i:=i+1;--7
          r_fmt(i).colWidth:=20;
          r_fmt(i).colLabel:='prz. cost';
          r_fmt(i).hFontStyle:='B';
          r_fmt(i).hFontSize:=10;
          r_fmt(i).hAlignment:='C';
          r_fmt(i).hAlignVert:='T';
          r_fmt(i).tAlignment:='R';
          r_fmt(i).tAlignVert:='B';
          i:=i+1;--8
          r_fmt(i).colWidth:=16;
          r_fmt(i).colLabel:='margin';
          r_fmt(i).hFontStyle:='B';
          r_fmt(i).hFontSize:=10;
          r_fmt(i).hAlignment:='C';
          r_fmt(i).hAlignVert:='T';
          r_fmt(i).tAlignment:='R';
          r_fmt(i).tAlignVert:='B';
          r_fmt(i).tBorder := 15;
          i:=i+1;--9
          r_fmt(i).colWidth:=150;
          r_fmt(i).colLabel:='product descrition';
          r_fmt(i).hFontStyle:='B';
          r_fmt(i).hFontSize:=10;
          r_fmt(i).hAlignment:='L';
          r_fmt(i).hAlignVert:='T';
          r_fmt(i).hCHeight := 8;
          r_fmt(i).tAlignment:='L';
          r_fmt(i).tAlignVert:='C';
          r_fmt(i).tFontSize:=8;
          r_fmt(i).offsetX := 0;
          r_fmt(i).tCHeight := 8;
          r_fmt(i).cellRow:=2;
          r_fmt(i).tBorder := as_pdf.BorderType('LRBT');
     
        end;        
          

        v_vSQL := q'[
        SELECT cod_mkt,
               c_art,
               pcs_imb,
               udm_vend,
               udm_list,
               prz_vend,
               prz_vend*.8 prz_cost,
               prz_vend*.2 margin,
               description
        from (      
        SELECT case when rownum <5 then '5201001' else '5201003' end cod_mkt,
                     rownum*1000+rownum*124 c_art,
                     (trunc(rownum/3)+1)*4  pcs_imb,
                     'N'  udm_vend,
                     'KG' udm_list,
                     round(dbms_random.value(40,2),2) prz_vend,
                     round(dbms_random.value(8,2),2)  margin,
                     'ART '||to_char(rownum*1000+rownum*124) description
                FROM DUAL d CONNECT BY ROWNUM <= 10
        )
        order by 1
           ]';
    end case;     
   dbms_output.put_line(v_vSQL);
   

case upper(p_vMode)
  when 'LABEL' then
   r_Label.MaxColumns:=2;
   r_Label.MaxRows:=4;
   r_Label.Width:=as_pdf.get_ParamPT('80mm');
   r_Label.Height:=as_pdf.get_ParamPT('60mm');
   r_Label.hDistance:=as_pdf.get_ParamPT('5mm');
   r_Label.hDistance:=as_pdf.get_ParamPT('5mm');
          
   as_pdf.query2Labels(v_vSQL,
     r_fmt,
     as_pdf.tp_colors('000000',v_vHeadColor,'000000',
                          '000000','ffffff','000000',
                          '000000',v_vOddColor,'000000'),
     0, 60 ,'mm', 0, r_Label
     );

  when 'FREE' then
   as_pdf.query2table(v_vSQL,
     r_fmt,
     as_pdf.tp_colors('000000',v_vHeadColor,'000000',
                          '000000','ffffff','000000',
                          '000000',v_vOddColor,'000000'),
     0, 60 ,'mm', 0, 0
     );
  when 'BREAK' then
   as_pdf.query2table(v_vSQL,
     r_fmt,
     as_pdf.tp_colors('000000',v_vHeadColor,'000000',
                          '000000','ffffff','000000',
                          '000000',v_vOddColor,'000000'),
     15,15, 'mm',0, 1
     );

  else --'STANDARD' then

   as_pdf.query2table(v_vSQL,
     r_fmt,
     '',
     15,15, 'mm',0, 0
     );
     
  end case;          

  --as_pdf.save_pdf(v_vOraDir, v_vFileName, TRUE);
  :pdf := as_pdf.get_pdf;
 
end;
