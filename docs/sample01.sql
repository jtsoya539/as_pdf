begin
  as_pdf.init;
  as_pdf.write( 'Minimal usage' );
  --as_pdf.save_pdf;
  :pdf := as_pdf.get_pdf;
end;
