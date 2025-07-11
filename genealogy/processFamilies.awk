BEGIN {
            FS = " ";
      }

/<h4>Families</ {
            idx = 0;
            tblCnt = 0;
            do {
               lines[++idx] = $0;
               getline;

               # rm fixed_subtbles, this streches lines out to the right margin
               sub(/ fixed_subtables/, "", $0);
               if (!hasMarried) {
                  hasMarried = index($0, ">Married<");
               }
               if (/>Partner</ || />Wife</ || />Husband</) {
                  spouseLn = idx;
               }
               if (!hasChildren) {
                  hasChildren = index($0, ">Children<");
               }
               if (/<table/)
                 ++tblCnt;
               if (/<\/table/)
                 --tblCnt;
            } while (tblCnt > 0);

#            Not needed if remove all fixed_subtable ?
#            if (hasChildren && spouseLn) {
#               sub(/"ColumnValue">/, "\"ColumnValue\" colspan=\"2\">", lines[spouseLn+1]);
#            }

            for (wrIdx = 0; wrIdx < idx; ) {
               # if No "Married" column before spouse add a blank colmn to move Spouse, Childrena, et. closer to the following table
               if (wrIdx == spouseLn && !hasMarried && hasChildren) {
                  print "						<td class="ColumnType">&nbsp;</td>"
               }
               print lines[++wrIdx];
            }
         }

#  PRINT THE OTHER LINES
      {
 	  print $0;
      }
