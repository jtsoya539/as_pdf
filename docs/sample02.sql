begin
  as_pdf.init;
  as_pdf.write( 'Some text with a newline-character included at this "
" place.' );
  as_pdf.write( 'Normally text written with as_pdf.write() is appended after the previous text. But the text wraps automatically to a new line.' );
  as_pdf.write( 'But you can place your text at any place', -1, 700 );
  as_pdf.write( 'you want', 100, 650 );
  as_pdf.write( 'You can even align it, left, right, or centered', p_y => 600, p_alignment => 'right' );
  --as_pdf.save_pdf;
  :pdf := as_pdf.get_pdf;
end;
