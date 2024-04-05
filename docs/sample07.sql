declare
  t_rc sys_refcursor;
  t_query varchar2(1000);
begin
  as_pdf.init;
  as_pdf.load_ttf_font( 'MY_FONTS', 'COLONNA.TTF', 'CID' );
  as_pdf.set_page_proc( q'~
    begin    
      as_pdf.set_font( 'helvetica', 8 );
      as_pdf.put_txt( 10, 15, 'Page #PAGE_NR# of "PAGE_COUNT#' );
      as_pdf.set_font( 'helvetica', 12 );
      as_pdf.put_txt( 350, 15, 'This is a footer text' );
      as_pdf.set_font( 'helvetica', 'B', 15 );
      as_pdf.put_txt( 200, 780, 'This is a header text' );
      as_pdf.put_image( 'MY_DIR', 'amis.jpg', 500, 15 );
   end;~' );
  as_pdf.set_page_proc( q'~
    begin    
      as_pdf.set_font( 'Colonna MT', 'N', 50 );
      as_pdf.put_txt( 150, 200, 'Watermark Watermark Watermark', 60 );
   end;~' ); 
  t_query := 'select rownum, sysdate + level, ''example'' || level from dual connect by level <= 50'; 
  as_pdf.query2table( t_query );
  open t_rc for t_query;
  as_pdf.refcursor2table( t_rc );
  --as_pdf.save_pdf;
  :pdf := as_pdf.get_pdf;
end;
