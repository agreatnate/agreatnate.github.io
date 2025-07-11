
/class="ColumnState">&nbsp;/ { getline; }

/class="ColumnCountry">&nbsp;/ { getline; }

/title="Private">/ {
                      for (i = 0; i < 10; i++) {
                         getline;
                      }
                   }


{
   print;
}
