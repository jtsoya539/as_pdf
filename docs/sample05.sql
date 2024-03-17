begin
  as_pdf.init;
  for i in 1 .. 10
  loop
    as_pdf.horizontal_line( 30, 700 - i * 15, 100, i );
  end loop;
  for i in 1 .. 10
  loop
    as_pdf.vertical_line( 150 + i * 15, 700, 100, i );
  end loop;
  for i in 0 .. 255
  loop
    as_pdf.horizontal_line( 330, 700 - i, 100, 2, p_line_color =>  to_char( i, 'fm0x' ) || to_char( i, 'fm0x' ) || to_char( i, 'fm0x' ) );
  end loop;
  as_pdf.save_pdf;
end;
