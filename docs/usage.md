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
* `#PAGE_NR#`, that at runtime contains current page number,
* `#PAGE_COUNT#`, that at runtime contains the total number of pages,
* `§`, useful when you call procedures and functions that are defined in this package, this substitution variable will reduce the changes when you rename the package.

This procedure will be executed from finish_pdf, which in turn is executed by save_pdf or get_pdf, which are used respectively to save the PDF file or to obtain the blob with the content of the PDF document.

In other words just before saving, when we already know the total number of pages, it executes a loop for each page that invokes all blocks of code in the same order that they were defined.

There is no distinction between header and footer, it depends on the coordinates used in this procedure.

The margins defined with set_margins haven’t effect for this procedure.

## query2table
This procedure uses the result of a query to print a datagrid.

The parameters are:
Parameter | Description
--- | ---
query | is the query to execute       
formats | is an array of columns formats
colors | is an array of Hex RGB colors, for header and data table with odd/even evidentiation (can be a varchar2 list of comma separated Hex RGB colors)
hRowHeight | is forced header height, if null it’s calculated, if 0 the header isn’t drawn
tRowHeight | is forced record height, if null it’s calculated depending on contained data
um | is the measure unit used for specify heights and coordinates
startX | is the offset between the defined margin and the left border of the table
breakField | Check columns from 1 to BreakColumn for detect breakings, 0 test is disabled
interline | 
startY | is the offset between the defined margin and the top border of the table
frame | is border around format
bulk_size | 

## query2labels
This procedure uses the result of a query to print record into an array of labels, similar to a mailing list address.

The parameters are:
Parameter | Description
--- | ---
query | is the query to execute
formats | is an array of columns formats
colors | is an array of Hex RGB colors, for header and data table with odd/even evidentiation (can be a varchar2 list of comma separated Hex RGB colors)
hRowHeight | is forced header height, if null it’s calculated, if 0 the header isn’t drawn
tRowHeight | is forced record height, if null it’s calculated depending on contained data
um | is the measure unit used for specify heights and coordinates
startX | is the offset between the defined margin and the left border of the table
labelDef | is type defined record that contains label definition, each measure unit is in pt
interline | 
startY | is the offset between the defined margin and the top border of the table
frame | is border around format

The parameters for label definition are:
Parameter | Description
--- | ---
MaxColumns | is the number of label columns in a page
MaxRows | is the number of label rows in a page
Width | is the width of each label
Height | is the height of each label
hDistance | is the horizontal distance between right border and left border of two labels
vDistance | is the vertical distance between bottom border and top border of two labels