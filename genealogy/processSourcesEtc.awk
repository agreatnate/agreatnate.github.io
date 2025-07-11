BEGIN {
            FS = " ";
            mainPerson = "";
            isFemale = 0;
}

/<title>/ {
            line = $0;
            sub(/	<title>Nathan McNew&#8217;s Genealogy - /,"",line);
            sub(/<\/title>/,"",line);
            mainPerson = line;
            if (length(mainPerson) > 12) {
               cnt = split(mainPerson, pieces, " ");
               mainPerson = pieces[1];
            }
          }

/>Gender</{
             print;
             getline;
             gender = $0
             isFemale = index($0, "female");
          }

/>Partner</ {
             if (isFemale) {
                sub(/Partner/, "Husband");
             } else {
                sub(/Partner/, "Wife");
             }
          }

/>Age at Death</ {
             print;
             getline;
             if (/>about /) {
               sub(/, [0-9]+ days/, "");
             }
          }

/Relation to main person/ {
          sub(/Relation to main person/, "Relation to " mainPerson);
          }

/Relation to the center person/ {
             sub(/Relation to the center person (Nathan McNew)/, "Relation to Nathan McNew");
          }

# Remove pointless hyperlink of Family line back to same page
/title="Family of / {
             sub(/<a href="" title="Family of .*">/,"");
             sub(/<\/a>/,"");
          }

# Remove hyplerlink to "Private" place
/html" title="Private">/ {
           getline; # Delete a href=... hyper link
           print;   # Print "Private" place
           getline; # Delete closing hyperlink </a>
           getline;
        }

/Harvey Simeon\./ { sub(/Harvey Simeon\./, "Harvey Simeon"); }

# Skip printing "DEFN .... Person Name" line.x  This is a 23 line long block  with ONE internal "Column Event"> line
/				DEFN/ {
           colEvtCnt = 0;
           do {
              getline;
              if (/class="ColumnEvent">/ )
                  ++colEvtCnt;
           } while( ! /class="ColumnEvent">/ || colEvtCnt < 2)
           getline;
        }

# Process all lists of source numbers
/ <a href="#sref/ {
           # If line has multiple source numbers parse to remove duplicates and sort
           if (index($0, "<a href") > 0) {
              split($0, srcNums, "<a href");
              maxsrc = 0;
              line = "";
              end = "";
              for (i in srcNums) {
                 num = srcNums[i];
                 if (index(num, "#sref")) {
                   sub( /="#sref[0-9]+[a-c]*\">/, "", num);
                   sub( /[a-c]*<\/a.*/, "", num);
                   if (! (num in Pieces)) {
                     gsub(/[1-9][a-c]/, "&XZX", srcNums[i]);
                     gsub(/[a-c]XZX/, "", srcNums[i]);
                     Pieces[num] = srcNums[i];
                     if (num > maxsrc)
                        maxsrc = num;
                   } else {
                      more = srcNums[i];
                      sub(/.*\/a>/, "", more);
                      if (length(more) > 0) {
                         end = more;
                      }
                   }
                 }
                 else {
                    Pieces[0] = num;
                 }
              }
              Pieces[num] = Pieces[num] " ";

              # Recreate the line
              for (i = 0; i <= maxsrc; i++) {
                 if (i in Pieces) {
                    if (i == 0) {
                       line = Pieces[0];
                    } else {
                       if (i < maxsrc) {
                          sub( /<\/a/, ",&", Pieces[i]);   # Add a comma between source numbers
                       }
                       line = line "<a href" Pieces[i];
                    }
                 }
              }
              sub(/ $/, "", line);
              print line end;
              for (i in Pieces ) {
                 delete Pieces[i];
              }
              getline;
           }
        }

/<h4>Source References/ {
           # Print this source section title and the following ordered list (<ol>) start line
           print; getline; print;

           # Read until the closing ordered list tag (</ol>) is found, skipping internal unwanted sub lists
           while (! /<\/ol>/ ) {
              getline;
              if ( /<ol>/ ) {
                 do {
                    getline;
                 } while (! /<\/ol>/ );
                 getline;
              } else {
                 print;
              }
           }
        }


#  PRINT THE INPUT LINE
{
	print $0;
}
