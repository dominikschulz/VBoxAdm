<div id="overview">
[% IF page.previous_page %]
<a href="[% base_url %]?rm=[% current %]&search=[% search %]&page=[% page.previous_page %]">[% "Previous Page" | l10n %]</a>
[% ELSE %]
[% "Previous Page" | l10n %]
[% END %]
 - [% "Current Page [_1] of [_2]" | l10n(page.current_page,page.last_page) %] - 
[% IF page.next_page %]
<a href="[% base_url %]?rm=[% current %]&search=[% search %]&page=[% page.next_page %]">[% "Next Page" | l10n %]</a>
[% ELSE %]
[% "Next Page" | l10n %]
[% END %]
</div>