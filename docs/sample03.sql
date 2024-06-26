begin
  as_pdf.init;
  as_pdf.write( 'The 14 standard PDF-fonts and the WINDOWS-1252 encoding.' );
  as_pdf.set_font( 'helvetica' );
  as_pdf.write( 'helvetica, normal: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, 700 );
  as_pdf.set_font( 'helvetica', 'I' );
  as_pdf.write( 'helvetica, italic: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
  as_pdf.set_font( 'helvetica', 'b' );
  as_pdf.write( 'helvetica, bold: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
  as_pdf.set_font( 'helvetica', 'BI' );
  as_pdf.write( 'helvetica, bold italic: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
  as_pdf.set_font( 'times' );
  as_pdf.write( 'times, normal: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, 625 );
  as_pdf.set_font( 'times', 'I' );
  as_pdf.write( 'times, italic: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
  as_pdf.set_font( 'times', 'b' );
  as_pdf.write( 'times, bold: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
  as_pdf.set_font( 'times', 'BI' );
  as_pdf.write( 'times, bold italic: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
  as_pdf.set_font( 'courier' );
  as_pdf.write( 'courier, normal: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, 550 );
  as_pdf.set_font( 'courier', 'I' );
  as_pdf.write( 'courier, italic: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
  as_pdf.set_font( 'courier', 'b' );
  as_pdf.write( 'courier, bold: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
  as_pdf.set_font( 'courier', 'BI' );
  as_pdf.write( 'courier, bold italic: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
--
  as_pdf.set_font( 'courier' );
  as_pdf.write( 'symbol:', -1, 475 );
  as_pdf.set_font( 'symbol' );
  as_pdf.write( 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
  as_pdf.set_font( 'courier' );
  as_pdf.write( 'zapfdingbats:', -1, -1 );
  as_pdf.set_font( 'zapfdingbats' );
  as_pdf.write( 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
--
  as_pdf.set_font( 'times', 'N', 20 );
  as_pdf.write( 'times, normal with fontsize 20pt', -1, 400 );
  as_pdf.set_font( 'times', 'N', 6 );
  as_pdf.write( 'times, normal with fontsize 5pt', -1, -1 );
  --as_pdf.save_pdf;
  :pdf := as_pdf.get_pdf;
end;
