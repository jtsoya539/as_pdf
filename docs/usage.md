## Basic usage
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
Margins are defined in order Top, Left, Bottom, Right, and measure unit.
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

## set_margins
It defines margins for data table, or for body of document.  
The parameters are in order Top, Left, Bottom, Right, and measure unit.  
Default values are: 3, 1, 4, 1, 'cm'.  

## set_page_proc
It defines the code that will be executed at every page change.  
This procedure accepts as parameter a varchar2 or a clob, that contains the code that will be executed dinamically as an execute immediate.  
Each time the procedure is called, the code will be appended to an array, so you can define multiple blocks of code that will be executed in the same order that they were defined.  
In the code you can use 3 substitution variables:
* #PAGE_NR# that at runtime contains current page number,
* #PAGE_COUNT#, that at runtime contains the total number of pages,
* §, useful when you call procedures and functions that are defined in this package, this substitution variable will reduce the changes when you rename the package.

This procedure will be executed from finish_pdf, which in turn is executed by save_pdf or get_pdf, which are used respectively to save the PDF file or to obtain the blob with the content of the PDF document.

In other words just before saving, when we already know the total number of pages, it executes a loop for each page that invokes all blocks of code in the same order that they were defined.

There are no distinction between header and footer, it depends on te coordinate used into procedure.
The margins defined with set_margins haven’t effect for this procedure.
