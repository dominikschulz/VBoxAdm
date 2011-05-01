<!doctype html>  

<!-- paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/ --> 
<!--[if lt IE 7 ]> <html lang="en" class="no-js ie6"> <![endif]-->
<!--[if IE 7 ]>    <html lang="en" class="no-js ie7"> <![endif]-->
<!--[if IE 8 ]>    <html lang="en" class="no-js ie8"> <![endif]-->
<!--[if IE 9 ]>    <html lang="en" class="no-js ie9"> <![endif]-->
<!--[if (gt IE 9)|!(IE)]><!--> <html lang="en" class="no-js"> <!--<![endif]-->
<head>
  <meta charset="utf-8">

  <!-- Always force latest IE rendering engine (even in intranet) & Chrome Frame 
       Remove this if you use the .htaccess -->
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

  <title>[% title | l10n %]</title>
  <meta name="description" content="VBoxAdm Mailserver Web Management Interface">
  <meta name="author" content="VBoxAdm by Dominik Schulz">

  <!--  Mobile viewport optimized: j.mp/bplateviewport -->
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <!-- Place favicon.ico & apple-touch-icon.png in the root of your domain and delete these references -->
  <link rel="shortcut icon" href="[% media_prefix %]/favicon.ico">
  <link rel="apple-touch-icon" href="[% media_prefix %]/apple-touch-icon.png">

  <!-- CSS : implied media="all" -->
  <link rel="stylesheet" href="[% media_prefix %]/css/style.css?v=@VERSION@">
  
  <style type="text/css" title="currentStyle">
  	@import "[% media_prefix %]/css/datatable/datatable_jui.min.css?v=@VERSION@";
	@import "[% media_prefix %]/css/datatable/themes/smoothness/jquery-ui-1.8.4.custom.css?v=@VERSION@";
  </style>

  <!-- Uncomment if you are specifically targeting less enabled mobile browsers
  <link rel="stylesheet" media="handheld" href="[% media_prefix %]/css/handheld.css?v=@VERSION@">  -->
 
  <!-- All JavaScript at the bottom, except for Modernizr which enables HTML5 elements & feature detects -->
  <script src="[% media_prefix %]/js/libs/modernizr-1.7.js"></script>

</head>

<body>

  <div id="container">
    <header>
     <div id="logo">VBoxAdm</div>
     [% FOREACH line IN breadcrumb %]
     [% IF loop.first %]<div id="breadcrumb">[% END %]
     <a href="?rm=[% line.rm %]">[% line.caption %]</a>
     [% IF loop.last %]</div>[% END %]
     [% END %]
    </header>
    [% IF nonavigation != 1 %]
	[% INCLUDE includes/navigation.tpl %]
	[% END %]
	[% FOREACH message IN messages %]
		<div class="[% message.severity %]">[% message.loc %]</div>
	[% END %]
    </header>