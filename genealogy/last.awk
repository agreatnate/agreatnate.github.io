
# Remove Previous & Next buttons
/<a onclick="history.go/ {
             getline;
             if (/a onclick="history.go/) {
                getline; 
             }
          }

# Add space between names and source numbers
/<td class="ColumnValue">/ {
              print;
              getline;
              if (/<a href="#sref/) {
                 sub(/<a href=/, "</td>\n						<td class="ColumnValue">&");
              }
          }
               
# Remove headers on Places page
/"ColumnState">State\/ Province/ { getline; }

/"ColumnCountry">Country/ { getline; }

{
    print;
}
