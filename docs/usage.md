# How the package works:
1. Initialization
```
as_pdf.init;
```

2. Define page format
```
as_pdf.set_page_format('A4');
```

3. Define page orientation
```
as_pdf.set_page_orientation('P');
```

4. Define margins
```
as_pdf.set_margins(90, 10, 10, 10, 'mm');
```
Margins are defined in order Top, Left, Bottom, Right, measure unit.
This margins are valid only for data table or body of document.

5. Define Header and Footer procedure
```
as_pdf.set_page_proc(varchar2 o clob);
```
(see above for procedure explanation)

6. Define columns formats (array or type as_pdf.tp_columns)

7. Define SQL code for query

8. Execute query2table or query2labels
(see above for parameter definition)

9. Optionally repeat from 6 with other query

10. Execute save_pdf o get_pdf for saving the file or get blob content.
