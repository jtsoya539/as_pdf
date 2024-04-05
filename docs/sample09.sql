DECLARE
  t_text VARCHAR2(32767);
BEGIN
  as_pdf.init;

  FOR a IN (SELECT NULL alignment_code, 'default' alignment_desc
              FROM dual
            UNION ALL
            SELECT 'L', 'left'
              FROM dual
            UNION ALL
            SELECT 'R', 'right'
              FROM dual
            UNION ALL
            SELECT 'C', 'centered'
              FROM dual
            UNION ALL
            SELECT 'J', 'justified'
              FROM dual) LOOP
    SELECT listagg(word, ' ') within GROUP(ORDER BY word) words
      INTO t_text
      FROM (SELECT dbms_random.string('a', dbms_random.value(4, 30)) word
              FROM dual
            CONNECT BY LEVEL <= 50) x;
  
    as_pdf.set_font('helvetica', 20);
    as_pdf.write(a.alignment_desc || ' alignment:');
    as_pdf.write(utl_tcp.crlf);
  
    as_pdf.set_font('helvetica', 12);
    as_pdf.write(t_text, p_alignment => a.alignment_code);
    as_pdf.write(utl_tcp.crlf || utl_tcp.crlf);
  END LOOP;

  --as_pdf.save_pdf;
  :pdf := as_pdf.get_pdf;
END;
