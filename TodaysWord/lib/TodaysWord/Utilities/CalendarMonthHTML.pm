package TodaysWord::Utilities::CalendarMonthHTML;
use Moose;
use namespace::autoclean;

=head1 NAME

TodaysWord::Utilities::CalendarMonthHTML 

=head1 DESCRIPTION

Calendar wrapper module

=head1 METHODS

=cut

$HTML::CalendarMonthSimple::VERSION = "1.25";
use Date::Calc;

# Adapted from HTML::CalendarMonthSimple.pm
# Generate HTML calendars. An alternative to HTML::CalendarMonth
# Herein, the symbol $self is used to refer to the object that's being passed around.


# Within the constructor is the only place where values are access directly.
# Methods are provided for accessing/changing values, and those methods
# are used even internally.
# Most of the constructor is assigning default values.
sub init {
   my $self = shift;
   my $the_year = shift;
   my $the_month = shift;
   # figure out the current date (which may be specified as today_year, et al
   # then figure out which year+month we're supposed to display
   {
      my($year,$month,$date) = Date::Calc::Today();
      $self->{'today_year'}  = $self->{'today_year'} || $year;
      $self->{'today_month'} = $self->{'today_month'} || $month;
      $self->{'today_date'}  = $self->{'today_date'} || $date;
      $self->{'month'}       = $the_month;
      $self->{'year'}        = $the_year;
      $self->{'monthname'}   = Date::Calc::Month_to_Text($self->{'month'});
   }

   # Some defaults
   $self->{'border'}             = 5;
   $self->{'width'}              = '100%';
   $self->{'showdatenumbers'}    = 1;
   $self->{'showweekdayheaders'} = 1;
   $self->{'cellalignment'}      = 'left';
   $self->{'vcellalignment'}     = 'top';
   $self->{'weekdayheadersbig'}  = 1;
   $self->{'nowrap'}             = 0;

   $self->{'weekdays'} = [qw/Mon Tue Wed Thu Fri/];
   $self->{'sunday'}   = "Sun";
   $self->{'saturday'} = "Sat";

   # Set the default calendar header
   $self->{'header'} = sprintf("<center><font size=\"+2\">%s %d</font></center>",
                               Date::Calc::Month_to_Text($self->{'month'}),$self->{'year'});

   # Initialize the (empty) cell content so the keys are representative of the month
   foreach my $datenumber ( 1 .. Date::Calc::Days_in_Month($self->{'year'},$self->{'month'}) ) {
      $self->{'content'}->{$datenumber}          = '';
      $self->{'datecellclass'}->{$datenumber}    = '';
      $self->{'datecolor'}->{$datenumber}        = '';
      $self->{'datebordercolor'}->{$datenumber}  = '';
      $self->{'datecontentcolor'}->{$datenumber} = '';
      $self->{'href'}->{$datenumber}             = '';
   }
}

sub as_HTML {
   my $self = shift;
   my %params = @_;
   my $html = '';
   my(@days,$weeks,$WEEK,$DAY);

   # To make the grid even, pad the start of the series with 0s
   @days = (1 .. Date::Calc::Days_in_Month($self->year(),$self->month() ) );
   if ($self->weekstartsonmonday()) {
       foreach (1 .. (Date::Calc::Day_of_Week($self->year(),
                                              $self->month(),1) -1 )) {
          unshift(@days,0);
       }
   }
   else {
       foreach (1 .. (Date::Calc::Day_of_Week($self->year(),
                                              $self->month(),1)%7) ) {
          unshift(@days,0);
       }
   }
   $weeks = int((scalar(@days)+6)/7);
   # And pad the end as well, to avoid "uninitialized value" warnings
   foreach (scalar(@days)+1 .. $weeks*7) {
      push(@days,0);
   }

   # Define some scalars for generating the table
   my $border = $self->border();
   my $tablewidth = $self->width();
   $tablewidth =~ m/^(\d+)(\%?)$/; my $cellwidth = (int($1/7))||'14'; if ($2) { $cellwidth .= '%'; }
   my $header = $self->header();
   my $cellalignment = $self->cellalignment();
   my $vcellalignment = $self->vcellalignment();
   my $contentfontsize = $self->contentfontsize();
   my $bgcolor = $self->bgcolor();
   my $weekdaycolor = $self->weekdaycolor() || $self->bgcolor();
   my $weekendcolor = $self->weekendcolor() || $self->bgcolor();
   my $todaycolor = $self->todaycolor() || $self->bgcolor();
   my $contentcolor = $self->contentcolor() || $self->contentcolor();
   my $weekdaycontentcolor = $self->weekdaycontentcolor() || $self->contentcolor();
   my $weekendcontentcolor = $self->weekendcontentcolor() || $self->contentcolor();
   my $todaycontentcolor = $self->todaycontentcolor() || $self->contentcolor();
   my $bordercolor = $self->bordercolor() || $self->bordercolor();
   my $weekdaybordercolor = $self->weekdaybordercolor() || $self->bordercolor();
   my $weekendbordercolor = $self->weekendbordercolor() || $self->bordercolor();
   my $todaybordercolor = $self->todaybordercolor() || $self->bordercolor();
   my $weekdayheadercolor = $self->weekdayheadercolor() || $self->bgcolor();
   my $weekendheadercolor = $self->weekendheadercolor() || $self->bgcolor();
   my $headercontentcolor = $self->headercontentcolor() || $self->contentcolor();
   my $weekdayheadercontentcolor = $self->weekdayheadercontentcolor() || $self->contentcolor();
   my $weekendheadercontentcolor = $self->weekendheadercontentcolor() || $self->contentcolor();
   my $headercolor = $self->headercolor() || $self->bgcolor();
   my $cellpadding = $self->cellpadding();
   my $cellspacing = $self->cellspacing();
   my $sharpborders = $self->sharpborders();
   my $cellheight = $self->cellheight();
   my $cellclass = $self->cellclass();
   my $tableclass = $self->tableclass();
   my $weekdaycellclass = $self->weekdaycellclass() || $self->cellclass();
   my $weekendcellclass = $self->weekendcellclass() || $self->cellclass();
   my $todaycellclass = $self->todaycellclass() || $self->cellclass();
   my $headerclass = $self->headerclass() || $self->cellclass();
   my $nowrap = $self->nowrap();

   # Get today's date, in case there's a todaycolor()
   my($todayyear,$todaymonth,$todaydate) = ($self->today_year(),$self->today_month(),$self->today_date());

   # the table declaration - sharpborders wraps the table inside a table cell
   if ($sharpborders) {
      $html .= "<table border=\"0\"";
      $html .= " class=\"$tableclass\"" if defined $tableclass;
      $html .= " width=\"$tablewidth\"" if defined $tablewidth;
      $html .= " cellpadding=\"0\" cellspacing=\"0\">\n";
      $html .= "<tr valign=\"top\" align=\"left\">\n";
      $html .= "<td align=\"left\" valign=\"top\"";
      $html .= " bgcolor=\"$bordercolor\"" if defined $bordercolor;
      $html .= ">";
      $html .= "<table border=\"0\" cellpadding=\"3\" cellspacing=\"1\" width=\"100%\">";
   }
   else {
      $html .= "<table";
      $html .= " class=\"$tableclass\"" if defined $tableclass;
      $html .= " border=\"$border\"" if defined $border;
      $html .= " width=\"$tablewidth\"" if defined $tablewidth;
      $html .= " bgcolor=\"$bgcolor\"" if defined $bgcolor;
      $html .= " bordercolor=\"$bordercolor\"" if defined $bordercolor;
      $html .= " cellpadding=\"$cellpadding\"" if defined $cellpadding;
      $html .= " cellspacing=\"$cellspacing\""  if defined $cellspacing;
      $html .= ">\n";
   }
   # the header
   if ($header) {
      $html .= "<tr><td colspan=\"7\"";
      $html .= " bgcolor=\"$headercolor\"" if defined $headercolor;
      $html .= " class=\"$headerclass\"" if defined $headerclass;
      $html .= ">";
      $html .= "<font color=\"$headercontentcolor\">" if defined $headercontentcolor;
      $html .= $header;
      $html .= "</font>"  if defined $headercontentcolor;
      $html .= "</td></tr>\n";
   }
   # the names of the days of the week
   if ($self->showweekdayheaders) {
      my $celltype = $self->weekdayheadersbig() ? "th" : "td";
      my @weekdays = $self->weekdays();

      my $saturday_html = "<$celltype"
                        . ( defined $weekendheadercolor
                            ? qq| bgcolor="$weekendheadercolor"|
                            : '' )
                        . ( defined $weekendcellclass
                            ? qq| class="$weekendcellclass"|
                            : '' )
                        . ">"
                        . ( defined $weekendheadercontentcolor
                            ? qq|<font color="$weekendheadercontentcolor">|
                            : '' )
                        . $self->saturday()
                        . ( defined $weekendheadercontentcolor
                            ? qq|</font>|
                            : '' )
                        . "</$celltype>\n";

      my $sunday_html   = "<$celltype"
                        . ( defined $weekendheadercolor
                            ? qq| bgcolor="$weekendheadercolor"|
                            : '' )
                        . ( defined $weekendcellclass
                            ? qq| class="$weekendcellclass"|
                            : '' )
                        . ">"
                        . ( defined $weekendheadercontentcolor
                            ? qq|<font color="$weekendheadercontentcolor">|
                            : '' )
                        . $self->sunday()
                        . ( defined $weekendheadercontentcolor
                            ? qq|</font>|
                            : '' )
                        . "</$celltype>\n";

      my $weekday_html = '';
      foreach (@weekdays) { # draw the weekday headers

         $weekday_html  .= "<$celltype"
                        . ( defined $weekendheadercolor
                            ? qq| bgcolor="$weekdayheadercolor"|
                            : '' )
                        . ( defined $weekendcellclass
                            ? qq| class="$weekdaycellclass"|
                            : '' )
                        . ">"
                        . ( defined $weekdayheadercontentcolor
                            ? qq|<font color="$weekdayheadercontentcolor">|
                            : '' )
                        . $_
                        . ( defined $weekdayheadercontentcolor
                            ? qq|</font>|
                            : '' )
                        . "</$celltype>\n";
      }

      $html .= "<tr>\n";
      if ($self->weekstartsonmonday()) {
        $html .= $weekday_html
              .  $saturday_html
              .  $sunday_html;
      }
      else {
        $html .= $sunday_html
              .  $weekday_html
              .  $saturday_html;
      }
      $html .= "</tr>\n";
   }

   my $_saturday_index = 6;
   my $_sunday_index   = 0;
   if ($self->weekstartsonmonday()) {
       $_saturday_index = 5;
       $_sunday_index   = 6;
   }
   # now do each day, the actual date-content-containing cells
   foreach $WEEK (0 .. ($weeks-1)) {
      $html .= "<tr>\n";

      foreach $DAY ( 0 .. 6 ) {
         my($thiscontent,$thisday,$thisbgcolor,$thisbordercolor,$thiscontentcolor,$thiscellclass);
         $thisday = $days[((7*$WEEK)+$DAY)];

         # Get the cell content
         if (! $thisday) { # If it's a dummy cell, no content
            $thiscontent = '&nbsp;'; }
         else { # A real date cell with potential content
            # Get the content
            if ($self->showdatenumbers()) {
              if ( $self->getdatehref( $thisday )) {
                $thiscontent = "<p><b><a href=\"".$self->getdatehref($thisday);
                $thiscontent .= "\">$thisday</a></b></p>\n";
              } else {
                $thiscontent = "<p><b>$thisday</b></p>\n";
              }
            }
            $thiscontent .= $self->{'content'}->{$thisday};
            $thiscontent ||= '&nbsp;';
         }

         # Get the cell's coloration and CSS class
         if ($self->year == $todayyear && $self->month == $todaymonth && $thisday == $todaydate)
                                              { $thisbgcolor = $self->datecolor($thisday) || $todaycolor;
                                                $thisbordercolor = $self->datebordercolor($thisday) || $todaybordercolor;
                                                $thiscontentcolor = $self->datecontentcolor($thisday) || $todaycontentcolor;
                                                $thiscellclass = $self->datecellclass($thisday) || $todaycellclass;
                                              }
         elsif (($DAY == $_sunday_index) || ($DAY == $_saturday_index))   { $thisbgcolor = $self->datecolor($thisday) || $weekendcolor;
                                                $thisbordercolor = $self->datebordercolor($thisday) || $weekendbordercolor;
                                                $thiscontentcolor = $self->datecontentcolor($thisday) || $weekendcontentcolor;
                                                $thiscellclass = $self->datecellclass($thisday) || $weekendcellclass;
                                              }
         else                                 { $thisbgcolor = $self->datecolor($thisday) || $weekdaycolor;
                                                $thisbordercolor = $self->datebordercolor($thisday) || $weekdaybordercolor;
                                                $thiscontentcolor = $self->datecontentcolor($thisday) || $weekdaycontentcolor;
                                                $thiscellclass = $self->datecellclass($thisday) || $weekdaycellclass;
                                              }

         # Done with this cell - push it into the table
         $html .= "<td";
         $html .= " nowrap" if $nowrap;
         $html .= " class=\"$thiscellclass\"" if defined $thiscellclass;
         $html .= " height=\"$cellheight\"" if defined $cellheight;
         $html .= " width=\"$cellwidth\"" if defined $cellwidth;
         $html .= " valign=\"$vcellalignment\"" if defined $vcellalignment;
         $html .= " align=\"$cellalignment\"" if defined $cellalignment;
         $html .= " bgcolor=\"$thisbgcolor\"" if defined $thisbgcolor;
         $html .= " bordercolor=\"$thisbordercolor\"" if defined $thisbordercolor;
         $html .= ">";
         $html .= "<font" if (defined $thiscontentcolor ||
                              defined $contentfontsize);
         $html .= " color=\"$thiscontentcolor\"" if defined $thiscontentcolor;
         $html .= " size=\"$contentfontsize\""  if defined $contentfontsize;
         $html .= ">" if (defined $thiscontentcolor ||
                          defined $contentfontsize);
         $html .= $thiscontent;
         $html .= "</font>" if (defined $thiscontentcolor ||
                                defined $contentfontsize);
         $html .= "</td>\n";
      }
      $html .= "</tr>\n";
   }
   $html .= "</table>\n";

   # if sharpborders, we need to break out of the enclosing table cell
   if ($sharpborders) {
      $html .= "</td>\n</tr>\n</table>\n";
   }

   return $html;
}

sub sunday {
   my $self = shift;
   my $newvalue = shift;
   $self->{'sunday'} = $newvalue if defined($newvalue);
   return $self->{'sunday'};
}

sub saturday {
   my $self = shift;
   my $newvalue = shift;
   $self->{'saturday'} = $newvalue if defined($newvalue);
   return $self->{'saturday'};
}

sub weekdays {
   my $self = shift;
   my @days = @_;
   $self->{'weekdays'} = \@days if (scalar(@days)==5);
   return @{$self->{'weekdays'}};
}

sub getdatehref {
   my $self = shift;
   my @dates = $self->_date_string_to_numeric(shift); return() unless @dates;
   return $self->{'href'}->{$dates[0]};
}

sub setdatehref {
   my $self = shift;
   my @dates = $self->_date_string_to_numeric(shift); return() unless @dates;
   my $datehref = shift || '';

   foreach my $date (@dates) {
      $self->{'href'}->{$date} = $datehref if defined($self->{'href'}->{$date});
   }
   
   return(1);
}

sub weekendcolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekendcolor'} = $newvalue; }
   return $self->{'weekendcolor'};
}

sub weekendheadercolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekendheadercolor'} = $newvalue; }
   return $self->{'weekendheadercolor'};
}

sub weekdayheadercolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekdayheadercolor'} = $newvalue; }
   return $self->{'weekdayheadercolor'};
}

sub weekdaycolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekdaycolor'} = $newvalue; }
   return $self->{'weekdaycolor'};
}

sub headercolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'headercolor'} = $newvalue; }
   return $self->{'headercolor'};
}

sub bgcolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'bgcolor'} = $newvalue; }
   return $self->{'bgcolor'};
}

sub todaycolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'todaycolor'} = $newvalue; }
   return $self->{'todaycolor'};
}

sub bordercolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'bordercolor'} = $newvalue; }
   return $self->{'bordercolor'};
}

sub weekdaybordercolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekdaybordercolor'} = $newvalue; }
   return $self->{'weekdaybordercolor'};
}

sub weekendbordercolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekendbordercolor'} = $newvalue; }
   return $self->{'weekendbordercolor'};
}
sub todaybordercolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'todaybordercolor'} = $newvalue; }
   return $self->{'todaybordercolor'};
}

sub contentcolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'contentcolor'} = $newvalue; }
   return $self->{'contentcolor'};
}

sub headercontentcolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'headercontentcolor'} = $newvalue; }
   return $self->{'headercontentcolor'};
}

sub weekdayheadercontentcolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekdayheadercontentcolor'} = $newvalue; }
   return $self->{'weekdayheadercontentcolor'};
}

sub weekendheadercontentcolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekendheadercontentcolor'} = $newvalue; }
   return $self->{'weekendheadercontentcolor'};
}

sub weekdaycontentcolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekdaycontentcolor'} = $newvalue; }
   return $self->{'weekdaycontentcolor'};
}

sub weekendcontentcolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekendcontentcolor'} = $newvalue; }
   return $self->{'weekendcontentcolor'};
}

sub todaycontentcolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'todaycontentcolor'} = $newvalue; }
   return $self->{'todaycontentcolor'};
}

sub datecolor {
   my $self = shift;
   my @dates = $self->_date_string_to_numeric(shift); return() unless @dates;
   my $newvalue = shift;

   if (defined($newvalue)) {
      foreach my $date (@dates) {
         $self->{'datecolor'}->{$date} = $newvalue if defined($self->{'datecolor'}->{$date});
      }
   }

   return $self->{'datecolor'}->{$dates[0]};
}

sub datebordercolor {
   my $self = shift;
   my @dates = $self->_date_string_to_numeric(shift); return() unless @dates;
   my $newvalue = shift;

   if (defined($newvalue)) {
      foreach my $date (@dates) {
         $self->{'datebordercolor'}->{$date} = $newvalue if defined($self->{'datebordercolor'}->{$date});
      }
   }

   return $self->{'datebordercolor'}->{$dates[0]};
}

sub datecontentcolor {
   my $self = shift;
   my @dates = $self->_date_string_to_numeric(shift); return() unless @dates;
   my $newvalue = shift;

   if (defined($newvalue)) {
      foreach my $date (@dates) {
         $self->{'datecontentcolor'}->{$date} = $newvalue if defined($self->{'datecontentcolor'}->{$date});
      }
   }

   return $self->{'datecontentcolor'}->{$dates[0]};
}

sub getcontent {
   my $self = shift;
   my @dates = $self->_date_string_to_numeric(shift); return() unless @dates;
   return $self->{'content'}->{$dates[0]};
}

sub setcontent {
   my $self = shift;
   my @dates = $self->_date_string_to_numeric(shift); return() unless @dates;
   my $newcontent = shift || '';

   foreach my $date (@dates) {
      $self->{'content'}->{$date} = $newcontent if defined($self->{'content'}->{$date});
   }

   return(1);
}

sub addcontent {
   my $self = shift;
   my @dates = $self->_date_string_to_numeric(shift); return() unless @dates;
   my $newcontent = shift || return();

   foreach my $date (@dates) {
      $self->{'content'}->{$date} .= $newcontent if defined($self->{'content'}->{$date});
   }

   return(1);
}

sub border {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'border'} = int($newvalue); }
   return $self->{'border'};
}


sub cellpadding {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'cellpadding'} = $newvalue; }
   return $self->{'cellpadding'};
}

sub cellspacing {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'cellspacing'} = $newvalue; }
   return $self->{'cellspacing'};
}

sub width {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'width'} = $newvalue; }
   return $self->{'width'};
}

sub showdatenumbers {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'showdatenumbers'} = $newvalue; }
   return $self->{'showdatenumbers'};
}
sub showweekdayheaders {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'showweekdayheaders'} = $newvalue; }
   return $self->{'showweekdayheaders'};
}

sub cellalignment {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'cellalignment'} = $newvalue; }
   return $self->{'cellalignment'};
}

sub vcellalignment {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'vcellalignment'} = $newvalue; }
   return $self->{'vcellalignment'};
}

sub contentfontsize {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'contentfontsize'} = $newvalue; }
   return $self->{'contentfontsize'};
}

sub weekdayheadersbig {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekdayheadersbig'} = $newvalue; }
   return $self->{'weekdayheadersbig'};
}

sub year {
   my $self = shift;
   return $self->{'year'};
}

sub month {
   my $self = shift;
   return $self->{'month'};
}

sub monthname {
   my $self = shift;
   return $self->{'monthname'};
}

sub today_year {
   my $self = shift;
   return $self->{'today_year'};
}

sub today_month {
   my $self = shift;
   return $self->{'today_month'};
}

sub today_date {
   my $self = shift;
   return $self->{'today_date'};
}


sub header {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'header'} = $newvalue; }
   return $self->{'header'};
}

sub nowrap {
    my $self = shift;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'nowrap'} = $newvalue; }
    return $self->{'nowrap'};
}

sub sharpborders {
    my $self = shift;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'sharpborders'} = $newvalue; }
    return $self->{'sharpborders'};
}

sub cellheight {
    my $self = shift;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'cellheight'} = $newvalue; }
    return $self->{'cellheight'};
}

sub cellclass {
    my $self = shift;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'cellclass'} = $newvalue; }
    return $self->{'cellclass'};
}

sub tableclass {
    my $self = shift;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'tableclass'} = $newvalue; }
    return $self->{'tableclass'};
}

sub weekdaycellclass {
    my $self = shift;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'weekdaycellclass'} = $newvalue; }
    return $self->{'weekdaycellclass'};
}

sub weekendcellclass {
    my $self = shift;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'weekendcellclass'} = $newvalue; }
    return $self->{'weekendcellclass'};
}

sub todaycellclass {
    my $self = shift;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'todaycellclass'} = $newvalue; }
    return $self->{'todaycellclass'};
}

sub datecellclass {
    my $self = shift;
    my $date = lc(shift) || return(); $date = int($date) if $date =~ m/^[\d\.]+$/;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'datecellclass'}->{$date} = $newvalue; }
    return $self->{'datecellclass'}->{$date};
}

sub headerclass {
    my $self = shift;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'headerclass'} = $newvalue; }
    return $self->{'headerclass'};
}

sub weekstartsonmonday {
    my $self = shift;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'weekstartsonmonday'} = $newvalue; }
    return $self->{'weekstartsonmonday'} ? 1 : 0;
}


### the following methods are internal-use-only methods

# _date_string_to_numeric() takes a date string (e.g. 5, 'wednesdays', or '3friday')
# and returns the corresponding numeric date. For numerics, this sounds meaningless,
# but for the strings it's useful to have this all in one place.
# If it's a plural weekday (e.g. 'sundays') then an array of numeric dates is returned.
sub _date_string_to_numeric {
   my $self = shift;
   my $date = shift || return ();

   my($which,$weekday);
   if ($date =~ m/^\d\.*\d*$/) { # first and easiest, simple numerics
      return int($date);
   }
   elsif (($which,$weekday) = ($date =~ m/^(\d)([a-zA-Z]+)$/)) {
      my($y,$m,$d) = Date::Calc::Nth_Weekday_of_Month_Year($self->year(),$self->month(),Date::Calc::Decode_Day_of_Week($weekday),$which);
      return $d;
   }
   elsif (($weekday) = ($date =~ m/^(\w+)s$/i)) {
      $weekday = Date::Calc::Decode_Day_of_Week($weekday); # now it's the numeric weekday
      my @dates;
      foreach my $which (1..5) {
         my $thisdate = Date::Calc::Nth_Weekday_of_Month_Year($self->year(),$self->month(),$weekday,$which);
         push(@dates,$thisdate) if $thisdate;
      }
      return @dates;
   }
}



__PACKAGE__->meta->make_immutable;

1;

