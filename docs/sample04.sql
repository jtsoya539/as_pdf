declare
  x pls_integer;
begin
  as_pdf.init;
  as_pdf.write( 'But others fonts and encodings are possible using TrueType fontfiles.' );
  x := as_pdf.load_ttf_font( 'MY_FONTS', 'refsan.ttf', 'CID', p_compress => false );
  as_pdf.set_font( x, 12  );
  as_pdf.write( 'The Windows MSReference SansSerif font contains a lot of encodings, for instance', -1, 700 );
  as_pdf.set_font( x, 15  );
  as_pdf.write( 'Albanian: Kush mund të lexoni këtë diçka si kjo', -1, -1 );
  as_pdf.write( 'Croatic: Tko može čitati to nešto poput ovoga', -1, -1 );
  as_pdf.write( 'Russian: Кто может прочитать это что-то вроде этого', -1, -1);
  as_pdf.write( 'Greek: Ποιος μπορεί να διαβάσει αυτό το κάτι σαν αυτό', -1, -1 );
--
  as_pdf.set_font( 'helvetica', 12  );
  as_pdf.write( 'Or by using a TrueType collection file (ttc).', -1, 600 );
  as_pdf.load_ttc_fonts( 'MY_FONTS',  'cambria.ttc', p_embed => true, p_compress => false );
  as_pdf.set_font( 'cambria', 15 );   -- font family
  as_pdf.write( 'Anton, testing 1,2,3 with Cambria', -1, -1 );
  as_pdf.set_font( 'CambriaMT', 15 );  -- fontname
  as_pdf.write( 'Anton, testing 1,2,3 with CambriaMath', -1, -1 );
--
  as_pdf.set_font( 'helvetica', 12 );
  as_pdf.write( 'Or if you need to generate a PDF report in Chinese:', -1, 520 );
  as_pdf.set_font( as_pdf.load_ttf_font( 'MY_DIR', 'simfang.ttf', 'CID', p_compress => false ), 12 );
  as_pdf.write( 'Chinese: 在中国的一个简单的句子', -1, -1 );
--
  --as_pdf.save_pdf;
  :pdf := as_pdf.get_pdf;
end;
