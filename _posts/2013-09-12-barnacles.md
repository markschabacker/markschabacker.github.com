---
layout: post
title: "Technical Debt as Barnacles"
---
### Barnacles in Code
As I dug through a particularly overburdened singleton at work recently, I was reminded of a constant in software development: crummy code attracts more crummy code.  I could see the justifications that the previous developer _(read: me)_ had made and they probably made sense at the time.  Unfortunately, the compromises did not hold up over the years and we had finally reached a point where the whole mess needed to be teased apart and cleaned up.  It was time to do some _barnacle scraping_.

<div about='http://farm5.static.flickr.com/4039/4473732027_a534775a4b_b.jpg'><a href='http://www.flickr.com/photos/portofsandiego/4473732027/' target='_blank'><img xmlns:dct='http://purl.org/dc/terms/' href='http://purl.org/dc/dcmitype/StillImage' rel='dct:type' src='/images/barnacle_cleaning.jpg' alt='HMS Surprise at Chula Vista Marine Group by Port of San Diego, on Flickr' title='HMS Surprise at Chula Vista Marine Group by Port of San Diego, on Flickr' border='0'/></a><br/><a rel='license' href='http://creativecommons.org/licenses/by/2.0/' target='_blank'><img src='http://i.creativecommons.org/l/by/2.0/80x15.png' alt='Creative Commons Attribution 2.0 Generic License' title='Creative Commons Attribution 2.0 Generic License' border='0' align='left'></a>&nbsp;&nbsp;by&nbsp;<a href='http://www.flickr.com/people/portofsandiego/' target='_blank'>&nbsp;</a><a xmlns:cc='http://creativecommons.org/ns#' rel='cc:attributionURL' property='cc:attributionName' href='http://www.flickr.com/people/portofsandiego/' target='_blank'>Port of San Diego</a></div>

### A Marine Metaphor
Barnacles.  The bane of any boat owner's existence.  The persistent critters attach themselves to any submerged surface in as little as a long weekend.  Wait much longer than that and you've got a real mess on your hands.  Cleanup involves laboriously scraping or pressure washing the boat's hull followed by a chemical treatment.  If you skip the cleanup, expect reduced speed and fuel efficiency due to the added drag.

[Technical Debt](http://martinfowler.com/bliki/TechnicalDebt.html) like my overburdened singleton is like a barnacle infestation in a few ways:

#### Easy To Clean If Addressed Early
A weekend's worth of barnacle growth can be scrubbed off with just a hose and brush.  This is technical debt in the top right of the [Technical Debt Quadrant](http://martinfowler.com/bliki/TechnicalDebtQuadrant.html) that is addressed in a timely manner.

#### Painful To Rectify If Addressed Too Late
Removal of a entrenched barnacle infestation is a difficult and time consuming process.  Simple cleaning tools will no longer suffice: it's time for a pressure washer or a putty knife and SCUBA gear.  This is likely technical debt from the left side of the quadrant but might be 'good' debt that has been ignored for too long.

#### Impacts Performance If Ignored
Like a boat slowed by extra drag on its hull, a team burdened by excess technical debt cannot operate at top performance.  The team can slog on inefficiently or choose to "Dry Dock" for a bit and streamline itself.

<br/>
<div about='http://farm4.static.flickr.com/3754/9246120511_d5e3a2f726_b.jpg'><a href='http://www.flickr.com/photos/quinet/9246120511/' target='_blank'><img xmlns:dct='http://purl.org/dc/terms/' href='http://purl.org/dc/dcmitype/StillImage' rel='dct:type' src='/images/barnacles_close.jpg' alt='Barnacles 7 by quinet, on Flickr' title='Barnacles 7 by quinet, on Flickr' border='0'/></a><br/><a rel='license' href='http://creativecommons.org/licenses/by/2.0/' target='_blank'><img src='http://i.creativecommons.org/l/by/2.0/80x15.png' alt='Creative Commons Attribution 2.0 Generic License' title='Creative Commons Attribution 2.0 Generic License' border='0' align='left'></a>&nbsp;&nbsp;by&nbsp;<a href='http://www.flickr.com/people/quinet/' target='_blank'>&nbsp;</a><a xmlns:cc='http://creativecommons.org/ns#' rel='cc:attributionURL' property='cc:attributionName' href='http://www.flickr.com/people/quinet/' target='_blank'>quinet</a></div>
