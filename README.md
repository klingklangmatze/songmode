## songmode
The Norns script provides a "song mode", or more precisely, a pattern chaining tool for e.g., Elektron Digitakt or Model:Cycles. It could also work with Model:Samples or Digitone...but I have not tested it.

#### Personal note
My programming experience is quite low, so I am grateful for any help, comments or suggestions for improvement.

#### Requirements
-	Norns (Factory / Fates / Shield)
-	Elektron Digitakt (or Model:Cycles)
-	MIDI connection between Norns and one of the devices listed above
-	Digitakt (or another device) must be able to receive both clock data and program change data (Channel 01)
-	Set Norns clock to "Internal" or "Link" as well as MIDI Output to 1

#### Documentation (Read me)
-	E1 scrolls pages
-	E2 scrolls bars
-	E3 scrolls pattern
-	K1 Alt
-	K2 starts/stops the Digitakt and the pattern sequence from the current frame position
-	K2+Alt starts/stops the Digitakt and the pattern sequence from Bar 1
-	K3 adds selected pattern to the song list
-	K3+Alt removes selected pattern from the song list

By using program change MIDI commands the patterns of the Digitakt (or the other device) can be changed. The "problem" is that these drum/sampler/synth machines need some time to handle the program change. E.g, if you want to change from A01 to A02, the program change trigger must be set while the A01 is playing. I have tried to take this into account in the script. Nevertheless you should start the script according to the following small instruction:

-	Choose an empty pattern manually on the Digitakt, which has to be 1 Bar in lenght (!!!). I usally use pattern A16.
-	Arrange your song/track by chaining the pattern
-	If the Digitakt pattern is 4 bars long, also four cells in the Norns app must be filled with the corresponding pattern number; a 2 bar pattern needs two cells, and so on.
-	No empty cells are allowed between filled cells (at least in the current version of the script)
-	K2 starts/stops the Digitakt and the pattern sequence from the current frame position. K2 + Alt starts/stops the Digitakt and the pattern sequence from Bar 1. There is a play cursor that shows the active bar. The small circle on the right side, just next to the page indicator indicates on which page the play cursor is currently located.
-	You can also activate/deactivate the loop mode in the parameter menu. When activated, the entire song or song section is looped.
- The parameter menu allows you to save and load tracks as well as to delete the current sequence.

#### Further aims
-	I would like to extend the script so that you can change the order of pattern during playing and add a loop of a selected part.
-	Currently, the script can be used to control only one device, why not implement a multi-track app.


